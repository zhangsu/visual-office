import webapp2
import app.desk as desk
import app.user as user
import app.maps as maps

from app.util import authenticate


from google.appengine.api import users


class MainPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        self.response.out.write(
"""<!DOCTYPE html>
<html>
<head>
<title>Visual Office</title>
<meta charset='UTF-8' />
<link href='stylesheets/application.css' rel='stylesheet' />
<link href='stylesheets/screen.css' media='screen, projection' rel='stylesheet' />
<link href='stylesheets/print.css' media='print' rel='stylesheet' />
<!--[if IE]>
<link href='stylesheets/ie.css' media='screen, projection' rel='stylesheet' />
<![endif]-->
</head>
<body>
<div id='canvas'></div>
<div id='toolbar'>
<div id='add-self'></div>
<div id='remove-self'>
&times
</div>
<div id='add-desk'></div>
<div id='remove-desk'>
&times
</div>
<div id='toolbar-toggle'>
<div id='toolbar-toggle-arrow'></div>
</div>
</div>
<script src='http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js' type='text/javascript'></script>
<script src='javascripts/application.js' type='text/javascript'></script>
</body>
</html>
""")



app = webapp2.WSGIApplication([('/desks', desk.ListDesksPage),
                               ('/desk', desk.DeskPage),
                               ('/users', user.ListUsersPage),
                               ('/user', user.UserPage),
                               ('/me', user.MePage),
                               ('/maps', maps.MapsPage),
                               ('/', MainPage)],
                              debug=True)
