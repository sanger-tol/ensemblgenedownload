#!/usr/bin/env python


"""Provide a command line tool to validate and transform tabular samplesheets."""


import argparse
import csv
import logging
import re
import sys
from collections import Counter
from pathlib import Path

logger = logging.getLogger()


class RowChecker:
    """
    Define a service that can validate and transform each given row.

    Attributes:
        modified (list): A list of dicts, where each dict corresponds to a previously
            validated and transformed row. The order of rows is maintained.

    """

    def __init__(
        self,
        accession_col="assembly_accession",
        name_col="assembly_name",
        dir_col="species_dir",
        ensembl_name_col="ensembl_species_name",
        geneset_col="geneset_version",
        **kwargs,
    ):
        """
        Initialize the row checker with the expected column names.

        Args:
            accession_col (str): The name of the column that contains the accession
                number (default "assembly_accession").
            name_col (str): The name of the column that contains the assembly name
                (default "assembly_name").
            dir_col (str): The name of the column that contains the species directory
                (default "species_dir").
            ensembl_name_col(str): The name of the column that contains the Ensembl species name
                (default "ensembl_species_name").
            geneset_col (str): The name of the column that contains the geneset version
                (default "geneset_version").

        """
        super().__init__(**kwargs)
        self._accession_col = accession_col
        self._name_col = name_col
        self._dir_col = dir_col
        self._ensembl_name_col = ensembl_name_col
        self._geneset_col = geneset_col
        self._seen = set()
        self.modified = []
        self._regex_accession = re.compile(r"^GCA_[0-9]{9}\.[0-9]+$")
        self._regex_geneset = re.compile(r"^20[0-9]{2}_[01][0-9]$")

    def validate_and_transform(self, row):
        """
        Perform all validations on the given row and insert the read pairing status.

        Args:
            row (dict): A mapping from column headers (keys) to elements of that row
                (values).

        """
        self._validate_accession(row)
        self._validate_name(row)
        self._validate_dir(row)
        self._validate_ensembl_name(row)
        self._validate_geneset(row)
        self._seen.add( (row[self._accession_col], row[self._geneset_col]) )
        self.modified.append(row)

    def _validate_accession(self, row):
        """Assert that the accession number exists and matches the expected nomenclature."""
        assert len(row[self._accession_col]) > 0, "Accession number is required."
        assert self._regex_accession.match(row[self._accession_col]), "Accession numbers must match %s." % self._regex_accession

    def _validate_name(self, row):
        """Assert that the assembly name is non-empty and has no space."""
        assert len(row[self._name_col]) > 0, "Accession name is required."
        assert " " not in row[self._name_col], "Accession name must not contain whitespace."

    def _validate_dir(self, row):
        """Assert that the species directory is non-empty."""
        assert len(row[self._dir_col]) > 0, "Species directory is required."

    def _validate_ensembl_name(self, row):
        """Assert that the Ensembl name is non-empty and has no space."""
        assert len(row[self._ensembl_name_col]) > 0, "Ensembl name is required."
        assert " " not in row[self._name_col], "Ensembl name must not contain whitespace."

    def _validate_geneset(self, row):
        """Assert that the geneset version is either empty or matches the expected nomenclature."""
        if len(row[self._geneset_col]) > 0:
            assert self._regex_geneset.match(row[self._geneset_col]), "Geneset versions must match %s." % self._regex_geneset

    def validate_unique_samples(self):
        """
        Assert that the sample identifiers are unique.
        """
        assert len(self._seen) == len(self.modified), "The pair of sample name and FASTQ must be unique."


def read_head(handle, num_lines=10):
    """Read the specified number of lines from the current position in the file."""
    lines = []
    for idx, line in enumerate(handle):
        if idx == num_lines:
            break
        lines.append(line)
    return "".join(lines)


def sniff_format(handle):
    """
    Detect the tabular format.

    Args:
        handle (text file): A handle to a `text file`_ object. The read position is
        expected to be at the beginning (index 0).

    Returns:
        csv.Dialect: The detected tabular format.

    .. _text file:
        https://docs.python.org/3/glossary.html#term-text-file

    """
    peek = read_head(handle)
    handle.seek(0)
    sniffer = csv.Sniffer()
    if not sniffer.has_header(peek):
        logger.critical(f"The given sample sheet does not appear to contain a header.")
        sys.exit(1)
    dialect = sniffer.sniff(peek)
    return dialect


def check_samplesheet(file_in, file_out):
    """
    Check that the tabular samplesheet has the structure expected by the pipeline.

    Validate the general shape of the table, expected columns, and each row.

    Args:
        file_in (pathlib.Path): The given tabular samplesheet. The format can be either
            CSV, TSV, or any other format automatically recognized by ``csv.Sniffer``.
        file_out (pathlib.Path): Where the validated and transformed samplesheet should
            be created; always in CSV format.

    Example:
        This function checks that the samplesheet follows the following structure::

            assembly_accession,assembly_name,species_dir,ensembl_species_name,geneset_version
            GCA_905163415.1,ilNocFimb1.1,/lustre/scratch124/tol/projects/darwin/data/insects/Noctua_fimbriata,Noctua_fimbriata,2022_03
            GCA_902459465.3,eAstRub1.3,/lustre/scratch124/tol/projects/25g/data/echinoderms/Asterias_rubens,Asterias_rubens,

    """
    required_columns = {"assembly_accession", "assembly_name", "species_dir", "ensembl_species_name", "geneset_version"}
    # See https://docs.python.org/3.9/library/csv.html#id3 to read up on `newline=""`.
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle, dialect=sniff_format(in_handle))
        # Validate the existence of the expected header columns.
        if not required_columns.issubset(reader.fieldnames):
            logger.critical(f"The sample sheet **must** contain the column headers: {', '.join(required_columns)}.")
            sys.exit(1)
        # Validate each row.
        checker = RowChecker()
        for i, row in enumerate(reader):
            try:
                checker.validate_and_transform(row)
            except AssertionError as error:
                logger.critical(f"{str(error)} On line {i + 2}.")
                sys.exit(1)
        checker.validate_unique_samples()
    header = list(reader.fieldnames)
    # See https://docs.python.org/3.9/library/csv.html#id3 to read up on `newline=""`.
    with file_out.open(mode="w", newline="") as out_handle:
        writer = csv.DictWriter(out_handle, header, delimiter=",")
        writer.writeheader()
        for row in checker.modified:
            writer.writerow(row)


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a tabular samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument(
        "file_in",
        metavar="FILE_IN",
        type=Path,
        help="Tabular input samplesheet in CSV or TSV format.",
    )
    parser.add_argument(
        "file_out",
        metavar="FILE_OUT",
        type=Path,
        help="Transformed output samplesheet in CSV format.",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"The given input file {args.file_in} was not found!")
        sys.exit(2)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_samplesheet(args.file_in, args.file_out)


if __name__ == "__main__":
    sys.exit(main())
