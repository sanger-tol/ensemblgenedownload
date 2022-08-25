//
// Uncompress and prepare reference genome files
//

include { MASKING_TO_BED          } from '../../modules/local/masking_to_bed'
include { SAMTOOLS_FAIDX          } from '../../modules/nf-core/modules/samtools/faidx/main'
include { SAMTOOLS_DICT           } from '../../modules/nf-core/modules/samtools/dict/main'
include { TABIX_SORT_BGZIP        } from '../../modules/local/tabix_sort_bgzip'
include { TABIX_BGZIP             } from '../../modules/local/tabix_bgzip'
include { TABIX_TABIX             } from '../../modules/nf-core/modules/tabix/tabix/main'


workflow PREPARE_REPEATS {

    take:
    fasta  // file: /path/to/genome.fa

    main:
    ch_versions = Channel.empty()

    // BED file
    ch_masking_bed      = MASKING_TO_BED ( fasta ).bed
    ch_versions         = ch_versions.mix(MASKING_TO_BED.out.versions)

    // Compress the BED file
    ch_compressed_bed   = TABIX_SORT_BGZIP ( ch_masking_bed ).output
    ch_versions         = ch_versions.mix(TABIX_SORT_BGZIP.out.versions)

    // Index the BED file
    ch_indexed_bed      = TABIX_TABIX ( ch_compressed_bed ).tbi
    ch_versions         = ch_versions.mix(TABIX_TABIX.out.versions)

    // Compress the Fasta file
    ch_compressed_fasta = TABIX_BGZIP (fasta).output
    ch_versions         = ch_versions.mix(TABIX_BGZIP.out.versions)

    // Generate Samtools index
    // NOTE: this file is identical to the one of the unmasked genome but
    //       we've decided to keep it rather than making a symbolic link
    ch_samtools_faidx   = SAMTOOLS_FAIDX (ch_compressed_fasta).fai
    ch_versions         = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // Generate Samtools dictionary
    // NOTE: this file has the same sequence checksums as the one of the
    //       unmasked genome but the path is different
    ch_samtools_dict    = SAMTOOLS_DICT (fasta).dict
    ch_versions         = ch_versions.mix(SAMTOOLS_DICT.out.versions)

    emit:
    bed_gz   = ch_compressed_bed         // path: genome.bed.gz
    bed_tbi  = ch_indexed_bed            // path: genome.bed.tbi
    fasta_gz = ch_compressed_fasta       // path: genome.fa.gz
    faidx    = ch_samtools_faidx         // path: samtools/faidx/
    dict     = ch_samtools_dict          // path: samtools/dict/
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
