#!/usr/bin/env python3

##############################################################################
# Script to extract code blocks from markdown
##############################################################################
# Requires pip package: mdextractor

import argparse
from mdextractor import extract_md_blocks

parser = argparse.ArgumentParser(
    description='Extract code blocks from markdown',
    epilog='')
parser.add_argument('filename')
parser.add_argument('-o', '--output_file', default=None, help="output filename")
parser.add_argument('-b', '--bash_header', default=False, action=argparse.BooleanOptionalAction, help="add bash header")
args = parser.parse_args()

with open(args.filename, "r") as fin:
    md = ''.join(fin.readlines())

code = '\n'.join(extract_md_blocks(md))

if(args.output_file==None):
    print(code)
else:
    with open(args.output_file, "w") as fout:
        if(args.bash_header):
            fout.write("#!/usr/bin/bash\n")
            fout.write("# exit script on first error:\n")
            fout.write("set -e\n")
        fout.write(code)
