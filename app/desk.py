import webapp2
import json
from util import *


from google.appengine.ext import db
from google.appengine.api import users


class Desk(db.Model):
    x = db.IntegerProperty()
    y = db.IntegerProperty()
    
    def to_dic(self):
        return {'id': self.key().id(),
                'x': self.x,
                'y': self.y}

    def to_json(self):
        return json.dumps(self.to_dic())


def desk_key(map_id="default"):
    return db.Key.from_path('Desk', map_id)


class ListDesksPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()

        try:        
            desks = db.GqlQuery("SELECT * FROM Desk WHERE ANCESTOR IS :1", desk_key(map_id))
            desks_l = [desk.to_dic() for desk in desks]
            self.msg.ok(desks_l)
        except Exception as e:
            self.msg.error(e)        
        self.response.out.write(self.msg.format())


class DeskPage(webapp2.RequestHandler):

    @authenticate
    def post(self):
        map_id = self.request.get('map_id') or "default"
        desk_id = self.request.get('desk_id')
        method = self.request.get('method')

        self.msg = Message()
        try:
            if method and method == "delete":
                self.do_delete(map_id, desk_id)
            else:
                self.do_post(map_id, desk_id)
        except Exception as e:
            self.msg.error(e)
        self.response.out.write(self.msg.format())


    def do_post(self, map_id, desk_id):
        if desk_id:
            desk = self.lookup_desk(map_id, desk_id)
            if not desk:
                self.msg.error("No desk found for id %s in map %s" % (desk_id, map_id))
                return
        else:
            desk = Desk(parent=desk_key(map_id))

        try:
            desk.x = int(self.request.get('x'))
            desk.y = int(self.request.get('y'))
            desk.put()

            self.msg.ok(desk.to_dic())
        except ValueError:
            self.msg.error("Invalid coordinates")

            
    def do_delete(self, map_id, desk_id):
        if not desk_id:
            self.msg.error("Please specify desk_id") 
            return
        
        desk = self.lookup_desk(map_id, desk_id)
        if not desk:
            self.msg.error("No desk found for id %s in map %s" % (desk_id, map_id))
            return
         
        desk.delete()
        self.msg.ok(desk.to_dic())


    def lookup_desk(self, map_id, desk_id): 
        key = db.Key.from_path('Desk', map_id, 'Desk', int(desk_id))
        desk = db.get(key)
        return desk


