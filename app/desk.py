import webapp2
import json
from util import Message


from google.appengine.ext import db
from google.appengine.api import users


class Desk(db.Model):
    tl_x = db.IntegerProperty()
    tl_y = db.IntegerProperty()
    br_x = db.IntegerProperty()
    br_y = db.IntegerProperty()
    
    def to_dic(self):
        return {'id': self.key().id(),
                'tl': (self.tl_x, self.tl_y),
                'br': (self.br_x, self.br_y)}

    def to_json(self):
        return json.dumps(self.to_dic())

    def to_string(desk):
        return "(%d, %d) - (%d, %d)<br>" % (desk.tl_x, desk.tl_y, desk.br_x, desk.br_y)



def desk_key(map_id="default"):
    return db.Key.from_path('Desk', map_id)


class ListDesksPage(webapp2.RequestHandler):

    def get(self):
        map_id = self.request.get('map_id') or "default"
        self.msg = Message()

        try:        
            desks = db.GqlQuery("SELECT * FROM Desk WHERE ANCESTOR IS :1", desk_key(map_id))
        
            desks_l = [desk.to_dic() for desk in desks]
            self.msg.status = "OK"
            self.msg.content = desks_l
        except Exception as e:
            self.msg.status = "ERROR"
            self.msg.content = e        
        self.response.out.write(self.msg.format())


class DeskPage(webapp2.RequestHandler):

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
            self.msg.status = "ERROR"
            self.msg.content = e
        self.response.out.write(self.msg.format())


    def do_post(self, map_id, desk_id):
        if desk_id:
            desk = self.lookup_desk(map_id, desk_id)
            if not desk:
                self.msg.status = "ERROR"
                self.msg.content = "No desk found for id %s in map %s" % (desk_id, map_id)
                return
        else:
            desk = Desk(parent=desk_key(map_id))

        try:
            desk.tl_x = int(self.request.get('tl_x'))
            desk.tl_y = int(self.request.get('tl_y'))
            desk.br_x = int(self.request.get('br_x'))
            desk.br_y = int(self.request.get('br_y'))
            desk.put()

            self.msg.status = "OK"
            self.msg.content = desk.to_dic() 
        except ValueError:
            self.msg.status = "ERROR"
            self.msg.content = "Invalid coordinates"

            
    def do_delete(self, map_id, desk_id):
        if not desk_id:
            self.msg.status = "ERROR"
            self.msg.content = "Please specify desk_id"  
            return
        
        desk = self.lookup_desk(map_id, desk_id)
        if not desk:
            self.msg.status = "ERROR"
            self.msg.content = "No desk found for id %s in map %s" % (desk_id, map_id)
            return
         
        desk.delete()
        self.msg.status = "OK"
        self.msg.content = desk.to_dic() 

    def lookup_desk(self, map_id, desk_id): 
        key = db.Key.from_path('Desk', map_id, 'Desk', int(desk_id))
        desk = db.get(key)
        return desk


