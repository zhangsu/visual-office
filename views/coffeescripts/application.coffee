mousedownOnCanvas = false

ToolbarState =
  nothing: 0
  addingSelf: 1
  removingSelf: 2
  addingDesk: 3
  removingDesk: 4

toolbarState = ToolbarState.nothing

mapId = 1
mapDimension =
  topLeft:
    x: -10
    y: -10
  bottomRight:
    x: 20
    y: 10

myself = null

tiles = {}


freeTileNode = (x, y) ->
  xkey = "#{x}"
  tiles[xkey]["#{y}"] = null if tiles[xkey]

putTileNode = (x, y, node) ->
  console.log 'new node', x, y
  xkey = "#{x}"
  tiles[xkey] ||= {}
  tiles[xkey]["#{y}"] = node

getTileNode = (x, y) ->
  xkey = "#{x}"
  ykey = "#{y}"
  return null unless tiles[xkey]
  return tiles[xkey][ykey]

tileUnderPoint = (x, y) ->
  origin = mapDimension.topLeft
  console.log 'tile under', [Math.floor(x / 32) + origin.x, Math.floor(y / 32) + origin.y]
  [Math.floor(x / 32) + origin.x, Math.floor(y / 32) + origin.y]


class Object
  constructor: (@id, @x, @y, @height) ->

  screenX: ->
    (@x - mapDimension.topLeft.x) * 32

  screenY: ->
    (@y - mapDimension.topLeft.y + 1) * 32 - @height

  freeTileNode: ->
    freeTileNode(@x, @y)

  remove: ->
    this.freeTileNode()
    @jq.addClass('fade-out')
    @jq.bind 'animationnend oAnimationEnd webkitAnimationEnd', ->
      $(this).remove()


class Character extends Object
  constructor: (id, @name, x, y, @width = 32, height = 48) ->
    super(id, x, y, height)

    @orien = 0

    @jq = $("<div id='char#{@id}' class='character fade-in'>")
    @jq.css('z-index', y + 1000000)
    @jq_sprite = $("<div class='sprite'>")
    @jq_sprite.width(@width)
    @jq_sprite.height(height)
    @jq.append("<div unselectable='on' class='name'>#{@name}</div>")
    @jq.append(@jq_sprite)

    @jq_sprite.addClass('male')

    this.updateScreenX()
    this.updateScreenY()
    putTileNode(@x, @y, this)

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

  turn: ->
    @orien += 1
    @orien %= 4
    this.updateOrientation()

  enableTurning: ->
    @jq_sprite.click =>
      this.turn()

  updateScreenX: ->
    @jq.css('left', "#{this.screenX()}px")

  updateScreenY: ->
    @jq.css('top', "#{this.screenY()}px")

  updateOrientation: ->
    @jq_sprite.removeClass('orien0 orien1 orien2 orien3')
    @jq_sprite.addClass("orien#{@orien}")

  updateMovement: ->
    putTileNode(@x, @y, this)
    this.updateOrientation()


class Desk extends Object
  constructor: (id, x, y, height = 48) ->
    super(id, x, y, height)

    @jq = $("<div id='desk#{@id}' class='desk fade-in'>")
    @jq.width(32)
    @jq.height(height)
    @jq.css('z-index', y + 1000000)

    this.updateScreenPos()
    this.updateNode()

    $('#canvas').append(@jq)

  updateScreenPos: ->
    console.log 'screen x,y', this.screenX(), this.screenY()
    @jq.css('left', "#{this.screenX()}px")
    @jq.css('top', "#{this.screenY()}px")

  updateNode: ->
    putTileNode(@x, @y, this)


expandMap = ->


$ ->
  canvas = $('#canvas')
  canvas.width((mapDimension.bottomRight.x - mapDimension.topLeft.x) * 32)
  canvas.height((mapDimension.bottomRight.y - mapDimension.topLeft.y) * 32)

  resetMousedownState = ->
    mousedownOnCanvas = false

  $(window).focus(resetMousedownState)
    .blur(resetMousedownState)
    .mouseup(resetMousedownState)

  toolbar = $('#toolbar')
  $('#toolbar-toggle').click ->
    toolbar.toggleClass('collapsed')

  addToolbarEventHandler = (selector, stateKey) ->
    $(selector).click ->
      $(this).toggleClass('pressed')
      state = ToolbarState[stateKey]
      if toolbarState == state
        toolbarState = ToolbarState.nothing
      else
        $("#toolbar>:not(#{selector})").removeClass('pressed')
        toolbarState = state

  addToolbarEventHandler('#add-self', 'addingSelf')
  addToolbarEventHandler('#remove-self', 'removingSelf')
  addToolbarEventHandler('#add-desk', 'addingDesk')
  addToolbarEventHandler('#remove-desk', 'removingDesk')

  mouseClickHandler = (e) ->
    indice = tileUnderPoint(e.pageX, e.pageY)
    x = indice[0]
    y = indice[1]
    node = getTileNode(x, y)
    switch toolbarState
      when ToolbarState.addingSelf
        unless node
          myself.remove() if myself
          myself = new Character(1, 'szhang', x, y)
          myself.enableTurning()
      when ToolbarState.removingSelf
        if node and node is myself
          node.remove()
          toolbarState = ToolbarState.nothing
          $('#remove-self').removeClass('pressed')
      when ToolbarState.addingDesk
        new Desk(1, x, y) unless node
      when ToolbarState.removingDesk
        node.remove() if node instanceof Desk
      else

  canvas.mousedown (e) ->
    if e.which == 1
      mousedownOnCanvas = true
      mouseClickHandler(e)
  .mousemove (e) ->
    return unless mousedownOnCanvas
    mouseClickHandler(e)

