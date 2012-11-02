class Object
  constructor: (@id, @x, @y, @height) ->

  screenX: ->
    @x * 32

  screenY: ->
    (@y + 1) * 32 - @height


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
    @x -= 1
    @orien = 1
    this.updateScreenX()
    this.updateOrientation()

  moveRight: ->
    @x += 1
    @orien = 2
    this.updateScreenX()
    this.updateOrientation()

  moveUp: ->
    @y -= 1
    @orien = 3
    this.updateScreenY()
    this.updateOrientation()

  moveDown: ->
    @y += 1
    @orien = 0
    this.updateScreenY()
    this.updateOrientation()

  updateScreenX: ->
    @jq.css('left', "#{this.screenX()}px")

  updateScreenY: ->
    @jq.css('top', "#{this.screenY()}px")

  updateOrientation: ->
    @jq_sprite.removeClass('orien0 orien1 orien2 orien3')
    @jq_sprite.addClass("orien#{@orien}")


class Desk extends Object
  constructor: (id, x, y, height = 48) ->
    super(id, x, y, height)

    @jq = $("<div id='desk#{@id}' class='desk'>")
    @jq.width(32)
    @jq.height(height)
    @jq.css('z-index', y)

    this.updatePos()

    $('#canvas').append(@jq)

  updatePos: ->
    @jq.css('left', "#{this.screenX()}px")
    @jq.css('top', "#{this.screenY()}px")

addingDesk = false

$ ->
  canvas = $('#canvas')
  canvas.width(3200)
  canvas.height(1600)

  toolbar = $('#toolbar')
  $('#toolbar-toggle').click ->
    toolbar.toggleClass('collapsed')

  addDeskButton = $('#add-desk')
  addDeskButton.click ->
    addDeskButton.toggleClass('pressed')
    addingDesk ^= false

  self = new Character(1, 'szhang', -1, 1)
  self.moveRight()
  self.moveRight()

  another = new Character(2, 'jolleon', 3, 4)
  another.moveLeft()

  desk1 = new Desk(1, 3, 3)
  desk2 = new Desk(2, 0, 1)
  desk3 = new Desk(3, 1, 0)
  desk4 = new Desk(4, 1, 2)
