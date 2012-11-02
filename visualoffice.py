import webapp2
import app.desk as desk
import app.user as user
import app.maps as maps

import os
from google.appengine.ext.webapp import template
from app.util import authenticate


from google.appengine.api import users


class MainPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        template_values = {
        }
        path = os.path.join(os.path.dirname(__file__), 'public/index.html')
        self.response.out.write(template.render(path, template_values))



app = webapp2.WSGIApplication([('/desks', desk.ListDesksPage),
                               ('/desk', desk.DeskPage),
                               ('/users', user.ListUsersPage),
                               ('/user', user.UserPage),
                               ('/me', user.MePage),
                               ('/maps', maps.MapsPage),
                               ('/', MainPage)],
                              debug=True)
