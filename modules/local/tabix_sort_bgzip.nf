// Modified version of my TABIX_BGZIP that sorts the input file first.
// Supports BED and GFF files.
process TABIX_SORT_BGZIP {
    tag "$input"
    label 'process_single'

    conda 'bioconda::tabix=1.11'
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tabix:1.11--hdfd78af_0' :
        'biocontainers/tabix:1.11--hdfd78af_0' }"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.gz") , emit: output
    tuple val(meta), path("*.gzi"), emit: index
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix   = task.ext.prefix ?: "${meta.id}"
    coord    = input.name.endsWith(".bed") ? 2 : 4
    """
    (
        grep "^#" $input || true
        grep -v "^#" $input | sort -k1,1 -k${coord},${coord}n
    ) | bgzip \
        -i -I ${prefix}.${input.getExtension()}.gz.gzi \
        $args -@${task.cpus} \
        > ${prefix}.${input.getExtension()}.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tabix: \$(echo \$(tabix -h 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """
}
