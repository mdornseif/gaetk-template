#!/usr/bin/env python
# encoding: utf-8
"""
s_models.py - Sample Datastore Models

Created by Maximillian Dornseif on 2012-10-16.
Copyright (c) 2012 Dr. Maximillian Dornseif. All rights reserved.
"""

import config
config.imported = True

import base64
import re
import struct
from google.appengine.ext import ndb

## http://code.activestate.com/recipes/577257/
_slugify_strip_re = re.compile(r'[^\w\s-]')
_slugify_hyphenate_re = re.compile(r'[-\s]+')


def _slugify(value):
    """
    Normalizes string, converts to lowercase, removes non-alpha characters,
    and converts spaces to hyphens.

    From Django's "django/template/defaultfilters.py".
    """
    import unicodedata
    value = unicodedata.normalize('NFKD', unicode(value)).encode('ascii', 'ignore')
    value = unicode(_slugify_strip_re.sub('', value).strip().lower())
    return _slugify_hyphenate_re.sub('-', value)
## end of http://code.activestate.com/recipes/577257/


class s_Blogpost(ndb.Model):
    id = ndb.StringProperty(indexed=True)
    slug = ndb.StringProperty(indexed=False)
    title = ndb.StringProperty(required=True)
    body = ndb.TextProperty(default='')
    date = ndb.DateTimeProperty(auto_now_add=True)
    updated_at = ndb.DateTimeProperty(auto_now=True)
    created_at = ndb.DateTimeProperty(auto_now_add=True)
    created_by = ndb.UserProperty(auto_current_user_add=True)
    updated_by = ndb.UserProperty(auto_current_user=True)

    @classmethod
    def create(cls, title, body='', postid=None, slug=None):
        if not slug:
            slug = _slugify(title)
        post = cls(
            title=title,
            body=body,
            slug=slug)
        post.put()
        if not postid:
            post.id = "B%s" % base64.b32encode(struct.pack('>Q', post.key.id()).lstrip('\0')).lower().rstrip('=')
        else:
            post.id = str(postid)
        post.put()
        return post

    @property
    def url(self):
        return '/{0}-{1}'.format(self.id, self.slug)
