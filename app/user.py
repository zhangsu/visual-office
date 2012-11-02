import webapp2
import json
from util import *

from google.appengine.ext import db
from google.appengine.api import users


class User(db.Model):
    x = db.IntegerProperty()
    y = db.IntegerProperty()
    id = db.UserProperty(auto_current_user_add = True)

    def to_dic(self):
        return {'x': self.x,
                'y': self.y,
                'id': self.id}

    def to_json(self):
        return json.dumps(self.to_dic())



def user_key(map_id="default"):
    return db.Key.from_path('User', map_id)


class ListUsersPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()

        try:        
            users = db.GqlQuery("SELECT * FROM User WHERE ANCESTOR IS :1", user_key(map_id))
            users_l = [user.to_dic() for user in users]
            self.msg.ok(users_l)
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
        id = users.get_current_user() 
        user = lookup_user(map_id, id) 

        if not user:
            user = User(parent=user_key(map_id), key_name=id)

        try:
            user.x = int(self.request.get('x'))
            user.y = int(self.request.get('y'))
            user.put()

            self.msg.ok(user.to_dic()) 
        except ValueError:
            self.msg.error("Invalid coordinates")

            
    def lookup_user(self, map_id, user_id): 
        key = db.Key.from_path('User', map_id, 'User', user_id)
        user = db.get(key)
        return user


