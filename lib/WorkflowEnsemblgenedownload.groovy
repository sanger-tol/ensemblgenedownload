//
// This file holds several functions specific to the workflow/ensemblgenedownload.nf in the sanger-tol/ensemblgenedownload pipeline
//

class WorkflowEnsemblgenedownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {

        // Check input has been provided
        if (params.input) {
            def f = new File(params.input);
            if (!f.exists()) {
                log.error "'${params.input}' doesn't exist"
                System.exit(1)
            }
        } else {
            if (!params.assembly_accession || !params.assembly_name || !params.outdir) {
                log.error "Either --input, or --assembly_accession, --assembly_name, and --outdir must be provided"
                System.exit(1)
            }
        }
    }

}
