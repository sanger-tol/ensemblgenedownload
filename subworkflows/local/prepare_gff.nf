//
// Uncompress and prepare GFF files
//

include { TABIX_SORT_BGZIP        } from '../../modules/local/tabix_sort_bgzip'
include { TABIX_TABIX as TABIX_TABIX_CSI   } from '../../modules/nf-core/tabix/tabix/main'
include { TABIX_TABIX as TABIX_TABIX_TBI   } from '../../modules/nf-core/tabix/tabix/main'


workflow PREPARE_GFF {

    take:
    gff    // file: /path/to/genes.gff

    main:
    ch_versions = Channel.empty()

    // Compress the GFF file
    ch_compressed_gff   = TABIX_SORT_BGZIP ( gff ).output
    ch_versions         = ch_versions.mix(TABIX_SORT_BGZIP.out.versions.first())

    // Try indexing the GFF file in two formats for maximum compatibility
    // but each has its own limitations
    tabix_selector      = ch_compressed_gff.join(gff).map { meta, gff_gz, gff ->
        [ meta, gff_gz, get_max_coord(gff) ]
    } . branch { meta, gff_gz, max_coord ->
        tbi_and_csi: max_coord < 2**29
                        return [meta, gff_gz]
        only_csi:    max_coord < 2**31
                        return [meta, gff_gz]
        no_tabix:    true
                        return [meta, gff_gz]
    }

    // Output channels to tell the downstream subworkflows which indexes are missing
    // (therefore, only meta is available)
    no_csi              = tabix_selector.no_tabix.map {it[0]}
    no_tbi              = tabix_selector.only_csi.mix(tabix_selector.no_tabix).map {it[0]}

    ch_indexed_gff_csi  = TABIX_TABIX_CSI ( tabix_selector.tbi_and_csi.mix(tabix_selector.only_csi) ).csi
    ch_versions         = ch_versions.mix(TABIX_TABIX_CSI.out.versions.first())
    ch_indexed_gff_tbi  = TABIX_TABIX_TBI ( tabix_selector.tbi_and_csi ).tbi
    ch_versions         = ch_versions.mix(TABIX_TABIX_TBI.out.versions.first())


    emit:
    gff_gz   = ch_compressed_gff         // path: genes.gff.gz
    gff_csi  = ch_indexed_gff_csi        // path: genes.gff.csi
    gff_tbi  = ch_indexed_gff_tbi        // path: genes.gff.tbi
    no_csi   = no_csi                       // (only meta)
    no_tbi   = no_tbi                       // (only meta)
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}

// Inspired from https://github.com/nf-core/rnaseq/blob/3.10.1/lib/WorkflowRnaseq.groovy
def get_max_coord(gff_file) {
    def max_coord = 0
    gff_file.withReader { reader ->
        def line
        while ((line = reader.readLine()) != null) {
            if (!line.startsWith('#')) {
                def end_coord = line.split()[4].toInteger()
                if (end_coord > max_coord) {
                    max_coord = end_coord
                }
            }
        }
    }
    return max_coord
}
