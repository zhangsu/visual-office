import json

from google.appengine.api import users

class Message:
    status = "OK"
    content = ""
    
    def ok(self, content):
        self.status = "OK"
        self.content = content

    def error(self, content):
        self.status = "ERROR"
        self.content = content
 
    def format(self):
        return json.dumps({'status': self.status, 'content': self.content})


def authenticate(f):
    def wrapper(*args, **kwargs):
        user = users.get_current_user()
        if user:
            f(*args,**kwargs)
        else:
            self.redirect(users.create_login_url(self.request.uri))
    return wrapper
