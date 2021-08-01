#!/usr/bin/env python
import sqlite3

# TODO: Add method to reset database

class historydb(object):
  """class: historydb"""

  def __init__(self, db_name, max_entries=100):
    self.db_name = db_name
    self.max_entries = max_entries

    self.open()

  def close (self):
    """def: close
       Close the database connection when done
    """
    self.cur.close()
    self.cunn.commit()
    self.cunn.close()
    
  def open (self):
    """def: open
       Open database
    """
    self.cunn = sqlite3.connect(self.db_name) # sqlite3 Connection 
    self.cur = self.cunn.cursor() # sqlite3 cursor

    # WAL Mode enables concurrent Read/Write at the same time
    # self.cur.execute('PRAGMA journal_mode=wal')


    self.cur.execute('''CREATE TABLE IF NOT EXISTS historydb (
    id INTEGER PRIMARY KEY,
    text,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )''')

    rows = self.cur.execute('''SELECT ID FROM historydb ORDER BY timestamp DESC ''' ).fetchall()

    self.cur.execute('''DELETE FROM historydb WHERE id NOT IN (
      SELECT id FROM historydb ORDER BY id DESC LIMIT ?
    )''', [self.max_entries])

    rows = self.cur.execute('''SELECT id FROM historydb''').fetchall()


  def insert (self, text):
    """def: insert
       Insert text into database
    """
    # Delete old entry from database if exits with the same text
    self.cur.execute('''DELETE FROM historydb where text = ?''', [text])

    self.cur.execute('''INSERT INTO historydb (text) VALUES (?)''', [text])
    self.cunn.commit()

  def get (self):
    """def: get
       Get and return all the historydb in array
    """
    rows = self.cur.execute('''SELECT text FROM historydb ORDER BY id DESC''').fetchall()
    rows = [row[0] for row in rows]
    return rows

if __name__ == "__main__":
  m_history = historydb('test.db')
  print m_history.get()
  m_history.insert('One')
  m_history.insert('Two')
  m_history.insert('Three')
  print m_history.get()
  m_history.close() # Don't forget to close database when done









