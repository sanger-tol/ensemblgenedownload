// Module that downloads all necessary geneset files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENESET_DOWNLOAD {
    tag "${meta.assembly_accession}|${meta.geneset_version}"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::wget=1.18" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6' :
        'quay.io/biocontainers/gnu-wget:1.18--h7132678_6' }"

    input:
    tuple val(meta), val(ftp_path), val(remote_filename_stem)

    output:
    tuple val(meta), path("*-cdna.fa")    , emit: cdna
    tuple val(meta), path("*-cds.fa")     , emit: cds
    tuple val(meta), path("*-genes.gff3") , emit: gff
    tuple val(meta), path("*-pep.fa")     , emit: pep
    path  "versions.yml"                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    rm -f *.gz md5sum.txt
    wget ${ftp_path}/${remote_filename_stem}-cdna.fa.gz
    wget ${ftp_path}/${remote_filename_stem}-cds.fa.gz
    wget ${ftp_path}/${remote_filename_stem}-genes.gff3.gz
    wget ${ftp_path}/${remote_filename_stem}-pep.fa.gz
    wget ${ftp_path}/md5sum.txt

    # Some files may be missing from md5sum.txt, let's not bother
    if grep "\\(-cdna\\.fa\\.gz\$\\|-cds\\.fa\\.gz\$\\|-genes\\.gff3\\.gz\$\\|-pep\\.fa\\.gz\$\\)" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi
    gunzip *.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n 1 | cut -d' ' -f3)
        BusyBox: \$(busybox | head -1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
