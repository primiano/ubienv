#!/usr/bin/env python
#
# Copyright (c) 2013 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import sqlite3
import os
import re
import sys


def main(argv):
    conn = sqlite3.connect("bench.sql3")
    curs = conn.cursor()
    tablename = argv[1]
    curs.execute("CREATE TABLE " + tablename + " (id INTEGER PRIMARY KEY, allocs INTEGER, size INTEGER, tsize INTEGER, stack TEXT);")
    regex = re.compile(r'Allocations: (\d+)\s+Size: (\d+)\s+TotalSize: (\d+)\s+BeginStacktrace:(.*?)EndStacktrace\s*', re.MULTILINE|re.DOTALL)
    all_stdin = '\n'.join(sys.stdin)

    for match in regex.finditer(all_stdin):
        allocations = int(match.group(1))
        size = int(match.group(2))
        total_size = int(match.group(3))
        stack_trace = match.group(4)
        #writer.writerow([allocations, size, total_size, stack_trace])
        vals = [allocations, size, total_size, stack_trace]
        curs.execute("INSERT INTO " + tablename + " (allocs, size, tsize, stack) VALUES (?, ?, ?, ?);", vals)
    conn.commit()
    # for line in sys.stdin:
      # line = line.rstrip('\r\n')
      # if re.match(regex, line):
        # print line
    
if __name__=='__main__':
    main(sys.argv)
