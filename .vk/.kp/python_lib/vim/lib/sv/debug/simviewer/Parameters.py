#!/usr/bin/env python
import os

if 'SIM_DB_DIR' in os.environ:
  DB_DIR = os.environ['SIM_DB_DIR']
elif 'BASE_DIR' in os.environ:
  DB_DIR = os.path.abspath('{0}/.ktagssim'.format(os.environ['BASE_DIR']))
else:
  DB_DIR = os.path.abspath('{0}/.ktagssim'.format(os.environ['HOME']))

FOCUS_HIST_DBFILE = '{0}/_fochist.db'.format(DB_DIR) # focus history database
TIFILT_HIST_DBFILE = '{0}/_tifilthist.db'.format(DB_DIR) # text include filter history database
TEFILT_HIST_DBFILE = '{0}/_tefilthist.db'.format(DB_DIR) # text exclude filter history database
RIFILT_HIST_DBFILE = '{0}/_rifilthist.db'.format(DB_DIR) # regex include filter history database
REFILT_HIST_DBFILE = '{0}/_refilthist.db'.format(DB_DIR) # regex include filter history database

MAX_HISTORY = 100




