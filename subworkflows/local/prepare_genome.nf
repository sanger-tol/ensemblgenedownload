//
// Uncompress and prepare reference genome files
//

include { CHROM_SIZES             } from '../../modules/local/chrom_sizes'
include { SAMTOOLS_FAIDX          } from '../../modules/nf-core/modules/samtools/faidx/main'
include { SAMTOOLS_DICT           } from '../../modules/nf-core/modules/samtools/dict/main'
include { TABIX_BGZIP             } from '../../modules/local/tabix_bgzip'


workflow PREPARE_GENOME {

    take:
    fasta  // file: /path/to/genome.fa


    main:
    ch_versions = Channel.empty()

    // Compress the Fasta file
    ch_compressed_fasta = TABIX_BGZIP (fasta).output
    ch_versions         = ch_versions.mix(TABIX_BGZIP.out.versions)

    // Generate Samtools index
    ch_samtools_faidx   = SAMTOOLS_FAIDX (ch_compressed_fasta).fai
    ch_versions         = ch_versions.mix(SAMTOOLS_FAIDX.out.versions)

    // Generate Samtools dictionary
    ch_samtools_dict    = SAMTOOLS_DICT (fasta).dict
    ch_versions         = ch_versions.mix(SAMTOOLS_DICT.out.versions)

    // For all UCSC tools such as bedToBigBed
    ch_chrom_sizes      = CHROM_SIZES ( ch_samtools_faidx ).chrom_sizes
    ch_versions         = ch_versions.mix(CHROM_SIZES.out.versions)

    emit:
    fasta_gz = ch_compressed_fasta       // path: genome.fa.gz
    faidx    = ch_samtools_faidx         // path: samtools/faidx/
    dict     = ch_samtools_dict          // path: samtools/dict/
    sizes    = ch_chrom_sizes            // path: samtools/dict/
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
