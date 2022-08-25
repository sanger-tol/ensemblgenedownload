//
// Uncompress and prepare GFF files
//

include { TABIX_SORT_BGZIP        } from '../../modules/local/tabix_sort_bgzip'
include { TABIX_TABIX             } from '../../modules/nf-core/modules/tabix/tabix/main'


workflow PREPARE_GFF {

    take:
    gff    // file: /path/to/genes.gff

    main:
    ch_versions = Channel.empty()

    // Compress the GFF file
    ch_compressed_gff   = TABIX_SORT_BGZIP ( gff ).output
    ch_versions         = ch_versions.mix(TABIX_SORT_BGZIP.out.versions)

    // Index the GFF file
    ch_indexed_gff      = TABIX_TABIX ( ch_compressed_gff ).tbi
    ch_versions         = ch_versions.mix(TABIX_TABIX.out.versions)

    emit:
    gff_gz   = ch_compressed_gff         // path: genes.gff.gz
    gff_tbi  = ch_indexed_gff            // path: genes.gff.tbi
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
