#!/usr/bin/env python
#
# Copyright (c) 2013 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import csv
import os
import re
import sys


def main(argv):
    regex = re.compile(r'Allocations: (\d+)\s+Size: (\d+)\s+TotalSize: (\d+)\s+BeginStacktrace:(.*?)EndStacktrace\s*', re.MULTILINE|re.DOTALL)
    all_stdin = '\n'.join(sys.stdin)
    writer = csv.writer(sys.stdout, delimiter=';', quotechar='"', quoting=csv.QUOTE_NONE)

    for match in regex.finditer(all_stdin):
        allocations =  match.group(1)
        size = match.group(2)
        total_size = match.group(3)
        stack_trace = match.group(4)
        stack_trace = stack_trace.replace('\r','')
        stack_trace = stack_trace.replace('\n','|')
        writer.writerow([allocations, size, total_size, stack_trace])

    # for line in sys.stdin:
      # line = line.rstrip('\r\n')
      # if re.match(regex, line):
        # print line
    
if __name__=='__main__':
    main(sys.argv)
