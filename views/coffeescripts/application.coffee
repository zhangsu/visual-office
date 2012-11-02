addingDesk = false
mapId = 1
tiles = {}

Node =
  free: 0
  desk: 1
  char: 2

freeTileNode = (x, y) ->
  xkey = "#{x}"
  tiles[xkey]["#{y}"] = Node.free if tiles[xkey]

putTileNode = (x, y, node) ->
  xkey = "#{x}"
  tiles[xkey] ||= {}
  tiles[xkey]["#{y}"] = node

isTileFree = (x, y) ->
  xkey = "#{x}"
  ykey = "#{y}"
  not tiles[xkey] or not tiles[xkey][ykey]

tileUnderPoint = (x, y) ->
  [Math.floor(x / 32), Math.floor(y / 32)]

class Object
  constructor: (@id, @x, @y, @height) ->

  screenX: ->
    @x * 32

  screenY: ->
    (@y + 1) * 32 - @height

  freeTileNode: ->
    freeTileNode(@x, @y)


class Character extends Object
  constructor: (id, @name, x, y, @width = 32, height = 48) ->
    super(id, x, y, height)

    @jq = $("<div id='char#{@id}' class='character'>")
    @jq.css('z-index', y)
    @jq_sprite = $("<div class='sprite'>")
    @jq_sprite.width(@width)
    @jq_sprite.height(height)
    @jq.append("<div class='name'>#{@name}</div>")
    @jq.append(@jq_sprite)

    @jq_sprite.addClass('male')

    this.updateScreenX()
    this.updateScreenY()

    $('#canvas').append(@jq)

    # Need the computed width after rendering.
    jq_name = $("#char#{id} .name")
    jq_name.css('left', "#{(@width - jq_name.width()) / 2}px")
    jq_name.css('top', '-16px')

  moveLeft: ->
    this.freeTileNode()
    @x -= 1
    @orien = 1
    this.updateScreenX()
    this.updateMovement()

  moveRight: ->
    this.freeTileNode()
    @x += 1
    @orien = 2
    this.updateScreenX()
    this.updateMovement()

  moveUp: ->
    this.freeTileNode()
    @y -= 1
    @orien = 3
    this.updateScreenY()
    this.updateMovement()

  moveDown: ->
    this.freeTileNode()
    @y += 1
    @orien = 0
    this.updateScreenY()
    this.updateMovement()

  updateScreenX: ->
    @jq.css('left', "#{this.screenX()}px")

  updateScreenY: ->
    @jq.css('top', "#{this.screenY()}px")

  updateOrientation: ->
    @jq_sprite.removeClass('orien0 orien1 orien2 orien3')
    @jq_sprite.addClass("orien#{@orien}")

  updateMovement: ->
    putTileNode(@x, @y, Node.char)
    this.updateOrientation()

class Desk extends Object
  constructor: (id, x, y, height = 48) ->
    super(id, x, y, height)

    @jq = $("<div id='desk#{@id}' class='desk'>")
    @jq.width(32)
    @jq.height(height)
    @jq.css('z-index', y)

    this.updateScreenPos()
    this.updateNode()

    $('#canvas').append(@jq)

  updateScreenPos: ->
    @jq.css('left', "#{this.screenX()}px")
    @jq.css('top', "#{this.screenY()}px")

  updateNode: ->
    putTileNode(@x, @y, Node.desk)

$ ->
  canvas = $('#canvas')
  canvas.width(3200)
  canvas.height(1600)

  canvas.mousedown (e) ->
    if addingDesk
      indice = tileUnderPoint(e.pageX, e.pageY)
      x = indice[0]
      y = indice[1]
      if isTileFree(x, y)
        putTileNode(new Desk(1, x, y))
    else
      console.log 'should be moving'


  toolbar = $('#toolbar')
  $('#toolbar-toggle').click ->
    toolbar.toggleClass('collapsed')

  addDeskButton = $('#add-desk')
  addDeskButton.click ->
    addDeskButton.toggleClass('pressed')
    addingDesk = if addingDesk then false else true

  self = new Character(1, 'szhang', -1, 1)
  self.moveRight()
  self.moveRight()

  another = new Character(2, 'jolleon', 3, 4)
  another.moveLeft()

  desk1 = new Desk(1, 3, 3)
  desk2 = new Desk(2, 0, 1)
  desk3 = new Desk(3, 1, 0)
  desk4 = new Desk(4, 1, 2)
