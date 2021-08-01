#!/usr/bin/env python

from utils.search import search_typedef_tags, search_class_tags
from ThreadManager.manager import get_default_client
import main_mp

if __name__ == "__main__":

  main_mp.bufdo_search_tags(search_typedef_tags)
  main_mp.bufdo_search_tags(search_class_tags)




