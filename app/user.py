import webapp2
import json
from util import *

from google.appengine.ext import db
from google.appengine.api import users


class Yelper(db.Model):
    x = db.IntegerProperty()
    y = db.IntegerProperty()
    guser = db.UserProperty(auto_current_user_add = True)

    def to_dic(self):
        return {'x': self.x,
                'y': self.y,
                'id': self.guser.nickname()}

    def to_json(self):
        return json.dumps(self.to_dic())



def yelper_key(map_id="default"):
    return db.Key.from_path('Yelper', map_id)


class ListUsersPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()

        try:        
            yelpers = db.GqlQuery("SELECT * FROM Yelper WHERE ANCESTOR IS :1", yelper_key(map_id))
            yelpers_l = [yelper.to_dic() for yelper in yelpers]
            self.msg.ok(yelpers_l)
        except Exception as e:
            self.msg.error(e)        
        self.response.out.write(self.msg.format())


class UserPage(webapp2.RequestHandler):

    @authenticate
    def post(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()
        try:
            self.do_post(map_id)
        except Exception as e:
            self.msg.error(e)
        self.response.out.write(self.msg.format())


    def do_post(self, map_id):
        guser = users.get_current_user() 
        id = guser.nickname()
        yelper = self.lookup_yelper(map_id, id) 

        if not yelper:
            yelper = Yelper(parent=yelper_key(map_id), key_name=id)

        try:
            yelper.x = int(self.request.get('x'))
            yelper.y = int(self.request.get('y'))
            yelper.put()

            self.msg.ok(yelper.to_dic()) 
        except ValueError:
            self.msg.error("Invalid coordinates")

            
    def lookup_yelper(self, map_id, id): 
        key = db.Key.from_path('Yelper', map_id, 'Yelper', id)
        yelper = db.get(key)
        return yelper


