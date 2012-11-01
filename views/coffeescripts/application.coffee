class Character
  constructor: (id, name, x, y, width, height) ->
    @id = id
    @name = name
    @x = x
    @y = y
    @orientation = 0
    @frame = 0
    @width = width
    @height = height
    @jq = $("<div id='#{@id}' class='character'>")
    @jq_sprite = $("<div class='character orientation0'>")
    @jq_sprite.width(width)
    @jq_sprite.height(height)
    @jq_sprite.addClass('male')
    @jq.append("<div class='name'>#{@name}</div>")
    @jq.append(@jq_sprite)
    this.updateScreenX()
    this.updateScreenY()
    $('#canvas').append(@jq)
    jq_name = $("\##{id} .name")
    console.log jq_name
    console.log jq_name.width()
    jq_name.css('left', "#{(width - jq_name.width()) / 2}px")
    jq_name.css('top', '-16px')

  moveLeft: ->
    @x -= 1
    @orientation = 1
    this.updateScreenX()
    this.updateOrientation()

  moveRight: ->
    @x += 1
    @orientation = 2
    this.updateScreenX()
    this.updateOrientation()

  moveUp: ->
    @y -= 1
    @orientation = 3
    this.updateScreenY()
    this.updateOrientation()

  moveDown: ->
    @y += 1
    @orientation = 0
    this.updateScreenY()
    this.updateOrientation()

  screenX: ->
    @x * 32

  screenY: ->
    (@y + 1) * 32 - @height

  updateScreenX: ->
    @jq.offset(left: this.screenX())

  updateScreenY: ->
    @jq.offset(top: this.screenY())

  updateOrientation: ->
    @jq_sprite.removeClass('orien0 orien1 orien2 orien3')
    @jq_sprite.addClass("orien#{@orientation}")

$ ->
  canvas = $('#canvas')
  canvas.width(3200)
  canvas.height(1600)

  self = new Character(1, 'szhang', 0, 0, 32, 48)
  self.moveRight()
  self.moveDown()

  self2 = new Character(2, 'jolleon', 3, 4, 32, 48)
  self2.moveLeft()
