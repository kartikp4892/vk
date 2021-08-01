#!/usr/bin/env python

import vim
import os, imp
import functools

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod


PARAMETERS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/Parameters.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
LOADER = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/Loader.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
BUFFERS = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/simviewer/Buffers.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
UTILSBUF = import_('{kp_vim_home}/python_lib/vim/lib/Utils/Buffer.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
HLSEARCH = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/hlsearch.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))
HISTORYDB = import_('{kp_vim_home}/python_lib/vim/lib/sv/debug/utils/historydb.py'.format(kp_vim_home=os.environ['KP_VIM_HOME']))


winsaveview = vim.Function('winsaveview')
winrestview = vim.Function('winrestview')

class Toggle(object):
  """class: Toggle
     This class implements logic to toggle b/w log buffer and simviewer buffer
  """

  def __init__(self, **kwargs):
    self.logbuf = BUFFERS.LogBuf() # Actual logfile buffer
    self.viewer = kwargs['viewer']

  def toggle_buffer (self):
    """def: toggle_buffer"""
    if self.logbuf.is_active():
      self.viewer.activate()
    else:
      self.logbuf.activate()


class Viewer(object):
  """class: Viewer"""

  buff_count = 0
  m_constraint_history = {
    'filter_include_text': HISTORYDB.historydb(PARAMETERS.TIFILT_HIST_DBFILE, PARAMETERS.MAX_HISTORY),
    'filter_exclude_text': HISTORYDB.historydb(PARAMETERS.TEFILT_HIST_DBFILE, PARAMETERS.MAX_HISTORY),
    'filter_include_regex': HISTORYDB.historydb(PARAMETERS.RIFILT_HIST_DBFILE, PARAMETERS.MAX_HISTORY),
    'filter_exclude_regex': HISTORYDB.historydb(PARAMETERS.REFILT_HIST_DBFILE, PARAMETERS.MAX_HISTORY),
    'focus': HISTORYDB.historydb(PARAMETERS.FOCUS_HIST_DBFILE, PARAMETERS.MAX_HISTORY),
  }

  def __init__(self, **kwargs):
    """ __init__:
        Create new hidden buffer. Current buffer remain active
    """
    Viewer.buff_count += 1
    self.buff_idx = Viewer.buff_count
    self.buff_name = 'Viewer_{0}'.format(str(self.buff_idx).rjust(2, '0')) # Viewer_01, Viewer_02...etc
    self.m_viewerbuf = BUFFERS.ViewerBuf(name=self.buff_name)

    self.m_loader_report = LOADER.LoaderReport(m_viewerbuf=self.m_viewerbuf, **kwargs)
    # self.m_loader_filter = LOADER.LoaderFilter(**kwargs)
    # self.m_loader_toggler = LOADER.LoaderToggler(**kwargs)

  def activate (self):
    """def: activate"""
    self.m_viewerbuf.activate()
    self.refresh_view()

  # def add_report_filter (self):
  #   """def: add_report_filter"""
  #   self.m_loader_report.add_report()

  def add_report (self):
    """def: add_report"""
    # || try:
    # ||   self.m_loader.add_report()
    # || except Exception:
    # ||   print "Can't process db file. Please make sure db file exists. Path: {0}".format(self.m_loader.db_dir)
    self.m_loader_report.add_report()
    # TODO: self.refresh_view()

  # def remove_report_filter (self):
  #   """def: remove_report_filter"""
  #   self.m_loader_report.remove_report()

  def remove_report (self):
    """def: remove_report"""
    # || try:
    # ||   self.m_loader.remove_report()
    # || except Exception:
    # ||   print "Can't process db file. Please make sure db file exists. Path: {0}".format(self.m_loader.db_dir)
    self.m_loader_report.remove_report()
    self.refresh_view()

  def refresh_view (self):
    """def: refresh_view"""
    self.m_loader_report.write()

  def visual_text_filter (self, include_or_exclude):
    """def: visual_text_filter"""
    # Get the visual selected (using v,V..) text
    value = UTILSBUF.getvisualtxt ()
    self.m_loader_report.add_filter(value=value, text_or_regex='text', include_or_exclude=include_or_exclude)

  def add_filter (self, **kwargs):
    """def: add_filter"""
    dbkey = 'filter_{0}_{1}'.format(kwargs['include_or_exclude'], kwargs['text_or_regex'])
    m_history = Viewer.m_constraint_history[dbkey]

    # Add filter and update history database
    callbacks = [functools.partial(self.__add_filter_cb, **kwargs), lambda value: m_history.insert(value)]

    history = m_history.get()

    HLSEARCH.hlsearch().input(scratch='{0}_{1}'.format(kwargs['include_or_exclude'], kwargs['text_or_regex']),
                              callbacks=callbacks, history=history)
    # self.m_loader_report.add_filter(**kwargs)

  def remove_filter (self):
    """def: remove_filter"""
    self.m_loader_report.remove_filter()

  def clear_filters (self):
    """def: clear_filters"""
    self.m_loader_report.clear_filters()

  def __add_filter_cb (self, **kwargs):
    """def: __add_filter_cb
       Add report in current line to the viewer next to the current viewer
    """

    self.m_loader_report.add_filter(**kwargs)

  def add_focus (self, **kwargs):
    """def: add_focus"""
    m_history = Viewer.m_constraint_history['focus']

    # Add focus and update history database
    callbacks = [functools.partial(self.__add_focus_cb, **kwargs), lambda value: m_history.insert(value)]

    history = m_history.get()

    HLSEARCH.hlsearch().input(scratch='focus',
                              callbacks=callbacks, history=history)
    # self.m_loader_report.add_focus(**kwargs)

  def remove_focus (self):
    """def: remove_focus"""
    self.m_loader_report.remove_focus()

  def clear_focuses (self):
    """def: clear_focuses"""
    self.m_loader_report.clear_focuses()

  def __add_focus_cb (self, **kwargs):
    """def: __add_focus_cb
       Add report in current line to the viewer next to the current viewer
    """
    self.m_loader_report.add_focus(**kwargs)

