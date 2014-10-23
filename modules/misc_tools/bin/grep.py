#!/usr/bin/env python

import os
import re
import sys


def main(argv):
    regex = re.compile(argv[1])
    for line in sys.stdin:
      line = line.rstrip('\r\n')
      if re.match(regex, line):
        print line
    
if __name__=='__main__':
    main(sys.argv)