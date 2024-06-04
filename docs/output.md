# sanger-tol/ensemblgenedownload: Output

## Introduction

This document describes the output produced by the pipeline.

The directories listed below will be created in a directory based on the `--outdir` command-line parameter and the `outdir` column of the samplesheet.
) after the pipeline has finished.
All paths are relative to the top-level results directory.

The directories comply with Tree of Life's canonical directory structure.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Gene annotation files](#gene-annotation-files) - Annotation files, either straight from the Ensembl FTP, or indices built on them
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

All data files are compressed (and indexed) with `bgzip`.

All Fasta files are indexed with `samtools faidx`, which allows accessing any region of the assembly in constant time, and `samtools dict`, which allows identifying a sequence by its MD5 checksum.

All BED files are indexed with tabix in both TBI and CSI modes, unless the sequences are too large.

### Gene annotation files

Here are the files you can expect in the `gene/` sub-directory.

```text
gene
└── ensembl
    └── 2022_02
        ├── GCA_907164925.1.ensembl.2022_02.cdna.fa.gz
        ├── GCA_907164925.1.ensembl.2022_02.cdna.fa.gz.dict
        ├── GCA_907164925.1.ensembl.2022_02.cdna.fa.gz.fai
        ├── GCA_907164925.1.ensembl.2022_02.cdna.fa.gz.gzi
        ├── GCA_907164925.1.ensembl.2022_02.cdna.fa.gz.sizes
        ├── GCA_907164925.1.ensembl.2022_02.cds.fa.gz
        ├── GCA_907164925.1.ensembl.2022_02.cds.fa.gz.dict
        ├── GCA_907164925.1.ensembl.2022_02.cds.fa.gz.fai
        ├── GCA_907164925.1.ensembl.2022_02.cds.fa.gz.gzi
        ├── GCA_907164925.1.ensembl.2022_02.cds.fa.gz.sizes
        ├── GCA_907164925.1.ensembl.2022_02.gff3.gz
        ├── GCA_907164925.1.ensembl.2022_02.gff3.gz.csi
        ├── GCA_907164925.1.ensembl.2022_02.gff3.gz.gzi
        ├── GCA_907164925.1.ensembl.2022_02.gff3.gz.tbi
        ├── GCA_907164925.1.ensembl.2022_02.pep.fa.gz
        ├── GCA_907164925.1.ensembl.2022_02.pep.fa.gz.dict
        ├── GCA_907164925.1.ensembl.2022_02.pep.fa.gz.fai
        ├── GCA_907164925.1.ensembl.2022_02.pep.fa.gz.gzi
        └── GCA_907164925.1.ensembl.2022_02.pep.fa.gz.sizes
```

All files are named after:

- the assembly accession, e.g. `GCA_907164925.1`;
- the annotation method, e.g. `ensembl`;
- the annotation date, e.g. `2022_02`.

These information are also in the directory names to allow multiple annotations to be loaded.

The `.seq_length.tsv` files are tabular analogous to the common `chrom.sizes`. They contain the sequence names and their lengths.

_The following documentation is copied from Ensembl's FTP_

#### Fasta files

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

#### GFF3 file

A GFF3 ([specification](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md)) file is also provided.
GFF3 files are validated using [GenomeTools](http://genometools.org).

The 'type' of gene features is:

- `gene` for protein-coding genes
- `ncRNA_gene` for RNA genes
- `pseudogene` for pseudogenes

The 'type' of transcript features is:

- `mRNA` for protein-coding transcripts
- a specific type or RNA transcript such as `snoRNA` or `lnc_RNA`
- `pseudogenic_transcript` for pseudogenes

All transcripts are linked to `exon` features.
Protein-coding transcripts are linked to `CDS`, `five_prime_UTR`, and
`three_prime_UTR` features.

Attributes for feature types:
(italics indicate data which is not available for all features)

- region types:
  - `ID`: Unique identifier, format `<region_type>:<region_name>`
  - _`Alias`_: A comma-separated list of aliases, usually including the
    `INSDC` accession
  - _`Is_circular`_: Flag to indicate circular regions
- gene types:
  - `ID`: Unique identifier, format `gene:<gene_stable_id>`
  - `biotype`: Ensembl biotype, e.g. `protein_coding`, `pseudogene`
  - `gene_id`: Ensembl gene stable ID
  - `version`: Ensembl gene version
  - _`Name`_: Gene name
  - _`description`_: Gene description
- transcript types:
  - `ID`: Unique identifier, format `transcript:<transcript_stable_id>`
  - `Parent`: Gene identifier, format `gene:<gene_stable_id>`
  - `biotype`: Ensembl biotype, e.g. `protein_coding`, `pseudogene`
  - `transcript_id`: Ensembl transcript stable ID
  - `version`: Ensembl transcript version
  - _`Note`_: If the transcript sequence has been edited (i.e. differs
    from the genomic sequence), the edits are described in a note.
- exon
  - `Parent`: Transcript identifier, format `transcript:<transcript_stable_id>`
  - `exon_id`: Ensembl exon stable ID
  - `version`: Ensembl exon version
  - `constitutive`: Flag to indicate if exon is present in all
    transcripts
  - `rank`: Integer that show the 5'->3' ordering of exons
- CDS
  - `ID`: Unique identifier, format `CDS:<protein_stable_id>`
  - `Parent`: Transcript identifier, format `transcript:<transcript_stable_id>`
  - `protein_id`: Ensembl protein stable ID
  - `version`: Ensembl protein version

### Pipeline information

- `pipeline_info/ensemblgenedownload/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
