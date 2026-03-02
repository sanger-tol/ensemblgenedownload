// Sort a GFF file while preserving the header lines
process SORT_GFF {
    tag "${input}"
    label 'process_single'

    conda 'conda-forge::coreutils=9.5'
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/coreutils:9.5'
        : 'biocontainers/coreutils:9.5'}"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.gff3"), emit: sorted
    tuple val("${task.process}"), val('coreutils'), eval("sort --version |& sed '1!d ; s/sort (GNU coreutils) //'"), emit: versions_coreutils, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    (
        grep "^#" ${input} || true
        grep -v "^#" ${input} | sort -k1,1 -k4,4n
    ) > ${prefix}.sorted.${input.extension}
    """
}
