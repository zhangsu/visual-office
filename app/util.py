import json

class Message:
    status = "OK"
    content = ""
    
    def format(self):
        return json.dumps({'status': self.status, 'content': self.content})


