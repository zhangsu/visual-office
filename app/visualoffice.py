import webapp2
import desk
import user

from google.appengine.api import users


class MainPage(webapp2.RequestHandler):
    def get(self):
        user = users.get_current_user()

        if user:
            self.response.headers['Content-Type'] = 'text/plain'
            self.response.out.write('Hello, ' + user.nickname())
        else:
            self.redirect(users.create_login_url(self.request.uri))




app = webapp2.WSGIApplication([('/desks', desk.ListDesksPage),
                               ('/desk', desk.DeskPage),
                               ('/users', user.ListUsersPage),
                               ('/user', user.UserPage),
                               ('/', MainPage)],
                              debug=True)
