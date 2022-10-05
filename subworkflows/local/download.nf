//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENESET_DOWNLOAD      } from '../../modules/local/ensembl_geneset_download'


workflow DOWNLOAD {

    take:
    annotation_params         // tuple(analysis_dir, ensembl_species_name, assembly_accession, geneset_version)


    main:
    ch_versions = Channel.empty()

    ENSEMBL_GENESET_DOWNLOAD ( annotation_params )
    ch_versions         = ch_versions.mix(ENSEMBL_GENESET_DOWNLOAD.out.versions.first())

    // Note: ideally ENSEMBL_GENESET_DOWNLOAD should set meta right, but we need the annotation method
    //       which is only available once the download has happened
    ch_all_gene_fasta   = Channel.empty()
        // All three channels are tuple(meta,annotation_method,fasta). Extend the tuple with the sequence type
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cdna.map { it + ["cdna"] } )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cds.map  { it + ["cds"] }  )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.pep.map  { it + ["pep"] }  )
        // Turn into the regular tuple(meta,file), with `id` and others in meta
        .map { [
            it[0] + [
                id: [it[0].assembly_accession, it[1], it[0].geneset_version, it[3]].join("."),
                method: it[1],
            ],
            it[2]
        ] }

    // tuple(meta,annotation_method,gff) at this stage
    ch_gff = ENSEMBL_GENESET_DOWNLOAD.out.gff.map { [
                // Like above, turn into the regular tuple(meta,file), with `id` and others in meta
                it[0] + [
                    id: [it[0].assembly_accession, it[1], it[0].geneset_version].join("."),
                    method: it[1],
                    geneset_version: it[0].geneset_version,
                ],
                it[2]
            ] }


    emit:
    genes    = ch_all_gene_fasta         // path: (cdna|cds|pep).fa
    gff      = ch_gff                    // path: genes.gff
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
