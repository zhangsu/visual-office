import webapp2
import json
from util import *

from google.appengine.ext import db
from google.appengine.api import users


class Yelper(db.Model):
    x = db.IntegerProperty()
    y = db.IntegerProperty()
    guser = db.UserProperty(auto_current_user_add = True)
    map_id = db.StringProperty()

    def to_dic(self):
        return {'x': self.x,
                'y': self.y,
                'id': self.guser.nickname().split('@')[0],
                'map_id': self.map_id}

    def to_json(self):
        return json.dumps(self.to_dic())


class MePage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        self.msg = Message()
        try:
            guser = users.get_current_user()
            yelper = lookup_yelper(guser.nickname())
            if yelper:
                self.msg.ok(yelper.to_dic())
            else:
                self.msg.ok({'id': guser.nickname()})
        except Exception as e:
            self.msg.error(e)
        self.response.out.write(self.msg.format())


class ListUsersPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        self.msg = Message()
        map_id = self.request.get('map_id')

        try: 
            if map_id:       
                yelpers = db.GqlQuery("SELECT * FROM Yelper WHERE map_id = :1", map_id)
            else:
                yelpers = db.GqlQuery("SELECT * FROM Yelper")
            yelpers_l = [yelper.to_dic() for yelper in yelpers]
            self.msg.ok(yelpers_l)
        except Exception as e:
            self.msg.error(e)        
        self.response.out.write(self.msg.format())


class UserPage(webapp2.RequestHandler):

    @authenticate
    def post(self):
        self.msg = Message()
        try:
            self.do_post()
        except Exception as e:
            self.msg.error(e)
        self.response.out.write(self.msg.format())


    def do_post(self):
        guser = users.get_current_user() 
        id = guser.nickname()
        yelper = lookup_yelper(id) 

        if not yelper:
            yelper = Yelper(key_name=id)

        try:
            yelper.x = int(self.request.get('x'))
            yelper.y = int(self.request.get('y'))
            yelper.map_id = self.request.get('map_id')
            yelper.put()

            self.msg.ok(yelper.to_dic()) 
        except ValueError:
            self.msg.error("Invalid coordinates")

            
def lookup_yelper(id): 
    key = db.Key.from_path('Yelper', id)
    yelper = db.get(key)
    return yelper


