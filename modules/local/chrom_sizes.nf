// Module to create the chrom.sizes file required by many kent utils, e.g. for creating bigbed files
process CHROM_SIZES {
    tag "$meta.id"
    label 'process_single'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    tuple val(meta), path(faidx)

    output:
    tuple val(meta), path("*.chrom_sizes"), emit: chrom_sizes
    path  "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    cut -f1,2 ${faidx} > ${prefix}.chrom_sizes

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cut: \$(cut --version | head -n 1 | cut -d' ' -f4)
    END_VERSIONS
    """
}