class ViewerTop(object):
  """class: ViewerTop"""

  logbuf = BUFFERS.LogBuf() # Actual logfile buffer
  m_viewers = {}
  m_toggle = None # Will be loaded when first viewer is created

  @classmethod
  def refresh_view (cls):
    """def: refresh_view"""
    m_viewer = cls.current_viewer()
    m_viewer.refresh_view()

  @classmethod
  def create_viewer (cls):
    """def: create_viewer"""
    m_viewer = Viewer(db_dir=PARAMETERS.DB_DIR)
    cls.m_viewers[m_viewer.m_viewerbuf.buff_id] = m_viewer
    return m_viewer

  @classmethod
  def current_viewer (cls):
    """def: current_viewer
       Get the current active viewer
    """
    bufid = vim.current.buffer.number
    # Return viewer object
    if bufid in cls.m_viewers:
      return cls.m_viewers[bufid]

    # Return log buffer object
    if bufid == cls.logbuf.buff.number:
      return cls.logbuf

    return None

  @classmethod
  def mappings (cls, m_viewer):
    """def: mappings
       This function is called after creating new viewer. New view is passed in the argument
       This function defines following mappings:
         1. Global Mapping to jump to the newly created viewer
         2. Buffer local mapping in current viewer:
            Mapping to jump to next viewer
         3. Buffer local mapping in next viewer:
            Mapping to jump to previous viewer
    """
    #-------------------------------------------------------------------------------
    # Mappings in viewer N
    vim.command('nmap <M-{0}> :silent py ViewerTop.activate({1})<CR>'.format(Viewer.buff_count , m_viewer.m_viewerbuf.buff_id))
    vim.command('nmap <buffer> <M-n> :py ViewerTop.activate({0})<CR>'.format(m_viewer.m_viewerbuf.buff_id))
    #-------------------------------------------------------------------------------

    m_saveviewer = cls.current_viewer()
    if isinstance(m_saveviewer, BUFFERS.LogBuf):
      savebufid = m_saveviewer.buff_id
    else:
      savebufid = m_saveviewer.m_viewerbuf.buff_id

    saveview = winsaveview()
    m_viewer.activate()

    #-------------------------------------------------------------------------------
    # Mappings in viewer N + 1
    vim.command('nmap <buffer> <M-p> :py ViewerTop.activate({0})<CR>'.format(savebufid)) # Mapping for jumb to previous viewer buffer
    #-------------------------------------------------------------------------------

    m_saveviewer.activate()
    winrestview(saveview)

  @classmethod
  def next_viewer (cls):
    """def: next_viewer"""

    if cls.logbuf.is_active():
      if Viewer.buff_count == 0:
        m_viewer = cls.create_viewer()
        cls.m_toggle = Toggle(viewer=m_viewer)
        cls.mappings(m_viewer)
        return m_viewer

      bufid = next(bid for bid in cls.m_viewers.keys() if bid > vim.current.buffer.number)
      return cls.m_viewers[bufid]
    else:
      if vim.current.buffer.number in cls.m_viewers:
        # Create new viewer if add_report is called in last viewer
        if vim.current.buffer.number == max(cls.m_viewers.keys()):
          m_viewer = cls.create_viewer()
          cls.mappings(m_viewer)
          return m_viewer

        bufid = next(bid for bid in cls.m_viewers.keys() if bid > vim.current.buffer.number)
        return cls.m_viewers[bufid]

    return None

  @classmethod
  def add_report (cls):
    """def: add_report
       Add report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.next_viewer()
    m_viewer.add_report()

  @classmethod
  def remove_report (cls):
    """def: remove_report
       Add report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    if m_viewer:
      m_viewer.remove_report()

  @classmethod
  def visual_text_filter (cls, include_or_exclude):
    """def: add_report
       Add report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.visual_text_filter(include_or_exclude)

  @classmethod
  def add_filter (cls, **kwargs):
    """def: add_report
       Add filter for the report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.add_filter(**kwargs)

  @classmethod
  def remove_filter (cls):
    """def: remove_filter
       remove filters for report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.remove_filter()

  @classmethod
  def clear_filters (cls):
    """def: clear_filters
       Remove all filters in current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.clear_filters()

  @classmethod
  def add_focus (cls, **kwargs):
    """def: add_report
       Add focus for the report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.add_focus(**kwargs)

  @classmethod
  def remove_focus (cls):
    """def: remove_focus
       remove focuses for report in current line to the viewer next to the current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.remove_focus()

  @classmethod
  def clear_focuses (cls):
    """def: clear_focuses
       Remove all focuses in current viewer
    """
    m_viewer = cls.current_viewer()
    m_viewer.clear_focuses()

  @classmethod
  def toggle_buffer (cls):
    """def: toggle_buffer"""
    cls.m_toggle.toggle_buffer()

  @classmethod
  def activate (cls, buf_id):
    """def: activate"""
    if buf_id in cls.m_viewers:
      if not cls.m_viewers[buf_id].m_viewerbuf.is_active():
        cls.m_viewers[buf_id].activate()
    elif buf_id == cls.logbuf.buff_id:
      cls.logbuf.activate()

