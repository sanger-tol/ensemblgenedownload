// Module that downloads all necessary genome files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENOME_DOWNLOAD {
    tag "$assembly_accession"
    label 'process_single'

    conda (params.enable_conda ? "bioconda::wget=1.18" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gnu-wget:1.18--h7132678_6' :
        'quay.io/biocontainers/gnu-wget:1.18--h7132678_6' }"

    input:
    tuple val(ensembl_species_name), val(assembly_accession)

    output:
    tuple val(meta), path("*.fa") , emit: fasta
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/genome/Agriopis_aurantiaria-GCA_914767915.1-softmasked.fa.gz
    def ftp_path = params.ftp_root + "/" + ensembl_species_name + "/" + assembly_accession + "/genome"
    def remote_filename_stem = ensembl_species_name + "-" + assembly_accession

    meta = [ id : assembly_accession, accession : assembly_accession ]

    """
    #export https_proxy=http://wwwcache.sanger.ac.uk:3128
    #export http_proxy=http://wwwcache.sanger.ac.uk:3128
    wget ${ftp_path}/${remote_filename_stem}-softmasked.fa.gz
    wget ${ftp_path}/md5sum.txt

    grep -- "-softmasked\\.fa\\.gz\$" md5sum.txt > md5checksums_restricted.txt
    md5sum -c md5checksums_restricted.txt
    gunzip *.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n 1 | cut -d' ' -f3)
        BusyBox: \$(busybox | head -1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
