mousedownOnCanvas = false

addingSelf = false
addingDesk = false
removingDesk = false

mapId = 1

myself = null

tiles = {}


freeTileNode = (x, y) ->
  xkey = "#{x}"
  tiles[xkey]["#{y}"] = null if tiles[xkey]

putTileNode = (x, y, node) ->
  xkey = "#{x}"
  tiles[xkey] ||= {}
  tiles[xkey]["#{y}"] = node

getTileNode = (x, y) ->
  xkey = "#{x}"
  ykey = "#{y}"
  return null unless tiles[xkey]
  return tiles[xkey][ykey]

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
    @jq.css('z-index', y)
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
    @jq.css('z-index', y)

    this.updateScreenPos()
    this.updateNode()

    $('#canvas').append(@jq)

  updateScreenPos: ->
    @jq.css('left', "#{this.screenX()}px")
    @jq.css('top', "#{this.screenY()}px")

  updateNode: ->
    putTileNode(@x, @y, this)


$ ->
  canvas = $('#canvas')
  canvas.width(3200)
  canvas.height(1600)

  resetMousedownState = ->
    mousedownOnCanvas = false

  $(window).focus(resetMousedownState)
    .blur(resetMousedownState)
    .mouseup(resetMousedownState)

  toolbar = $('#toolbar')
  $('#toolbar-toggle').click ->
    toolbar.toggleClass('collapsed')

  addSelfButton = $('#add-self')
  addSelfButton.click ->
    addSelfButton.toggleClass('pressed')
    if addingSelf
      addingSelf = false
    else
      $('#toolbar>:not(#add-self)').removeClass('pressed')
      addingSelf = true
      addingDesk = false
      removingDesk = false

  addDeskButton = $('#add-desk')
  addDeskButton.click ->
    addDeskButton.toggleClass('pressed')
    if addingDesk
      addingDesk = false
    else
      $('#toolbar>:not(#add-desk)').removeClass('pressed')
      addingDesk = true
      removingDesk = false
      addingSelf = false

  removeDeskButton = $('#remove-desk')
  removeDeskButton.click ->
    removeDeskButton.toggleClass('pressed')
    if removingDesk
      removingDesk = false
    else
      $('#toolbar>:not(#remove-desk)').removeClass('pressed')
      removingDesk = true
      addingDesk = false
      addingSelf = false

  mouseClickHandler = (e) ->
    indice = tileUnderPoint(e.pageX, e.pageY)
    x = indice[0]
    y = indice[1]
    node = getTileNode(x, y)
    if addingSelf
      unless node
        myself.remove() if myself
        myself = new Character(1, 'szhang', x, y)
        myself.enableTurning()
    else if addingDesk
      putTileNode(x, y, new Desk(1, x, y)) unless node
    else if removingDesk
      node.remove() if node instanceof Desk
    else

  canvas.mousedown (e) ->
    if e.which == 1
      mousedownOnCanvas = true
      mouseClickHandler(e)
  .mousemove (e) ->
    return unless mousedownOnCanvas
    mouseClickHandler(e)

