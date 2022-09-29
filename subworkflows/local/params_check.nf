//
// Check and parse the input parameters
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow PARAMS_CHECK {

    take:
    inputs


    main:

    def (samplesheet, assembly_accession, ensembl_species_name, geneset_version, outdir) = inputs

    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (samplesheet) {

        SAMPLESHEET_CHECK ( file(samplesheet, checkIfExists: true) )
            .csv
            // Provides species_dir, assembly_name, assembly_accession (optional), ensembl_species_name, and geneset_version
            .splitCsv ( header:true, sep:',' )
            // Add analysis_dir, following the Tree of Life directory structure
            .map {
                it + [
                    analysis_dir: "${it["species_dir"]}/analysis/${it["assembly_name"]}",
                    ]
            }
            .branch {
                it ->
                    // Check if there is an assembly_accession in the samplesheet
                    with_accession: it["assembly_accession"]
                    without_accession : true
            }
            .set { ch_samplesheet }

            // If assembly_accession is missing:
            // Load the accession number from file, following the Tree of Life directory structure
            ch_samplesheet.with_accession.mix( ch_samplesheet.without_accession.map {
                it + [
                    assembly_accession: file("${it["species_dir"]}/assembly/release/${it["assembly_name"]}/insdc/ACCESSION", checkIfExists: true).text.trim(),
                    ]
            } )
            // Convert to tuple, as required by the download subworkflow
            .map { [
                it["analysis_dir"],
                it["ensembl_species_name"],
                it["assembly_accession"],
                it["geneset_version"],
            ] }
            .set { ch_inputs }

        ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions.first())

    } else {

        ch_inputs = Channel.of(
            [
                params.outdir,
                params.ensembl_species_name,
                params.assembly_accession,
                params.geneset_version,
            ]
        )

    }


    emit:
    ensembl_params  = ch_inputs        // tuple(analysis_dir, ensembl_species_name, assembly_accession, geneset_version)
    versions        = ch_versions      // channel: versions.yml
}

