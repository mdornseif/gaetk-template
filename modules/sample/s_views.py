#!/usr/bin/env python
# encoding: utf-8
"""
s_views.py - Sample view Functions

Created by Maximillian Dornseif on 2012-10-16.
Copyright (c) 2012 Dr. Maximillian Dornseif. All rights reserved.
"""

import config
config.imported = True

import webapp2
import gaetk

from modules.sample.s_models import s_Blogpost


class Homepage(gaetk.handler.BasicHandler):
    def get(self):
        postings = s_Blogpost.query().order(-s_Blogpost.created_at).fetch(30)
        self.render(dict(postings=postings), 'sample/home.html')


# for the python 2.7 runrime application needs to be top-level
application = webapp2.WSGIApplication([
        ('^/$', Homepage),
    ], debug=True)
