# ![sanger-tol/ensemblgenedownload](docs/images/sanger-tol-ensemblgenedownload_logo.png)

[![GitHub Actions CI Status](https://github.com/sanger-tol/ensemblgenedownload/workflows/nf-core%20CI/badge.svg)](https://github.com/sanger-tol/ensemblgenedownload/actions?query=workflow%3A%22nf-core+CI%22)

<!-- [![GitHub Actions Linting Status](https://github.com/sanger-tol/ensemblgenedownload/workflows/nf-core%20linting/badge.svg)](https://github.com/sanger-tol/ensemblgenedownload/actions?query=workflow%3A%22nf-core+linting%22) -->

[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.7155206-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.7155206)

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)

[![Get help on Slack](http://img.shields.io/badge/slack-SangerTreeofLife%20%23pipelines-4A154B?labelColor=000000&logo=slack)](https://SangerTreeofLife.slack.com/channels/pipelines)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40sangertol-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/sangertol)
[![Watch on YouTube](http://img.shields.io/badge/youtube-tree--of--life-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/channel/UCFeDpvjU58SA9V0ycRXejhA)

## Introduction

**sanger-tol/ensemblgenedownload** is a pipeline that downloads gene annotations from Ensembl into a Tree of Life directory structure.

The pipeline takes a CSV file that contains assembly accession number, Ensembl species names (as they may differ from Tree of Life ones !), output directories, geneset methods and geneset versions.
Assembly accession numbers are optional. If missing, the pipeline assumes it can be retrieved from files named `ACCESSION` in the standard location on disk.
The pipeline downloads the Fasta files of the genes (cdna, cds, and protein sequences) as well as the GFF3 file.
All files are compressed with `bgzip`, and indexed with `samtools faidx` or `tabix`.

Steps involved:

- Download from Ensembl the GFF3 file, and the sequences of the genes in
  Fasta format.
- Compress and index all Fasta files with `bgzip`, `samtools faidx`, and
  `samtools dict`.
- Compress and index the GFF3 file with `bgzip` and `tabix`.

## Usage

> **Note**
> If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
> to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
> with `-profile test` before running the workflow on actual data.

The easiest is to provide the exact species name and versions of the assembly and annotations like this:

```console
nextflow run sanger-tol/ensemblgenedownload --ensembl_species_name Noctua_fimbriata --assembly_accession GCA_905163415.1 --annotation_method braker --geneset_version 2022_03
```

> **Warning:**
> Please provide pipeline parameters via the CLI or Nextflow `-params-file` option. Custom config files including those
> provided by the `-c` Nextflow option can be used to provide any configuration _**except for parameters**_;
> see [docs](https://nf-co.re/usage/configuration#custom-configuration-files).

The pipeline also supports bulk downloads through a sample-sheet.
More information about this mode on our [pipeline website](https://pipelines.tol.sanger.ac.uk/ensemblgenedownload/usage).

## Credits

sanger-tol/ensemblgenedownload was originally written by [Matthieu Muffato](https://github.com/muffato).

We thank the following people for their assistance in the development of this pipeline:

- [Priyanka Surana](https://github.com/priyanka-surana) for providing reviews.

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#pipelines` channel](https://sangertreeoflife.slack.com/channels/pipelines). Please [create an issue](https://github.com/sanger-tol/ensemblgenedownload/issues/new/choose) on GitHub if you are not on the Sanger slack channel.

## Citations

If you use sanger-tol/ensemblgenedownload for your analysis, please cite it using the following doi: [10.5281/zenodo.7155206](https://doi.org/10.5281/zenodo.7155206)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
