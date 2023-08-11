//
// This file holds several functions specific to the workflow/ensemblgenedownload.nf in the sanger-tol/ensemblgenedownload pipeline
//

import nextflow.Nextflow

class WorkflowEnsemblgenedownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        // Check input has been provided
        if (params.input) {
            def f = new File(params.input);
            if (!f.exists()) {
                Nextflow.error "'${params.input}' doesn't exist"
            }
        } else {
            if (!params.assembly_accession || !params.ensembl_species_name || !params.annotation_method || !params.geneset_version) {
                Nextflow.error "Either --input, or --assembly_accession, --ensembl_species_name, --annotation_method, and --geneset_version must be provided"
            }
        }
        if (!params.outdir) {
            Nextflow.error "--outdir is mandatory"
        }
    }

}
