"""
Convert Mintty color format to XShell.

Usage:

    $ echo 'BoldRed=203,75,22' | $0
    red(bold)=dc322f
"""

import re
import fileinput
from collections import namedtuple

ColorIn = namedtuple('ColorIn', 'bold name r g b')

for line in fileinput.input()
    mm = re.match(r'(Bold)?(\w+)=(\d+),(\d+),(\d+)', line)
    if mm:
        zz = mm.groups()
        xshell_bold = "(bold)" if zz[0] else ""
        ci2 = ColorIn(xshell_bold, zz[1].lower(), int(zz[2]), int(zz[3]), int(zz[4]))
        print("{name}{bold}={r:0=2x}{g:0=2x}{b:0=2x}".format(**ci2._asdict()))
