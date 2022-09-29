//
// Uncompress and prepare GFF files
//

include { TABIX_SORT_BGZIP        } from '../../modules/local/tabix_sort_bgzip'
include { TABIX_TABIX as TABIX_TABIX_CSI   } from '../../modules/nf-core/modules/tabix/tabix/main'
include { TABIX_TABIX as TABIX_TABIX_TBI   } from '../../modules/nf-core/modules/tabix/tabix/main'


workflow PREPARE_GFF {

    take:
    gff    // file: /path/to/genes.gff

    main:
    ch_versions = Channel.empty()

    // Compress the GFF file
    ch_compressed_gff   = TABIX_SORT_BGZIP ( gff ).output
    ch_versions         = ch_versions.mix(TABIX_SORT_BGZIP.out.versions.first())

    // Index the GFF file in two formats for maximum compatibility
    ch_indexed_gff_csi  = TABIX_TABIX_CSI ( ch_compressed_gff ).csi
    ch_versions         = ch_versions.mix(TABIX_TABIX_CSI.out.versions.first())
    ch_indexed_gff_tbi  = TABIX_TABIX_TBI ( ch_compressed_gff ).tbi
    ch_versions         = ch_versions.mix(TABIX_TABIX_TBI.out.versions.first())


    emit:
    gff_gz   = ch_compressed_gff         // path: genes.gff.gz
    gff_csi  = ch_indexed_gff_csi        // path: genes.gff.csi
    gff_tbi  = ch_indexed_gff_tbi        // path: genes.gff.tbi
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
