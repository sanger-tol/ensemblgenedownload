/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowEnsembldownload.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { ENSEMBL_GENESET_DOWNLOAD      } from '../modules/local/ensembl_geneset_download'
include { ENSEMBL_GENOME_DOWNLOAD       } from '../modules/local/ensembl_genome_download'
include { SAMPLESHEET_CHECK             } from '../modules/local/samplesheet_check'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { PREPARE_GENOME                } from '../subworkflows/local/prepare_genome'
include { PREPARE_REPEATS               } from '../subworkflows/local/prepare_repeats'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ENSEMBLDOWNLOAD {

    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (params.input) {

        SAMPLESHEET_CHECK ( file(params.input, checkIfExists: true) )
            .csv
            .splitCsv ( header:true, sep:',' )
            .set { ch_inputs }

    } else {

        ch_inputs = Channel.from( [
            [assembly_accession:params.assembly_accession, assembly_name:params.assembly_name]
        ] )

    }

    ch_inputs.branch {
        it ->
            geneset : it["geneset_version"]
                return [it["ensembl_species_name"], it["assembly_accession"], it["geneset_version"]]
            repeats : true
                return [it["ensembl_species_name"], it["assembly_accession"]]
    }
    .set { ch_parsed_inputs }

    ENSEMBL_GENOME_DOWNLOAD ( ch_parsed_inputs.repeats )
    ENSEMBL_GENESET_DOWNLOAD ( ch_parsed_inputs.geneset )
    ch_versions         = ch_versions.mix(ENSEMBL_GENOME_DOWNLOAD.out.versions)
    ch_versions         = ch_versions.mix(ENSEMBL_GENESET_DOWNLOAD.out.versions)

    ch_all_fasta        = Channel.empty()
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cdna.map { [it[0] + [id: it[0].id + ".cdna"], it[1]] } )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.cds.map { [it[0] + [id: it[0].id + ".cds"], it[1]] } )
        .mix( ENSEMBL_GENESET_DOWNLOAD.out.pep.map { [it[0] + [id: it[0].id + ".pep"], it[1]] } )

    // Preparation of Fasta files
    PREPARE_GENOME (
        ch_all_fasta
    )
    ch_versions         = ch_versions.mix(PREPARE_GENOME.out.versions)

    // Preparation of repeat-masking files
    PREPARE_REPEATS (
        ENSEMBL_GENOME_DOWNLOAD.out.fasta
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEATS.out.versions)

    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.summary(workflow, params, log)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
