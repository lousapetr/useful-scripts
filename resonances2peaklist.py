#!/usr/bin/env python

import sys

if len(sys.argv) < 2:
    raise IOError('No input file!')

filename = sys.argv[1]

with open(filename, 'r') as f:
    res_name = None
    residue = {}
    for line in f:
        line = line.split()
        if res_name != line[0]:
            try:
                print '%sN-H\t%s\t%s' % (res_name, residue['N'], residue['H'])
            except KeyError:
                pass
            residue = {}
            res_name = line[0]
        atom_name = line[1]
        shift = line[3]
        residue[atom_name] = shift

