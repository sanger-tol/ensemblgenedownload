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

include { SAMPLESHEET_CHECK             } from '../modules/local/samplesheet_check'

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { DOWNLOAD                                     } from '../subworkflows/local/download'
include { PREPARE_FASTA as PREPARE_GENES_FASTA         } from '../subworkflows/sanger-tol/prepare_fasta'
include { PREPARE_FASTA as PREPARE_REPEAT_MASKED_FASTA } from '../subworkflows/sanger-tol/prepare_fasta'
include { PREPARE_GFF                                  } from '../subworkflows/local/prepare_gff'
include { PREPARE_REPEATS                              } from '../subworkflows/sanger-tol/prepare_repeats'

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
            // Provides species_dir, assembly_name, ensembl_species_name, and geneset_version
            .splitCsv ( header:true, sep:',' )
            // Add analysis_dir, and load the accession number, following the Tree of Life directory structure
            .map {
                it + [
                    assembly_accession: file("${it["species_dir"]}/assembly/release/${it["assembly_name"]}/insdc/ACCESSION", checkIfExists: true).text.trim(),
                    analysis_dir: "${it["species_dir"]}/analysis/${it["assembly_name"]}",
                    ]
            }
            .set { ch_inputs }

    } else if (params.geneset_version) {

        ch_inputs = Channel.from( [
            [
                analysis_dir: params.outdir,
                assembly_accession: params.assembly_accession,
                ensembl_species_name: params.ensembl_species_name,
                geneset_version: params.geneset_version,
            ]
        ] )

    } else {

        ch_inputs = Channel.from( [
            [
                analysis_dir: params.outdir,
                assembly_accession: params.assembly_accession,
                ensembl_species_name: params.ensembl_species_name,
            ]
        ] )

    }

    // Actual download
    DOWNLOAD (
        ch_inputs
    )
    ch_versions         = ch_versions.mix(DOWNLOAD.out.versions)

    // Preparation of Fasta files
    PREPARE_GENES_FASTA (
        DOWNLOAD.out.genes
    )
    ch_versions         = ch_versions.mix(PREPARE_GENES_FASTA.out.versions)

    // Preparation of GFF files
    PREPARE_GFF (
        DOWNLOAD.out.gff
    )
    ch_versions         = ch_versions.mix(PREPARE_GFF.out.versions)

    // Preparation of repeat-masking files
    PREPARE_REPEAT_MASKED_FASTA (
        DOWNLOAD.out.genome
    )
    ch_versions         = ch_versions.mix(PREPARE_REPEAT_MASKED_FASTA.out.versions)
    PREPARE_REPEATS (
        DOWNLOAD.out.genome
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
