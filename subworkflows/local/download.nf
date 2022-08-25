//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENESET_DOWNLOAD      } from '../../modules/local/ensembl_geneset_download'
include { ENSEMBL_GENOME_DOWNLOAD       } from '../../modules/local/ensembl_genome_download'


workflow DOWNLOAD {

    take:
    inputs  // maps that indicate what to download (straight from the samplesheet)


    main:
    ch_versions = Channel.empty()

    ch_parsed_inputs    = inputs.branch {
        it ->
            geneset : it["geneset_version"]
                return [it["analysis_dir"], it["ensembl_species_name"], it["assembly_accession"], it["geneset_version"]]
            repeats : true
                return [it["analysis_dir"], it["ensembl_species_name"], it["assembly_accession"]]
    }

    ENSEMBL_GENESET_DOWNLOAD ( ch_parsed_inputs.geneset )
    ch_versions         = ch_versions.mix(ENSEMBL_GENESET_DOWNLOAD.out.versions)

    ch_all_gene_fasta   = Channel.empty()
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cdna.map { it + ["cdna"] } )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cds.map  { it + ["cds"] }  )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.pep.map  { it + ["pep"] }  )
        .map { [it[0] + [id: [it[0].accession, it[1], it[0].version, it[3]].join("."), method: it[1]], it[2]] }

    ch_gff              = ENSEMBL_GENESET_DOWNLOAD.out.gff.map { [it[0] + [id: [it[0].accession, it[1], it[0].version].join("."), method: it[1]], it[2]] }

    ch_genome_fasta     = ENSEMBL_GENOME_DOWNLOAD ( ch_parsed_inputs.repeats ).fasta
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions)


    emit:
    genome   = ch_genome_fasta           // path: genome.fa
    genes    = ch_all_gene_fasta         // path: (cdna|cds|pep).fa
    gff      = ch_gff                    // path: genes.gff
    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}
