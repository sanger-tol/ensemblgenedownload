//
// This file holds several functions specific to the workflow/ensemblgenedownload.nf in the sanger-tol/ensemblgenedownload pipeline
//

class WorkflowEnsemblgenedownload {

    //
    // Check and validate parameters
    //
    public static void initialise(params, log) {
        

        if (!params.fasta) {
            log.error "Genome fasta file not specified with e.g. '--fasta genome.fa' or via a detectable config file."
            System.exit(1)
        }
    }

}
