#!/usr/bin/env python
import json
import optparse
import os
import shutil
import subprocess
import sys
import tempfile
import urllib2


def _GetJSON(url):
  return json.load(urllib2.urlopen(url))


def _ApplyPatchFromUrl(url, depth=0):
  url_fd = urllib2.urlopen(url)
  tmp_fd, tmp_path = tempfile.mkstemp()
  tmp_fd = os.fdopen(tmp_fd, 'w')
  shutil.copyfileobj(url_fd, tmp_fd)
  url_fd.close()
  tmp_fd.close()
  cmd = ['git', 'apply', '-3', '-p', str(depth), tmp_path]
  try:
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)
  except subprocess.CalledProcessError as ex:
    print '\nERROR:', ' '.join(cmd), ' failed (ret: %d)' % ex.returncode
    print ex.output
    return False
  os.remove(tmp_path)
  return True


def main():
  parser = optparse.OptionParser(usage='%prog [options] issue_number')
  parser.add_option('-p', dest='depth', type='int', help='Patch level')
  parser.add_option('-k', '--ignore_errors', action='store_true')
  parser.add_option('-s', '--rietveld-url',
                    default='https://breakpad.appspot.com')

  (options, args) = parser.parse_args()

  if len(args) < 1:
    parser.print_usage()
    return -1

  rietveld_url = options.rietveld_url
  cl = args[0]

  cl_desc = _GetJSON('%s/api/%s' % (rietveld_url, cl))
  print 'Downloading %s/%s (%s)' % (rietveld_url, cl, cl_desc['subject'])

  last_ps = cl_desc['patchsets'][-1]
  ps_desc = _GetJSON('%s/api/%s/%s' % (rietveld_url, cl, last_ps))
  print 'Last patchset is %s (%s, %s)' % (
      last_ps, ps_desc['message'], ps_desc['modified'])

  file_count = 0
  for file_name, file_desc in ps_desc['files'].iteritems():
    file_count += 1
    print '  [%d/%d] Patch %s...' % (
        file_count, len(ps_desc['files']), file_name)
    url = '%s/download/issue%s_%s_%s.diff' % (rietveld_url, cl, last_ps,
                                              file_desc['id'])
    success = _ApplyPatchFromUrl(url, options.depth)
    if not success and not options.ignore_errors:
      sys.exit(-2)


if __name__ == '__main__':
  sys.exit(main() or 0)