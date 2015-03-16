class Board
  constructor: (@canvas) ->
    console.log("hellos")

class KeyboardHandler
  MODIFIERS = ['shift', 'ctrl', 'alt', 'meta']
  ALIAS = {
    'left': 37,
    'up': 38,
    'right': 39,
    'down': 40,
    'space': 32,
    'pageup': 33,
    'pagedown': 34,
    'tab': 9,
  }

  keyCodes: {}
  modifiers: {}

  onKeyDown: (event) =>
    @onKeyChange(event, true)


  onKeyUp: (event) =>
    @onKeyChange(event, false)

  bind: () ->
    document.addEventListener('keydown', @onKeyDown, false)
    document.addEventListener('keyup', @onKeyUp, false)

  unbind: () ->
    document.removeEventListener('keydown', @onKeyDown, false)
    document.removeEventListener('keyup', @onKeyUp, false)

  onKeyChange: (event, pressed) =>
    keyCode = event.keyCode
    @keyCodes[keyCode] = pressed
    this.modifiers['shift']= event.shiftKey
    this.modifiers['ctrl'] = event.ctrlKey
    this.modifiers['alt'] = event.altKey
    this.modifiers['meta'] = event.metaKey

  pressed: (keyDesc) =>
    keys = keyDesc.split('+')
    for key in keys
      if MODIFIERS.indexOf(key) isnt -1
        pressed = @modifiers[key]
      else if Object.keys(ALIAS).indexOf(key) isnt -1
        pressed = @keyCodes[ALIAS[key]]
      else
        pressed = @keyCodes[key.toUpperCase().charCodeAt(0)]

      if !pressed
        return false

    true

class Player
  constructor: (@scoreEl) ->
    @score = 0

  incrementScore: () ->
    @score++

  updateScore: () ->
    @incrementScore()
    @scoreEl.text(@score)

class Paddle
  constructor: (@pos) ->
    @width = 10
    @height = 65
    @speed = 2
    @input = 0

  doAiInput: (ball) ->
    if ball.pos[1] > @pos[1] + (@height * 0.5)
      @input = 1
    else if ball.pos[1] < @pos[1] + (@height * 0.5)
      @input = -1
    else
      @input = 0

  update: () ->
    @pos[1] += @input * @speed

  draw: (context) ->
    halfWidth = (0.5 * @width)
    context.beginPath()
    context.fillStyle = 'red'
    context.rect (@pos[0] - halfWidth), @pos[1], @width, @height
    context.closePath()
    context.fill()

class Ball
  constructor: (@canvas) ->
    @size = 5
    @pos = [@canvas.width * 0.5, @canvas.height * 0.5]
    @vel = [100, 300]

  update: (time) ->
    for i in [0..1]
      @pos[i] += time * @vel[i]

  draw: (context) ->
    context.beginPath()
    context.fillStyle = 'red'
    context.arc @pos[0], @pos[1], @size, 0, 2 * Math.PI
    context.closePath()
    context.fill()

class PongGame
  constructor: () ->
    @canvas = $('#myCanvas')[0]
    $('#myCanvas').attr('width', parseInt($('#myCanvas').css('width')))
    $('#myCanvas').attr('height', parseInt($('#myCanvas').css('height')))
    @context = @canvas.getContext("2d")
    @player1 = new Player($('#player1'))
    @player2 = new Player($('#player2'))
    @board = new Board
    @ball = new Ball(@canvas)
    @paddleOne = new Paddle([@canvas.width * 0.05, 0])
    # @paddleOne.speed = 10
    @paddleTwo = new Paddle([@canvas.width * 0.95, 0])
    @paddleTwo.speed = 5
    @paddles = [@paddleOne, @paddleTwo]
    @keyboardHandler = new KeyboardHandler

  start: () ->
    @keyboardHandler.bind()
    @lastTime = Date.now()
    requestAnimFrame(@frame)

  frame: () =>
    thisTime = Date.now()
    @deltaTime = (thisTime - @lastTime) / 1000
    @lastTime = thisTime

    @getInput()
    @updateState()
    @draw()

    requestAnimFrame(@frame)

  getInput: () ->
    @paddleOne.input = 0
    if @keyboardHandler.pressed('up')
      @paddleOne.input -= 1
    if @keyboardHandler.pressed('down')
      @paddleOne.input += 1

    @paddleTwo.doAiInput(@ball)

  updateState: () ->
    @ball.update(@deltaTime)

    for paddle in @paddles
      paddle.update()

    # @checkForPaddleWallCollision()
    @checkForPaddleCollision()
    @checkForWallCollision()


  draw: () =>
    @context.clearRect(0, 0, @canvas.width, @canvas.height);
    @ball.draw(@context)
    for paddle in @paddles
      paddle.draw(@context)



  checkLeftPaddleCollision: (paddle) ->
    if @ball.pos[0] < paddle.pos[0]
      if @ball.pos[1] > (paddle.pos[1] + paddle.height) || @ball.pos[1] < paddle.pos[1]
        @player2.updateScore()
        @resetGame()
      else
        overshoot = paddle.pos[0] - @ball.pos[0]
        @ball.pos[0] = paddle.pos[0] + overshoot
        @ball.vel[0] *= -1


  checkRightPaddleCollision: (paddle) ->
    if @ball.pos[0] > paddle.pos[0]
      if @ball.pos[1] > (paddle.pos[1] + paddle.height) || @ball.pos[1] < paddle.pos[1]
        @player1.updateScore()
        @resetGame()
      else
        overshoot = @ball.pos[0] - paddle.pos[0]
        @ball.pos[0] = paddle.pos[0] - overshoot
        @ball.vel[0] *= -1


  checkForPaddleCollision: () ->
    if @ball.vel[0] > 0
      @checkRightPaddleCollision(@paddles[1])
    else if @ball.vel[0] < 0
      @checkLeftPaddleCollision(@paddles[0])


  checkForWallCollision: () ->
    dimensions = [[@ball.size, @canvas.width - @ball.size], [@ball.size, @canvas.height - @ball.size]]
    for dimension, i in dimensions
      if @ball.pos[i] < dimension[0]
        overshoot = dimension[0] - @ball.pos[i]
        @ball.pos[i] = dimension[0] + overshoot
        @ball.vel[i] *= -1
      else if @ball.pos[i] > dimension[1]
        overshoot = @ball.pos[i] - dimension[1]
        @ball.pos[i] = dimension[1] - overshoot
        @ball.vel[i] *= -1

  resetGame: () ->
    @ball = new Ball(@canvas)

jQuery ->
  window.requestAnimFrame = ((callback) ->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
      window.setTimeout callback, 1000 / 60
      return
  )()

  pong = new PongGame
  pong.start()
