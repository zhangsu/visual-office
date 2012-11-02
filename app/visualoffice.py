import webapp2
import desk
import user
import maps

from util import authenticate


from google.appengine.api import users


class MainPage(webapp2.RequestHandler):

    @authenticate
    def get(self):
        user = users.get_current_user()
        self.response.out.write('Hello, ' + user.nickname())

        self.response.out.write("""
<script>
function loadXMLDoc()
{
var xmlhttp;
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
    }
  }
xmlhttp.open("POST","user",true);
xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
xmlhttp.send("x=5&y=6&map_id=8thfloor");
}
</script>
<script>
function loadXMLDoc2()
{
var xmlhttp;
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    document.getElementById("myDiv").innerHTML=xmlhttp.responseText;
    }
  }
xmlhttp.open("POST","maps",true);
xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
xmlhttp.send("tl_x=-5&tl_y=-8&br_x=100&br_y=200&map_id=9thfloor");
}
</script>
<br>
<button type="button" onclick="loadXMLDoc()">Post data</button>
<br>
<button type="button" onclick="loadXMLDoc2()">Post data</button>
<div id="myDiv"></div>


""")


app = webapp2.WSGIApplication([('/desks', desk.ListDesksPage),
                               ('/desk', desk.DeskPage),
                               ('/users', user.ListUsersPage),
                               ('/user', user.UserPage),
                               ('/me', user.MePage),
                               ('/maps', maps.MapsPage),
                               ('/', MainPage)],
                              debug=True)
