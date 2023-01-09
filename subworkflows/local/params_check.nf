//
// Check and parse the input parameters
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow PARAMS_CHECK {

    take:
    samplesheet  // file
    cli_params   // tuple, see below
    outdir       // file output directory


    main:
    ch_versions = Channel.empty()

    ch_inputs = Channel.empty()
    if (samplesheet) {
        SAMPLESHEET_CHECK ( file(samplesheet, checkIfExists: true) )
            .csv
            // Provides species_dir, assembly_name, assembly_accession (optional), ensembl_species_name, annotation_method, and geneset_version
            .splitCsv ( header:true, sep:',' )
            .map {
                // If assembly_accession is missing, load the accession number from file, following the Tree of Life directory structure
                it["assembly_accession"] ? it : it + [
                    assembly_accession: file("${it["species_dir"]}/assembly/release/${it["assembly_name"]}/insdc/ACCESSION", checkIfExists: true).text.trim(),
                ]
            }
            // Convert to tuple, as required by the download subworkflow
            .map { [
                (it["species_dir"].startsWith("/") ? "" : outdir + "/") + "${it["species_dir"]}/analysis/${it["assembly_name"]}",
                it["ensembl_species_name"],
                it["assembly_accession"],
                it["annotation_method"],
                it["geneset_version"],
            ] }
            .set { ch_inputs }

        ch_versions = ch_versions.mix(SAMPLESHEET_CHECK.out.versions)

    } else {
        // Add the other input channel in, as it's expected to have all the parameters in the right order
        ch_inputs = ch_inputs.mix(cli_params.map { [outdir] + it } )
    }

    emit:
    ensembl_params  = ch_inputs        // tuple(analysis_dir, ensembl_species_name, assembly_accession, annotation_method, geneset_version)
    versions        = ch_versions      // channel: versions.yml
}

