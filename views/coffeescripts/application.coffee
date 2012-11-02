mousedownOnCanvas = false

ToolbarState =
  nothing: 0
  addingSelf: 1
  removingSelf: 2
  addingDesk: 3
  removingDesk: 4

toolbarState = ToolbarState.nothing

mapId = 'Playground'
mapDimension =
  topLeft:
    x: 0
    y: 0
  bottomRight:
    x: 200
    y: 100

myself = null
myName = ''

tiles = {}

$.ajaxSetup
  dataType: 'json'

imperativeRequestResponseHandler = (response) ->
  alert response.content if response.status == 'ERROR'

freeTileNode = (x, y) ->
  xkey = "#{x}"
  ykey = "#{y}"
  node = tiles[xkey][ykey]
  tiles[xkey][ykey] = null if tiles[xkey]

  if node instanceof Character
    $.post '/user',
      x: x,
      y: y,
      map_id: mapId,
      action: 'remove'
    , imperativeRequestResponseHandler
  else
    $.post '/desk',
      x: x,
      y: y,
      map_id: mapId,
      action: 'remove'
    , imperativeRequestResponseHandler


putTileNode = (x, y, node, persist = false) ->
  xkey = "#{x}"
  tiles[xkey] ||= {}
  tiles[xkey]["#{y}"] = node
  return unless persist

  if node instanceof Character
    $.post '/user',
      x: x,
      y: y,
      map_id: mapId
    , imperativeRequestResponseHandler
  else
    $.post '/desk',
      x: x,
      y: y,
      map_id: mapId
    , imperativeRequestResponseHandler

getTileNode = (x, y) ->
  xkey = "#{x}"
  ykey = "#{y}"
  return null unless tiles[xkey]
  return tiles[xkey][ykey]

tileUnderPoint = (x, y) ->
  origin = mapDimension.topLeft
  [Math.floor(x / 32) + origin.x, Math.floor(y / 32) + origin.y]

populateObjects = ->
  $.get '/desks', map_id: mapId, (response) ->
    imperativeRequestResponseHandler(response)

    for desk in response.content
      new Desk(desk.x, desk.y)

  $.get '/users', map_id: mapId, (response) ->
    imperativeRequestResponseHandler(response)

    for user in response.content
      new Character(user.id, user.x, user.y) unless getTileNode(user.x, user.y)


class Object
  constructor: (@x, @y, @height) ->

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
  constructor: (@name, x, y, persist = false, @width = 32, height = 48) ->
    super(x, y, height)

    @orien = 0

    @jq = $("<div class='character fade-in'>")
    @jq.css('z-index', y + 1000000)
    @jq_sprite = $("<div class='sprite'>")
    @jq_sprite.width(@width)
    @jq_sprite.height(height)
    @jq.append("<div class='name'>#{@name}</div>")
    @jq.append(@jq_sprite)

    @jq_sprite.addClass('male')

    this.updateScreenX()
    this.updateScreenY()
    putTileNode(@x, @y, this, persist)

    $('#canvas').append(@jq)

    # Need the computed width after rendering.
    jq_name = $(".character:last-child > .name")
    jq_name.css('left', "#{(@width - jq_name.width()) / 2}px")
    jq_name.css('top', '-16px')

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


class Desk extends Object
  constructor: (x, y, persist = false, height = 48) ->
    super(x, y, height)

    @jq = $("<div class='desk fade-in'>")
    @jq.width(32)
    @jq.height(height)
    @jq.css('z-index', y + 1000000)

    this.updateScreenPos()
    putTileNode(@x, @y, this, persist)

    $('#canvas').append(@jq)

  updateScreenPos: ->
    @jq.css('left', "#{this.screenX()}px")
    @jq.css('top', "#{this.screenY()}px")


expandMapTop = ->
  mapDimension.topLeft.y -= 10


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
          myself = new Character(myName, x, y, true)
          myself.enableTurning()
      when ToolbarState.removingSelf
        if node and node is myself
          node.remove()
          toolbarState = ToolbarState.nothing
          $('#remove-self').removeClass('pressed')
      when ToolbarState.addingDesk
        new Desk(x, y, true) unless node
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

  $.get '/me', (response) ->
    imperativeRequestResponseHandler(response)
    character = response.content
    if character.x
      myself = new Character(character.id, character.x, character.y)
    else
      myself = null
    myName = character.id

  populateObjects()

