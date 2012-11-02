import webapp2
import json
from util import Message

#fjkdsl
from google.appengine.ext import db
from google.appengine.api import users


class User(db.Model):
    x = db.IntegerProperty()
    y = db.IntegerProperty()
    name = db.StringProperty()

    def to_dic(self):
        return {'id': self.key().id(),
                'position': (self.x, self.y),
                'name': self.name}

    def to_json(self):
        return json.dumps(self.to_dic())



def user_key(map_id="default"):
    return db.Key.from_path('User', map_id)


class ListUsersPage(webapp2.RequestHandler):

    def get(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()

        try:        
            users = db.GqlQuery("SELECT * FROM User WHERE ANCESTOR IS :1", user_key(map_id))
        
            users_l = [user.to_dic() for user in users]
            self.msg.status = "OK"
            self.msg.content = users_l
        except Exception as e:
            self.msg.status = "ERROR"
            self.msg.content = e        
        self.response.out.write(self.msg.format())


class UserPage(webapp2.RequestHandler):

    def post(self):
        map_id = self.request.get('map_id') or "default"
        user_id = self.request.get('user_id')
        method = self.request.get('method')

        self.msg = Message()
        try:
            if method and method == "delete":
                self.do_delete(map_id, user_id)
            else:
                self.do_post(map_id, user_id)
        except Exception as e:
            self.msg.status = "ERROR"
            self.msg.content = e
        self.response.out.write(self.msg.format())


    def do_post(self, map_id, user_id):
        if user_id:
            user = self.lookup_user(map_id, user_id)
            if not user:
                self.msg.status = "ERROR"
                self.msg.content = "No user found for id %s in map %s" % (user_id, map_id)
                return
        else:
            user = Desk(parent=user_key(map_id))

        try:
            user.x = int(self.request.get('x'))
            user.y = int(self.request.get('y'))
            user.name = int(self.request.get('name'))
            user.put()

            self.msg.status = "OK"
            self.msg.content = user.to_dic() 
        except ValueError:
            self.msg.status = "ERROR"
            self.msg.content = "Invalid coordinates"

            
    def do_delete(self, map_id, user_id):
        if not user_id:
            self.msg.status = "ERROR"
            self.msg.content = "Please specify user_id"  
            return
        
        user = self.lookup_user(map_id, user_id)
        if not user:
            self.msg.status = "ERROR"
            self.msg.content = "No user found for id %s in map %s" % (user_id, map_id)
            return
         
        user.delete()
        self.msg.status = "OK"
        self.msg.content = user.to_dic() 

    def lookup_user(self, map_id, user_id): 
        key = db.Key.from_path('User', map_id, 'User', int(user_id))
        user = db.get(key)
        return user


