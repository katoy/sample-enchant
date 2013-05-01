enchant()                     # enchant.js v0.6.3

window.onload = ->

  [GAME_W, GAME_H] = [320, 320]
  RESOURCE = ['chara1.png']    # 画像ファイル
  SPLITE_W = 32                # スプライトの幅
  SPLITE_H = 32                # スプライトの高さ
  SPLITE_BASES = [5, 10]       # 基本のスプライトの index
  NUM_BEAR = 10                # 生成するスプライトの数

  # [m, ... m] の中からランダムな値を返す
  rand = (n, m) -> n + Math.floor(Math.random() * (m - n + 1))

  # ary の中からランダムな値を返す
  randInAry = (ary) -> ary[Math.floor(Math.random() * ary.length)]

  # Bear クラス
  class Bear extends Sprite
    constructor: (x = 0, y = 0, @dx = 0, @dy = 0, @splite_base = 5) ->
      super SPLITE_W, SPLITE_H
      [@x, @y] = [x, y]
      @image = game.assets[RESOURCE]
      @frame = @splite_base
      game.rootScene.addChild @
  
      # フレーム更新のときの処理
      @on "enterframe", ->
        d = (@dx * @dx + @dy * @dy)
        @frame = @splite_base + if (d < 0.01) then 0 else @age % 3
        @dx *= 0.98
        @dy *= 0.98
        @reflect()

        [@x, @y] = [@x + @dx, @y + @dy]
        @x = 0 if @x < 0
        @x = GAME_W - SPLITE_W if @x > GAME_W - SPLITE_W
        @y = 0 if @y < 0
        @y = GAME_H - SPLITE_H if @y > GAME_H - SPLITE_H
  
        @.scaleX = if @dx < 0 then -1 else 1
        console.log "#{@dx}, #{@dy}"

      # タッチしたときの処理
      @on "touchstart", ->
        # game.rootScene.removeChild @
        [@dx, @dy] = [rand(-10, 10), rand(-10, 10)]
        @.scaleX = if @dx < 0 then -1 else 1
        @reflect()

    # 壁での反射処理
    reflect: ->
      if (GAME_W - SPLITE_W <= @x) or (@x <= 0)
        @dx *= -0.4
        @.scaleX *= -1
      if (GAME_H - SPLITE_H <= @y) or (@y <= 0)
        @dy *= -0.4

  game = new Game(GAME_W, GAME_H)
  game.fps = 10
  game.preload RESOURCE
  game.rootScene.backgroundColor = 'rgb(240, 240, 240)'
  game.onload = ->
    # Bear の生成
    bears = []
    for i in [1 .. NUM_BEAR]
      [x,  y]  = [rand(0, GAME_W - SPLITE_W), rand(0, GAME_H - SPLITE_H)]
      [dx, dy] =  [rand(-10, 10), rand(-10, 10)]
      frame = randInAry(SPLITE_BASES)
      bear = new Bear(x, y, dx, dy, frame)
      bears.push bear

  game.start()
