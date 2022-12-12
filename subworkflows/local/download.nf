//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENESET_DOWNLOAD      } from '../../modules/local/ensembl_geneset_download'


workflow DOWNLOAD {

    take:
    annotation_params         // tuple(analysis_dir, ensembl_species_name, assembly_accession, annotation_method, geneset_version)


    main:
    ch_versions = Channel.empty()

    ENSEMBL_GENESET_DOWNLOAD (
        annotation_params.map { [
            // meta
            [
                assembly_accession: it[2],
                geneset_version: it[4],
                method: it[3],
                outdir: it[0],
            ],
            // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/braker/geneset/2021_12/Agriopis_aurantiaria-GCA_914767915.1-2021_12-cdna.fa.gz
            // ftp_path
            [params.ftp_root, it[1], it[2], it[3], "geneset", it[4]].join("/"),
            // remote_filename_stem
            it[1] + "-" + it[2] + "-" + it[4],
        ] },
    )
    ch_versions         = ch_versions.mix(ENSEMBL_GENESET_DOWNLOAD.out.versions.first())

    // Set meta.id
    ch_all_gene_fasta   = Channel.empty()
        // All three channels are tuple(meta,fasta). Extend the tuple with the sequence type
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cdna.map { it + ["cdna"] } )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cds.map  { it + ["cds"] }  )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.pep.map  { it + ["pep"] }  )
        // Add `id` to meta
        .map { [
            it[0] + [
                id: [it[0].assembly_accession, it[0].method, it[0].geneset_version, it[2]].join("."),
            ],
            it[1]
        ] }

    // tuple(meta,gff) at this stage
    ch_gff = ENSEMBL_GENESET_DOWNLOAD.out.gff.map { [
                // Like above, add meta.id
                it[0] + [
                    id: [it[0].assembly_accession, it[0].method, it[0].geneset_version].join("."),
                ],
                it[1]
            ] }


    emit:
    genes    = ch_all_gene_fasta         // path: (cdna|cds|pep).fa
    gff      = ch_gff                    // path: genes.gff
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
