#!/usr/bin/env python
import json
import urllib2
import sys
import re
from multiprocessing.pool import ThreadPool


CR = 'https://codereview.chromium.org'

def GetDiff(cl, ps):
  try:
    url = '%s/download/issue%s_%s.diff' % (CR, cl, ps)
    return urllib2.urlopen(url).read()
  except urllib2.HTTPError:
    return None


def ExtractDiffLines(diff, context):
  prev_context = []
  res = []
  context_after = 0
  for line in diff.splitlines():
    if line.startswith('+ ') or line.startswith('- '):
      res += prev_context
      res += [line]
      prev_context = []
      context_after = context
    elif context_after > 0:
      res += [line]
      context_after -= 1
    elif context > 0:
      prev_context += [line]
      prev_context = prev_context[-1 * context:]
  return res


def CheckCRIs3WayMergeable(line):
  line = line.rstrip('\n')
  cl = line.split('/')[-1]
  cl_data = json.load(urllib2.urlopen('%s/api/%s' % (CR, cl)))
  if len(cl_data['patchsets']) < 2:
    return
  ps = cl_data['patchsets'][-1]
  ps_2 = cl_data['patchsets'][-2]
  diff = GetDiff(cl, ps)
  diff_2 = GetDiff(cl, ps_2)
  if not diff or not diff_2:
    return
  if ExtractDiffLines(diff, context=1) == ExtractDiffLines(diff_2, context=1):
    return '3way mergeable'
  if ExtractDiffLines(diff, context=0) == ExtractDiffLines(diff_2, context=0):
    return 'probable conflict'


def CheckSafe(line):
  try:
    return CheckCRIs3WayMergeable(line)
  except Exception as e:
    print '\nError %s' % e


def ExtractCRFromStdin():
  match_re = r'.*%s/(\d+)$' % CR
  while True:
    line = sys.stdin.readline()
    if not line:
      break
    m = re.match(match_re, line)
    if m:
      yield m.group(1)


if __name__ == "__main__":
  print 'Usage: git log | %s\n\n' % sys.argv[0]
  print 'Counting (press CTRL+C to stop)'
  pool = ThreadPool(250)
  count = 0
  stats = {}
  try:
    for x in pool.imap_unordered(CheckSafe, ExtractCRFromStdin()):
      count += 1
      stats.setdefault(x, 0)
      stats[x] += 1
      stats_str = ''
      for k, v in sorted(stats.items()):
        fmt = '%s: %d (%.2f %%)  ' % (k, v, v * 100.0 / count)
        stats_str += '%-25s' % fmt
      print '\r[%d] %s' % (count, stats_str),
      sys.stdout.flush()
  except KeyboardInterrupt as e:
    pass
  print '\n\n'
