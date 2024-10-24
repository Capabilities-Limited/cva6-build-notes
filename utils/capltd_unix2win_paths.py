#!/usr/bin/env python3

##############################################################################
# Script convert UNIX to Windows paths
##############################################################################
# Copyright Simon W. Moore, Capabilities Limited, September 2024
##############################################################################
# Notes:
#  - replaces /mnt/c with C: (for any drive letter)
#  - preserves the UNIX / seperator rather than use the windows \ since that
#    is what is needed in Xilinx tcl scripts

import argparse

parser = argparse.ArgumentParser(
    description='Convert UNIX to Winodws paths',
    epilog='')
parser.add_argument('filename')
parser.add_argument('-o', '--output_file', default=None, help="output filename")
args = parser.parse_args()

with open(args.filename, 'r') as fin:
    code = ''.join(fin.readlines())

outfn = args.filename if (args.output_file==None) else args.output_file
with open(outfn, 'w') as fout:
    words = code.split(' ')
    for j in range(len(words)):
        pathlst = words[j].split('/')
        if((len(pathlst)>3) and (pathlst[1]=='mnt')):
            drive = pathlst[2]
            words[j] = pathlst[0]+drive.capitalize()+':/'+'/'.join(pathlst[3:])
    code = ' '.join(words)
    fout.write(code)
