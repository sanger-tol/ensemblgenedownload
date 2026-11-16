# sanger-tol/ensembldownload: Usage

## :warning: Please read this documentation on the nf-core website: [https://pipelines.tol.sanger.ac.uk/ensembldownload/usage](https://pipelines.tol.sanger.ac.uk/ensembldownload/usage)

> _Documentation of pipeline parameters is generated automatically from the pipeline schema and can no longer be found in markdown files._

## Introduction

The pipeline downloads Enembl gene annotations for one of multiple assemblies.
It also builds a set of common indices (such as `samtools faidx`, `tabix`).

## One-off downloads

The pipeline accepts command-one line arguments to specify a single genome to download:

- `--assembly_accession`: The accession number of the assembly,
- `--annotation_method`: The annotation method of the geneset,
- `--geneset_version`: The geneset version to download,
- `--outdir`: Where the pipeline runtime information will be stored, and where data will be downloaded (except if absolute paths are given in the samplesheet).

```bash
nextflow run sanger-tol/ensembldownload -profile singularity --assembly_accession GCA_905163415.1 --annotation_method braker --geneset_version 2022_03 --outdir Noctua_fimbriata_braker_2022_03
```

This will launch the pipeline and download the `2022_03` _Braker_ annotation of the assembly `GCA_905163415.1` into the `Noctua_fimbriata_braker_2022_03/` directory,
which will be created if needed.

Annotation parameters can be retrieved by browsing the [Ensembl](https://www.ensembl.org/) site.

- Go to the assembly page <https://www.ensembl.org/genome/GCA_905163415.1>
  and click on the "Get files" button on the right-hand side.
- From the URL of any link, e.g. `https://ftp.ebi.ac.uk/pub/ensemblorganisms/GCA/905/163/415/1/braker/2022_03/genome`,
  extract the annotation method and version.

Current annotation represent pipelines:

- `ensembl` for Ensembl's own annotation pipeline
- `braker` for the [BRAKER2](https://academic.oup.com/nargab/article/3/1/lqaa108/6066535) pipeline
- `helixer` for the [Helixer](https://doi.org/10.1038/s41592-025-02939-1) pipeline
- `prokka` for the [Prokka](https://academic.oup.com/bioinformatics/article-lookup/doi/10.1093/bioinformatics/btu153) pipeline

or source databases the annotation is loaded from:

- `refseq` for [RefSeq](https://academic.oup.com/nar/article/49/D1/D1020/6018440)
- `flybase` for [FlyBase](https://academic.oup.com/genetics/article-lookup/doi/10.1093/genetics/iyad211)
- `genbank` for [GenBank](https://academic.oup.com/nar/article-lookup/doi/10.1093/nar/gkab1135)
- `veupathdb` for [VEuPathDB](https://academic.oup.com/nar/article-lookup/doi/10.1093/nar/gkad1003)
- `wormbase` for [WormBase](https://academic.oup.com/genetics/article-lookup/doi/10.1093/genetics/iyae050)
- `community` and many `community_*` strings for other annotations pulled from the community

## Bulk download

The pipeline can download multiple genesets at once, by providing them in a `.csv` file through the `--input` parameter.
It has to be a comma-separated file with four columns, and a header row as shown in the examples below.

```csv title="samplesheet.csv"
outdir,assembly_accession,annotation_method,geneset_version
Asterias_rubens/eAstRub1.3,GCA_902459465.3,ensembl,2020_11
Osmia_bicornis/iOsmBic2.1_alternate_haplotype,GCA_907164925.1,ensembl,2022_02
Noctua_fimbriata/ilNocFimb1.1,GCA_905163415.1,braker,2022_03
```

| Column               | Description                                                                                                                                                               |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `outdir`             | Output directory for this annotation (evaluated from `--outdir` if a relative path). Analysis results are in a sub-directory `genes/$annotation_method/$geneset_version`. |
| `assembly_accession` | Accession number of the assembly to download. Typically of the form `GCA_*.*`.                                                                                            |
| `annotation_method`  | Name of the method of the geneset.                                                                                                                                        |
| `geneset_version`    | Version of the geneset, usually in the form `YYYY_MM`.                                                                                                                    |

A samplesheet may contain:

- multiple genesets of the same species
- multiple genesets of the same assembly
- multiple genesets in the same output directory
- only one row per geneset

All samplesheet columns correspond exactly to their corresponding command-line parameter,
except `outdir` which, if a relative path, is interpreted under `--oudir`.

An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline.

```bash
nextflow run sanger-tol/ensembldownload --input ./samplesheet.csv --outdir ./results  -profile docker
```

## Nextflow outputs

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> [!WARNING]
> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/running/run-pipelines#configuring-pipelines), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run sanger-tol/ensembldownload -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
assembly_accession: "GCA_905163415.1"
annotation_method: "braker"
geneset_version: "2022_03"
outdir: "./results/"
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull sanger-tol/ensembldownload
```

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [sanger-tol/ensembldownload releases page](https://github.com/sanger-tol/ensembldownload/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://charliecloud.io/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow `24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.
- `test`
  - A profile with a minimal configuration for automated testing
  - Corresponds to defining the assembly to download as command-line parameters so needs no other parameters
- `test_full`
  - A profile with a complete configuration for automated testing
  - Corresponds to defining the assembly to download as a CSV file so needs no other parameters

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

## Custom configuration

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/running/configuration/nextflow-for-your-system#set-max-resources) and [customise process resources](https://nf-co.re/docs/running/configuration/nextflow-for-your-system#customize-process-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. By default, nf-core pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/running/configuration/nextflow-for-your-system#update-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, nf-core pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/running/configuration/nextflow-for-your-system#modifying-tool-arguments) section of the nf-core website.

### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organisation are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
