//
// Uncompress and prepare GFF files
//

include { SORT_GFF   } from '../../modules/local/sort_gff'
include { BGZIPTABIX } from '../../modules/sanger-tol/bgziptabix/main'


workflow PREPARE_GFF {
    take:
    ch_gff // file: /path/to/genes.gff

    main:

    ch_sorted_gff = SORT_GFF(ch_gff).sorted

    ch_gff_with_seq_length = ch_sorted_gff.map { meta, gff -> [meta, gff, get_max_coord(gff)] }
    BGZIPTABIX(ch_gff_with_seq_length)

    ch_indexed_gff = BGZIPTABIX.out.gz_index
        .join(BGZIPTABIX.out.tbi, by: 0, remainder: true)
        .join(BGZIPTABIX.out.csi, by: 0, remainder: true)

    emit:
    gff = ch_indexed_gff // channel: [ meta, gff.gz, gff.gzi, tbi?, csi? ]
}

// Inspired from https://github.com/nf-core/rnaseq/blob/3.10.1/lib/WorkflowRnaseq.groovy
def get_max_coord(gff_file) {
    def max_coord = 0
    gff_file.eachLine { line ->
        if (!line.startsWith('#')) {
            def end_coord = line.split()[4].toLong()
            if (end_coord > max_coord) {
                max_coord = end_coord
            }
        }
    }
    return max_coord
}
