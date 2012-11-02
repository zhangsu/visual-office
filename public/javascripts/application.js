(function(){var e,t,n,r,i,s,o,u,a,f,l,c,h,p,d,v={}.hasOwnProperty,m=function(e,t){function n(){this.constructor=e}for(var r in t)v.call(t,r)&&(e[r]=t[r]);return n.prototype=t.prototype,e.prototype=new n,e.__super__=t.prototype,e};f=!1,r={nothing:0,addingSelf:1,removingSelf:2,addingDesk:3,removingDesk:4},d=r.nothing,a=1,u={topLeft:{x:-10,y:-10},bottomRight:{x:20,y:10}},l=null,p={},s=function(e,t){var n;n=""+e;if(p[n])return p[n][""+t]=null},c=function(e,t,n){var r;return r=""+e,p[r]||(p[r]={}),p[r][""+t]=n},o=function(e,t){var n,r;return n=""+e,r=""+t,p[n]?p[n][r]:null},h=function(e,t){var n;return n=u.topLeft,[Math.floor(e/32)+n.x,Math.floor(t/32)+n.y]},n=function(){function e(e,t,n,r){this.id=e,this.x=t,this.y=n,this.height=r}return e.prototype.screenX=function(){return(this.x-u.topLeft.x)*32},e.prototype.screenY=function(){return(this.y-u.topLeft.y+1)*32-this.height},e.prototype.freeTileNode=function(){return s(this.x,this.y)},e.prototype.remove=function(){return this.freeTileNode(),this.jq.addClass("fade-out"),this.jq.bind("animationnend oAnimationEnd webkitAnimationEnd",function(){return $(this).remove()})},e}(),e=function(e){function t(e,n,r,i,s,o){var u;this.name=n,this.width=s!=null?s:32,o==null&&(o=48),t.__super__.constructor.call(this,e,r,i,o),this.orien=0,this.jq=$("<div id='char"+this.id+"' class='character fade-in'>"),this.jq.css("z-index",i+1e6),this.jq_sprite=$("<div class='sprite'>"),this.jq_sprite.width(this.width),this.jq_sprite.height(o),this.jq.append("<div unselectable='on' class='name'>"+this.name+"</div>"),this.jq.append(this.jq_sprite),this.jq_sprite.addClass("male"),this.updateScreenX(),this.updateScreenY(),c(this.x,this.y,this),$("#canvas").append(this.jq),u=$("#char"+e+" .name"),u.css("left",""+(this.width-u.width())/2+"px"),u.css("top","-16px")}return m(t,e),t.prototype.moveLeft=function(){return this.freeTileNode(),this.x-=1,this.orien=1,this.updateScreenX(),this.updateMovement()},t.prototype.moveRight=function(){return this.freeTileNode(),this.x+=1,this.orien=2,this.updateScreenX(),this.updateMovement()},t.prototype.moveUp=function(){return this.freeTileNode(),this.y-=1,this.orien=3,this.updateScreenY(),this.updateMovement()},t.prototype.moveDown=function(){return this.freeTileNode(),this.y+=1,this.orien=0,this.updateScreenY(),this.updateMovement()},t.prototype.turn=function(){return this.orien+=1,this.orien%=4,this.updateOrientation()},t.prototype.enableTurning=function(){var e=this;return this.jq_sprite.click(function(){return e.turn()})},t.prototype.updateScreenX=function(){return this.jq.css("left",""+this.screenX()+"px")},t.prototype.updateScreenY=function(){return this.jq.css("top",""+this.screenY()+"px")},t.prototype.updateOrientation=function(){return this.jq_sprite.removeClass("orien0 orien1 orien2 orien3"),this.jq_sprite.addClass("orien"+this.orien)},t.prototype.updateMovement=function(){return c(this.x,this.y,this),this.updateOrientation()},t}(n),t=function(e){function t(e,n,r,i){i==null&&(i=48),t.__super__.constructor.call(this,e,n,r,i),this.jq=$("<div id='desk"+this.id+"' class='desk fade-in'>"),this.jq.width(32),this.jq.height(i),this.jq.css("z-index",r+1e6),this.updateScreenPos(),this.updateNode(),$("#canvas").append(this.jq)}return m(t,e),t.prototype.updateScreenPos=function(){return this.jq.css("left",""+this.screenX()+"px"),this.jq.css("top",""+this.screenY()+"px")},t.prototype.updateNode=function(){return c(this.x,this.y,this)},t}(n),i=function(){return u.topLeft.y-=10},$(function(){var n,i,s,a,c;return i=$("#canvas"),i.width((u.bottomRight.x-u.topLeft.x)*32),i.height((u.bottomRight.y-u.topLeft.y)*32),a=function(){return f=!1},$(window).focus(a).blur(a).mouseup(a),c=$("#toolbar"),$("#toolbar-toggle").click(function(){return c.toggleClass("collapsed")}),n=function(e,t){return $(e).click(function(){var n;return $(this).toggleClass("pressed"),n=r[t],d===n?d=r.nothing:($("#toolbar>:not("+e+")").removeClass("pressed"),d=n)})},n("#add-self","addingSelf"),n("#remove-self","removingSelf"),n("#add-desk","addingDesk"),n("#remove-desk","removingDesk"),s=function(n){var i,s,u,a;i=h(n.pageX,n.pageY),u=i[0],a=i[1],s=o(u,a);switch(d){case r.addingSelf:if(!s)return l&&l.remove(),l=new e(1,"szhang",u,a),l.enableTurning();break;case r.removingSelf:if(s&&s===l)return s.remove(),d=r.nothing,$("#remove-self").removeClass("pressed");break;case r.addingDesk:if(!s)return new t(1,u,a);break;case r.removingDesk:if(s instanceof t)return s.remove()}},i.mousedown(function(e){if(e.which===1)return f=!0,s(e)}).mousemove(function(e){if(!f)return;return s(e)})})}).call(this);