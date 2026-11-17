// Module that downloads all necessary geneset files from Ensembl.
// The module checks that the MD5 checksums match before releasing the data.
// It also uncompresses the files, since we want bgzip compression.
process ENSEMBL_GENESET_DOWNLOAD {
    tag "${meta.assembly_accession}.${meta.method}.${meta.geneset_version}"
    label 'process_single'

    conda "conda-forge::rsync=3.4.1"
    container "${ workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/db/dbfb90af7b92fb651e63ab29ef1919606f5fc536a8eaf13da74439bf200dd89e/data'
        : 'community.wave.seqera.io/library/rsync:3.4.1--a8163606c0035a88' }"

    input:
    tuple val(meta), val(ftp_path)

    output:
    tuple val(meta), path("*.cdna.fa.*"), emit: cdna
    tuple val(meta), path("*.genes.gff3.*"), emit: gff
    tuple val(meta), path("*.pep.fa.*"), emit: pep
    tuple val("${task.process}"), val('rsync'), eval("rsync --version | sed '1!d;s/^rsync  version //; s/ .*//'"), topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def filename_stem = "${meta.assembly_accession}.${meta.method}.${meta.geneset_version}"
    """
    rsync -av \
      --exclude='*/' \
      --include='pep.fa.bgz*' \
      --include='genes.gff3.bgz*' \
      --include='cdna.fa.bgz*' \
      --include='md5sum.txt' \
      --exclude='*' \
      ${ftp_path}/ ./

    # Some files may be missing from md5sum.txt, let's not bother
    if grep "^\\(cdna\\.fa\\.bgz\\|genes\\.gff3\\.bgz\\|pep\\.fa\\.bgz\\)" md5sum.txt > md5checksums_restricted.txt
    then
        md5sum -c md5checksums_restricted.txt
    fi

    for i in pep.fa.* genes.gff3.* cdna.fa.*
    do
        mv \${i} ${filename_stem}.\${i/.bgz/.gz}
    done
    """

    stub:
    def filename_stem = "${meta.assembly_accession}.${meta.method}.${meta.geneset_version}"
    """
    touch ${filename_stem}.cdna.fa.gz
    touch ${filename_stem}.cdna.fa.gz.fai
    touch ${filename_stem}.cdna.fa.gz.gzi
    touch ${filename_stem}.genes.gff3.gz
    touch ${filename_stem}.genes.gff3.gz.csi
    touch ${filename_stem}.pep.fa.gz
    touch ${filename_stem}.pep.fa.gz.fai
    touch ${filename_stem}.pep.fa.gz.gzi
    """
}
