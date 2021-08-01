set cursorline
set cursorcolumn

function! s:simtags()
py << EOF
import tempfile
from shutil import rmtree
class TempDir(object):
  def __init__(self):
    self.tempdir = tempfile.mkdtemp(prefix='.ktagsim.')

  def __del__(self):
    rmtree(self.tempdir)

m_tempdir = TempDir()
os.environ['SIM_DB_DIR'] = m_tempdir.tempdir
EOF

  exe 'redir > ' . $SIM_DB_DIR . '/debug.log'
  silent !chmod 777 $KP_VIM_HOME/bin/simtags.py
  silent exe '!simtags.py ' . expand('%:p') . ' &'
  redir END
endfunction

" Set comments after 'end' for begin-end pair
command! -nargs=0 Simtags call <SID>simtags()



