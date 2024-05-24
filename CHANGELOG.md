# sanger-tol/ensemblgenedownload: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [[2.0.0](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/2.0.0)] – Vicious Uruk-hai – [2024-05-24]

### `Fixed`

- Support for the updated directory structure of the Ensembl FTP
- Relative paths in the sample-sheet are now evaluated from the `--outdir` parameter
- Memory usage rules for `samtools dict`
- Appropriate use of `tabix`'s TBI and CSI indexing, depending on the sequence lengths

### `Added`

- New command-line parameter (`--annotation_method`): required for accessing the files on the Ensembl FTP
- `--outdir` is a _mandatory_ parameter

## [[1.0.1](https://github.com/sanger-tol/ensemblgenedownload/releases/tag/1.0.1)] [2022-10-19]

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