if __name__ == "__main__":

  # Check if $BASE_DIR exists. The databse will be in base directory if exists
  # otherwise in the $HOME directory
  # if 'BASE_DIR' in os.environ:
  #   db_dir = os.path.abspath('{0}/.ktagssim'.format(os.environ['BASE_DIR']))
  # else:
  #   db_dir = os.path.abspath('{0}/.ktagssim'.format(os.environ['HOME']))

  # || try:
  # ||   m_viewer = Viewer(db_dir=db_dir)
  # || except Exception:
  # ||   pass # Don't give error if db file doesn't exists
  # m_viewer = Viewer(db_dir=db_dir)

  # vim.command('''nmap \\a :py m_viewer.add_report_filter()<CR>''')
  # vim.command('''nmap \\d :py m_viewer.remove_report_filter()<CR>''')
  vim.command('''nmap <M-r> :py ViewerTop.refresh_view()<CR>''')
  vim.command('''nmap <M-a> :py ViewerTop.add_report()<CR>''')
  vim.command('''nmap <M-d> :py ViewerTop.remove_report()<CR>''')
  vim.command('''nmap <M-t> :py ViewerTop.toggle_buffer()<CR>''')

  vim.command('''vmap ft :py ViewerTop.visual_text_filter('include')<CR>''')
  vim.command('''vmap fT :py ViewerTop.visual_text_filter('exclude')<CR>''')

  # Filter
  vim.command('''nmap fr :py ViewerTop.add_filter(text_or_regex='regex', include_or_exclude='include')<CR>''')
  vim.command('''nmap fR :py ViewerTop.add_filter(text_or_regex='regex', include_or_exclude='exclude')<CR>''')
  vim.command('''nmap ft :py ViewerTop.add_filter(text_or_regex='text', include_or_exclude='include')<CR>''')
  vim.command('''nmap fT :py ViewerTop.add_filter(text_or_regex='text', include_or_exclude='exclude')<CR>''')
  vim.command('''nmap fc :py ViewerTop.clear_filters()<CR>''')

  vim.command('''nmap Fi :py ViewerTop.remove_filter()<CR>''')

  # Focus
  vim.command('''nmap fo :py ViewerTop.add_focus()<CR>''')
  vim.command('''nmap Fo :py ViewerTop.remove_focus()<CR>''')

  # Toggle between current cursor report and previous view of the report
  # vim.command('''nmap \\ta :py m_viewer.m_loader_toggler.add_report()<CR>''') # Toggle add
  # vim.command('''nmap \\td :py m_viewer.m_loader_toggler.remove_report()<CR>''') # Toggle add
  # vim.command('''nmap <M-g> :py m_viewer.m_loader_toggler.toggle()<CR>''')





