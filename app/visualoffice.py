import webapp2
import desk
import user
from util import authenticate


from google.appengine.api import users


class MainPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        user = users.get_current_user()
        self.response.out.write('Hello, ' + user.nickname())




app = webapp2.WSGIApplication([('/desks', desk.ListDesksPage),
                               ('/desk', desk.DeskPage),
                               ('/users', user.ListUsersPage),
                               ('/user', user.UserPage),
                               ('/', MainPage)],
                              debug=True)
