#!/usr/bin/env python3

import sys

# This script will generate a BED file of the masked regions a fasta file.
in_gap = None
with open(sys.argv[1]) as fh:
    for line in fh:
        line = line[:-1]
        if line.startswith(">"):
            if in_gap:
                print("\t".join([chrom, str(start), str(i)]))
                in_gap = False
            i = 0  # Start coordinate is 0-based, included
            chrom = line.split()[0][1:]
        else:
            for char in line:
                if not in_gap and char.islower():
                    in_gap = True
                    start = i
                elif in_gap and char.isupper():
                    in_gap = False
                    # end coordinate is 0-based, excluded
                    print("\t".join([chrom, str(start), str(i)]))
                else:
                    pass
                i += 1

# Print mask close if on the last chromosome.
if in_gap:
    print("\t".join([chrom, str(start), str(i)]))
