# sanger-tol/ensembldownload: Output

## Introduction

This document describes the output produced by the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

The directories comply with Tree of Life's canonical directory structure.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Gene annotation files](#gene-annotation-files) - Assembly files, either straight from the NCBI FTP, or indices built on them
- [Repeat annotation files](#repeat-annotation-files) - Files corresponding to analyses run (by the NCBI) on the original assembly, e.g repeat masking
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### Gene annotation files

Here are the files you can expect in the `gene/` sub-directory.

```text
/lustre/scratch124/tol/projects/vgp/data/fish/Parambassis_ranga/
└── analysis
    └── fParRan2.2
        └── gene
            └── ensembl
                ├── GCA_900634625.2.ensembl.2020_09.cdna.fa.gz
                ├── GCA_900634625.2.ensembl.2020_09.cdna.fa.gz.dict
                ├── GCA_900634625.2.ensembl.2020_09.cdna.fa.gz.gzi
                ├── GCA_900634625.2.ensembl.2020_09.cds.fa.gz
                ├── GCA_900634625.2.ensembl.2020_09.cds.fa.gz.dict
                ├── GCA_900634625.2.ensembl.2020_09.cds.fa.gz.gzi
                ├── GCA_900634625.2.ensembl.2020_09.pep.fa.gz
                ├── GCA_900634625.2.ensembl.2020_09.pep.fa.gz.dict
                └── GCA_900634625.2.ensembl.2020_09.pep.fa.gz.gzi
```

The directory structure includes the assembly name, e.g. `fParRan2.2`, and all files are named after the assembly accession, e.g. `GCA_900634625.2`.
The file name (and the directory name) includes the annotation method and date. Current methods are:

- `braker2` for [BRAKER2](https://academic.oup.com/nargab/article/3/1/lqaa108/6066535)
- `ensembl` for Ensembl's own annotation pipeline

_The following documentation is copied from Ensembl's FTP_

Ensembl provide gene sequences in FASTA format in three files. The 'cdna' file contains
transcript sequences for all types of gene (including, for example,
pseudogenes and RNA genes). The 'cds' file contains the DNA sequences
of the coding regions of protein-coding genes. The 'pep' file contains
the amino acid sequences of protein-coding genes.

The headers in the 'cdna' FASTA files have the format:

```text
><transcript_stable_id> <seq_type> <assembly_name>:<seq_name>:<start>:<end>:<strand> gene:<gene_stable_id> gene_biotype:<gene_biotype> transcript_biotype:<transcript_biotype> [gene_symbol:<gene_symbol>] [description:<description>]
```

Example 'cdna' header:

```text
>ENSZVIT00000000002.1 cdna UG_Zviv_1:LG1:3600:22235:-1 gene:ENSZVIG00000000002.1 gene_biotype:protein_coding transcript_biotype:protein_coding
```

The headers in the 'cds' FASTA files have the format:

```text
><transcript_stable_id> <seq_type> <assembly_name>:<seq_name>:<coding_start>:<coding_end>:<strand> gene:<gene_stable_id> gene_biotype:<gene_biotype> transcript_biotype:<transcript_biotype> [gene_symbol:<gene_symbol>] [description:<description>]
```

Example 'cds' header:

```text
>ENSZVIT00000000002.1 cds UG_Zviv_1:LG1:5289:19862:-1 gene:ENSZVIG00000000002.1 gene_biotype:protein_coding transcript_biotype:protein_coding
```

The headers in the 'pep' FASTA files have the format:

```text
><protein_stable_id> <seq_type> <assembly_name>:<seq_name>:<coding_start>:<coding_end>:<strand> gene:<gene_stable_id> transcript:<transcript_stable_id> gene_biotype:<gene_biotype> transcript_biotype:<transcript_biotype> [gene_symbol:<gene_symbol>] [description:<description>]
```

Example 'pep' header:

```text
>ENSZVIP00000000002.1 pep UG_Zviv_1:LG1:5289:19862:-1 gene:ENSZVIG00000000002.1 transcript:ENSZVIT00000000002.1 gene_biotype:protein_coding transcript_biotype:protein_coding
```

Stable IDs for genes, transcripts, and proteins include a version
suffix. Gene symbols and descriptions are not available for all genes.

A GFF3 ([specification](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md)) file is also provided.
GFF3 files are validated using [GenomeTools](http://genometools.org).

The 'type' of gene features is:

- "gene" for protein-coding genes
- "ncRNA_gene" for RNA genes
- "pseudogene" for pseudogenes

The 'type' of transcript features is:

- "mRNA" for protein-coding transcripts
- a specific type or RNA transcript such as "snoRNA" or "lnc_RNA"
- "pseudogenic_transcript" for pseudogenes

All transcripts are linked to "exon" features.
Protein-coding transcripts are linked to "CDS", "five_prime_UTR", and
"three_prime_UTR" features.

Attributes for feature types:
(square brackets indicate data which is not available for all features)

- region types:
  - ID: Unique identifier, format "<region_type>:<region_name>"
  - [Alias]: A comma-separated list of aliases, usually including the
      INSDC accession
  - [Is_circular]: Flag to indicate circular regions
- gene types:
  - ID: Unique identifier, format "gene:<gene_stable_id>"
  - biotype: Ensembl biotype, e.g. "protein_coding", "pseudogene"
  - gene_id: Ensembl gene stable ID
  - version: Ensembl gene version
  - [Name]: Gene name
  - [description]: Gene description
- transcript types:
  - ID: Unique identifier, format "transcript:<transcript_stable_id>"
  - Parent: Gene identifier, format "gene:<gene_stable_id>"
  - biotype: Ensembl biotype, e.g. "protein_coding", "pseudogene"
  - transcript_id: Ensembl transcript stable ID
  - version: Ensembl transcript version
  - [Note]: If the transcript sequence has been edited (i.e. differs
      from the genomic sequence), the edits are described in a note.
- exon
  - Parent: Transcript identifier, format "transcript:<transcript_stable_id>"
  - exon_id: Ensembl exon stable ID
  - version: Ensembl exon version
  - constitutive: Flag to indicate if exon is present in all
      transcripts
  - rank: Integer that show the 5'->3' ordering of exons
- CDS
  - ID: Unique identifier, format "CDS:<protein_stable_id>"
  - Parent: Transcript identifier, format "transcript:<transcript_stable_id>"
  - protein_id: Ensembl protein stable ID
  - version: Ensembl protein version

### Repeat annotation files

Here are the files you can expect in the `repeats/` sub-directory.

```text
analysis
└── gfLaeSulp1.1
    └── repeats
        └── ncbi
            ├── GCA_927399515.1.masked.ncbi.bed.gz
            ├── GCA_927399515.1.masked.ncbi.bed.gz.gzi
            ├── GCA_927399515.1.masked.ncbi.bed.gz.tbi
            ├── GCA_927399515.1.masked.ncbi.fasta.dict
            ├── GCA_927399515.1.masked.ncbi.fasta.gz
            ├── GCA_927399515.1.masked.ncbi.fasta.gz.fai
            └── GCA_927399515.1.masked.ncbi.fasta.gz.gzi
```

They all correspond to the repeat-masking analysis run by Ensembl themselves. Like for the `assembly/` sub-directory,
the directory structure includes the assembly name, e.g. `gfLaeSulp1.1`, and all files are named after the assembly accession, e.g. `GCA_927399515.1`.

- `GCA_*.masked.ncbi.fasta.gz`: Masked assembly in Fasta format, compressed with `bgzip` (whose index is `GCA_*.fasta.gz.gzi`)
- `GCA_*.masked.ncbi.fasta.gz.fai`: `samtools faidx` index, which allows accessing any region of the assembly in constant time
- `GCA_*.masked.ncbi.fasta.dict`: `samtools dict` index, which allows identifying a sequence by its MD5 checksum
- `GCA_*.masked.ncbi.bed.gz`: BED file with the coordinates of the regions masked by the NCBI pipeline, with accompanying `bgzip` and `tabix` indices (resp. `.gzi` and `.tbi`)

_The following documentation is copied from Ensembl's FTP_

### Pipeline information

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
