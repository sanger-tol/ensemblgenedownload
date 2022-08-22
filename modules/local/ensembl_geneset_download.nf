// Module that downloads all necessary geneset files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENESET_DOWNLOAD {
    tag "${assembly_accession}|${geneset_version}"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::wget=1.18" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6' :
        'quay.io/biocontainers/gnu-wget:1.18--h7132678_6' }"

    input:
    tuple val(analysis_dir), val(ensembl_species_name), val(assembly_accession), val(geneset_version)

    output:
    tuple val(meta), env(ANNOTATION_METHOD), path("*-cdna.fa")    , emit: cdna
    tuple val(meta), env(ANNOTATION_METHOD), path("*-cds.fa")     , emit: cds
    tuple val(meta), env(ANNOTATION_METHOD), path("*-genes.gff3") , emit: gff
    tuple val(meta), env(ANNOTATION_METHOD), path("*-pep.fa")     , emit: pep
    path  "versions.yml"                                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/geneset/2021_12/Agriopis_aurantiaria-GCA_914767915.1-2021_12-cdna.fa.gz
    def ftp_path = params.ftp_root + "/" + ensembl_species_name + "/" + assembly_accession + "/geneset/" + geneset_version
    def remote_filename_stem = ensembl_species_name + "-" + assembly_accession + "-" + geneset_version

    // id will be added later
    meta = [ outdir : analysis_dir, accession : assembly_accession, version: geneset_version ]

    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    wget ${ftp_path}/${remote_filename_stem}-cdna.fa.gz
    wget ${ftp_path}/${remote_filename_stem}-cds.fa.gz
    wget ${ftp_path}/${remote_filename_stem}-genes.gff3.gz
    wget ${ftp_path}/${remote_filename_stem}-pep.fa.gz
    wget ${ftp_path}/md5sum.txt

    # Some files may be missing from md5sum.txt, let's not bother
    grep "\\(-cdna\\.fa\\.gz\$\\|-cds\\.fa\\.gz\$\\|-genes\\.gff3\\.gz\$\\|-pep\\.fa\\.gz\$\\)" md5sum.txt > md5checksums_restricted.txt || true
    [ -s md5checksums_restricted.txt ] && md5sum -c md5checksums_restricted.txt
    gunzip *.gz
    if head -n 1 ${remote_filename_stem}-pep.fa | grep '^>BRAKER'
    then
        ANNOTATION_METHOD=braker2
    else
        ANNOTATION_METHOD=ensembl
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n 1 | cut -d' ' -f3)
        BusyBox: \$(busybox | head -1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
