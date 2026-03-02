//
// Download all files from Ensembl and prepare clean output channels for post-processing
//

include { ENSEMBL_GENESET_DOWNLOAD } from '../../modules/local/ensembl_geneset_download'


workflow DOWNLOAD {
    take:
    annotation_params // tuple(outdir, assembly_accession, ensembl_species_name, annotation_method, geneset_version)

    main:

    ENSEMBL_GENESET_DOWNLOAD(
        annotation_params.map { outdir, assembly_accession, ensembl_species_name, annotation_method, geneset_version ->
            [
                // meta
                [
                    assembly_accession: assembly_accession,
                    geneset_version: geneset_version,
                    method: annotation_method,
                    outdir: outdir,
                ],

                // e.g. https://ftp.ensembl.org/pub/rapid-release/species/Agriopis_aurantiaria/GCA_914767915.1/braker/geneset/2021_12/Agriopis_aurantiaria-GCA_914767915.1-2021_12-cdna.fa.gz
                // ftp_path
                [
                    params.ftp_root,
                    ensembl_species_name,
                    assembly_accession,
                    annotation_method,
                    "geneset",
                    geneset_version,
                ].join("/"),

                // remote_filename_stem
                [
                    ensembl_species_name,
                    assembly_accession,
                    geneset_version,
                ].join("-"),
            ]
        }
    )

    // Set meta.id
    ch_all_gene_fasta = channel.empty()
        .mix(ENSEMBL_GENESET_DOWNLOAD.out.cdna.map { meta, file -> [meta, file, "cdna"] })
        .mix(ENSEMBL_GENESET_DOWNLOAD.out.cds.map { meta, file -> [meta, file, "cds"] })
        .mix(ENSEMBL_GENESET_DOWNLOAD.out.pep.map { meta, file -> [meta, file, "pep"] })
        .map { meta, fasta, type ->
            [
                meta + [
                    id: [meta.assembly_accession, meta.method, meta.geneset_version, type].join(".")
                ],
                fasta,
            ]
        }

    // tuple(meta,gff) at this stage
    ch_gff = ENSEMBL_GENESET_DOWNLOAD.out.gff.map { meta, gff ->
        [
            meta + [
                id: [meta.assembly_accession, meta.method, meta.geneset_version].join(".")
            ],
            gff,
        ]
    }

    emit:
    genes    = ch_all_gene_fasta // path: (cdna|cds|pep).fa
    gff      = ch_gff // path: genes.gff
}
