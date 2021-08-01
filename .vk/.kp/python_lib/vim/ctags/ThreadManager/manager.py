from multiprocessing import Queue
from multiprocessing.managers import SyncManager

SOCKET_USERDT = set()

HOST = ''
PORT = 5011
AUTHKEY = 'ctags' # password
SERVER_STARTED = 0

class QueueManager(SyncManager):
  """class: QueueManager"""
  pass

class QueueServer(object):
  """class: QueueServer"""

  def __init__(self, HOST, PORT, AUTHKEY):
    self.queue = Queue()
    self.userdts = SOCKET_USERDT
    QueueManager.register('get_queue', lambda : self.queue)
    QueueManager.register('get_userdts', lambda : self.userdts)

    self.manager = QueueManager(address = (HOST, PORT), authkey = AUTHKEY)

  def start (self):
    """def: start"""
    SERVER_STARTED = 1
    self.manager.start()

  def shutdown (self):
    """def: shutdown"""
    self.manager.shutdown()


class QueueClient(object):
  """class: QueueClient"""

  def __init__(self, HOST, PORT, AUTHKEY):
    QueueManager.register('get_queue')
    QueueManager.register('get_userdts')
    self.manager = QueueManager(address = (HOST, PORT), authkey = AUTHKEY)
    self.queue = None
    self.userdts = None

  def connect (self):
    """def: connect"""
    self.manager.connect()
    self.queue = self.manager.get_queue()
    self.userdts = self.manager.get_userdts()

def get_default_server ():
  m_queue_server = QueueServer(HOST, PORT, AUTHKEY)
  return m_queue_server

def get_default_client ():
  m_queue_client = QueueClient(HOST, PORT, AUTHKEY)
  return m_queue_client

#-------------------------------------------------------------------------------
# Example
#-------------------------------------------------------------------------------
# || m_queue_server = QueueServer(HOST, PORT, AUTHKEY)
# || m_queue_client = QueueClient(HOST, PORT, AUTHKEY)





