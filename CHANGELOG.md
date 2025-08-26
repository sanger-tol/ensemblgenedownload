# sanger-tol/ensemblgenedownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [[2.0.2](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/2.0.2)] - Vicious Uruk-hai (patch 2) - [2024-12-09]

### Enhancements & fixes

- Remove defaults from lib/Utils.groovy

## [[2.0.1](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/2.0.1)] - Vicious Uruk-hai (patch 1) - [2024-12-05]

### Enhancements & fixes

- Update module versions
- Remove reference to Anaconda repositories

### Software dependencies

Note, since the pipeline is using Nextflow DSL2, each process will be run with its own [Biocontainer](https://biocontainers.pro/#/registry). This means that on occasion it is entirely possible for the pipeline to be using different versions of the same tool. However, the overall software dependency changes compared to the last release have been listed below for reference. Only `Docker` or `Singularity` containers are supported, `conda` is not supported.

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| `Python`   | 3.8.3,3.9.1 | 3.9.1       |
| `samtools` | 1.17        | 1.21        |
| `tabix`    | 1.11        | 1.20        |

## [[2.0.0](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/2.0.0)] – Vicious Uruk-hai – [2024-06-04]

This version supports the new FTP structure of Ensembl

### Enhancements & fixes

- Support for the updated directory structure of the Ensembl FTP
- Relative paths in the sample-sheet are now evaluated from the `--outdir` parameter
- Memory usage rules for `samtools dict`
- Appropriate use of `tabix`'s TBI and CSI indexing, depending on the sequence lengths
- New command-line parameter (`--annotation_method`): required for accessing the files on the Ensembl FTP
- `--outdir` is a _mandatory_ parameter

### Parameters

| Old parameter | New parameter       |
| ------------- | ------------------- |
|               | --annotation_method |

_In the samplesheet_

| Old parameter | New parameter     |
| ------------- | ----------------- |
| species_dir   | outdir            |
|               | annotation_method |
| assembly_name |                   |

> **NB:** Parameter has been **updated** if both old and new parameter information is present. </br> **NB:** Parameter has been **added** if just the new parameter information is present. </br> **NB:** Parameter has been **removed** if new parameter information isn't present.

### Software dependencies

Note, since the pipeline is using Nextflow DSL2, each process will be run with its own [Biocontainer](https://biocontainers.pro/#/registry). This means that on occasion it is entirely possible for the pipeline to be using different versions of the same tool. However, the overall software dependency changes compared to the last release have been listed below for reference. Only `Docker` or `Singularity` containers are supported, `conda` is not supported.

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |
| multiqc    | 1.13        | 1.14        |

## [[1.0.1](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/1.0.1)] – Hefty mûmakil (patch 1) – [2022-10-19]

Minor bugfix update.

### Fixed

- When a samplesheet is provided, do not process the individual command-line parameters

## [[1.0.0](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/1.0.0)] – Hefty mûmakil – [2022-10-07]

Initial release of sanger-tol/ensemblgenedownload, created with the [nf-core](https://nf-co.re/) template.

### Added

- Download from Ensembl
- `samtools faidx` and `samtools dict` indices for the annotation fastas
- tabix index for the GFF3 file

### Dependencies

All dependencies are automatically fetched by Singularity.

- bgzip
- samtools
- tabix
- python3
- wget
- awk
- gzip
