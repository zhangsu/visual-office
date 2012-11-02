import webapp2
import json
from util import *

from google.appengine.ext import db
from google.appengine.api import users


class Map(db.Model):
    tl_x = db.IntegerProperty()
    tl_y = db.IntegerProperty()
    br_x = db.IntegerProperty()
    br_y = db.IntegerProperty()
    map_id = db.StringProperty()

    def to_dic(self):
        return {'tl_x': self.tl_x,
                'tl_y': self.tl_y,
                'br_x': self.br_x,
                'br_y': self.br_y,
                'map_id': self.map_id}

    def to_json(self):
        return json.dumps(self.to_dic())


class MapsPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        self.msg = Message()
        map_id = self.request.get('map_id')

        try: 
            if map_id:       
                maps = db.GqlQuery("SELECT * FROM Map WHERE map_id = :1", map_id)
            else:
                maps = db.GqlQuery("SELECT * FROM Map")
            maps_l = [m.to_dic() for m in maps]
            self.msg.ok(maps_l)
        except Exception as e:
            self.msg.error(e)        
        self.response.out.write(self.msg.format())


    @authenticate
    def post(self):
        self.msg = Message()
        try:
            self.do_post()
        except Exception as e:
            self.msg.error(e)
        self.response.out.write(self.msg.format())


    def do_post(self):
        map_id = self.request.get('map_id')
        if not map_id:
            self.msg.error("Please specify map_id")
            return

        m = lookup_map(map_id) 

        if not m:
            m = Map(key_name=map_id)

        try:
            m.tl_x = int(self.request.get('tl_x'))
            m.tl_y = int(self.request.get('tl_y'))
            m.br_x = int(self.request.get('br_x'))
            m.br_y = int(self.request.get('br_y'))
            m.map_id = self.request.get('map_id')
            m.put()

            self.msg.ok(m.to_dic()) 
        except ValueError:
            self.msg.error("Invalid parameters")

            
def lookup_map(id): 
    key = db.Key.from_path('Map', id)
    return db.get(key)


