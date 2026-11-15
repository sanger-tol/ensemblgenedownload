// Module that downloads all necessary geneset files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENESET_DOWNLOAD {
    tag "${meta.assembly_accession}.${meta.method}.${meta.geneset_version}"
    label 'process_single'

    conda "bioconda::gnu-wget=1.18"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6'
        : 'biocontainers/gnu-wget:1.18--h7132678_6'}"

    input:
    tuple val(meta), val(ftp_path)

    output:
    tuple val(meta), path("*cdna.fa"), emit: cdna
    tuple val(meta), path("*genes.gff3"), emit: gff
    tuple val(meta), path("*pep.fa"), emit: pep
    tuple val("${task.process}"), val('wget'), eval("wget --version | head -n 1 | cut -d' ' -f3"), topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def filename_stem = "${meta.assembly_accession}.${meta.method}.${meta.geneset_version}"
    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    rm -f *.bgz md5sum.txt
    wget ${ftp_path}/cdna.fa.bgz
    wget ${ftp_path}/genes.gff3.bgz
    wget ${ftp_path}/pep.fa.bgz
    wget ${ftp_path}/md5sum.txt

    # Some files may be missing from md5sum.txt, let's not bother
    if grep "\\(cdna\\.fa\\.bgz\$\\|genes\\.gff3\\.bgz\$\\|pep\\.fa\\.bgz\$\\)" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi
    # Temporary, until the sub-workflow downstream can accept compressed files
    mv cdna.fa.bgz ${filename_stem}.cdna.fa.gz
    mv genes.gff3.bgz ${filename_stem}.genes.gff3.gz
    mv pep.fa.bgz ${filename_stem}.pep.fa.gz
    gunzip *.gz
    """
}
