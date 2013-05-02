
# See
#  http://code.9leap.net/codes/show/4497
#
# 絵合わせ16パズル by @usami_yu
# このコード'game.js'はMITライセンスで公開いたします。
# ご自由に改造してお使いください。

# 以下は、上もソースコードを youicnikato@gmail.com が変更をしたものです。
# 2013-05-01  javascript -> coffeescript に変換した。
#             セルの数を 4x4  固定でなく、可変にした。

$ ->
  
  enchant()                   # enchant.js v0.6.3

  BGM_URL = './sounds/bgm01.wav'                                  # BGM
  IMG_URL = 'images/enchant.png'                                  # パズルの画像 (320 x 320),
  PRELOAD_MATERIAL = ['images/start.png', IMG_URL, BGM_URL]       # スタートロゴ (236 x 48)

  game = null

  # URL の queey 値を得る。
  # See http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values
  getParameterByName = (name, def_val = "") ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regexS = "[\\?&]" + name + "=([^&#]*)"
    regex = new RegExp(regexS)
    results = regex.exec(window.location.search)
    return if (results == null) then def_val else decodeURIComponent(results[1].replace(/\+/g, " "))
  
  #  [0, ... , num -1] の範囲の整数をランダムに返す。
  rand = (num) -> Math.floor((Math.random() * num))

  # 配列中の要素をランダムに返す。
  randInAry = (ary) -> ary[rand(ary.length)]
  
  # クラス: パネル
  class Panel extends Sprite
    constructor: (@conf, @position = 0) ->
      super conf.cell_w, conf.cell_h
      @moved = false

      surface = new Surface conf.cell_w, conf.cell_h
      [sx0, sy0] = [ (position % 4) * conf.cell_w, (Math.floor(position / 4)) * conf.cell_h ]
      surface.draw(game.assets[IMG_URL], sx0, sy0, conf.cell_w, conf.cell_h, 0, 0, conf.cell_w, conf.cell_h)
      surface.context.rect(0, 0, conf.cell_w, conf.cell_h)
      surface.context.strokeStyle = '#666666'
      surface.context.stroke()
      @image = surface

      #onTouchStart: ->
      @on "touchstart", ->
        @tl.fadeTo 0.5, 1  unless @moved

      #onTouchEnd: ->
      @on "touchend", ->
        unless @moved
          @tl.fadeTo 1, 1
          nodes = @parentNode.childNodes
          for j in [ [1, 0], [0, 1], [-1, 0], [0, -1] ]
            break  if @moved
  
            [x, y] = j
            for node in nodes
              pos = node.position
              if pos is @position + x + y * @conf.cell_x
                if node.x is 320
                  node.position = @position
                  @position = pos
                  @moved = true
                  @tl.moveTo( (@position % @conf.cell_x) * @conf.cell_w,
                              Math.floor(@position / @conf.cell_x) * @conf.cell_h,
                              3, QUAD_EASEOUT)
                  @tl.then ->
                    @moved = false
                    game.checkFinish()
                  break

  # クラス: ボード
  class Board
    constructor: (@conf) ->
  
      @panels = []
      for i in [0 ... conf.celles]
        panel = new Panel(conf, i)
        game.rootScene.addChild panel
        @panels.push panel
      @shuffle()

    shuffle: ->
      # たまたま初期状態の戻ってしまっていたら、シャフルしなおす。
      for i in [1...10]
        @do_shuffle()
        break if @checkFinish() is false
  
    # パネルをシャッフルする
    do_shuffle: ->
      # 整列させる
      positions = [0 ... @conf.celles]
      @hideCell_idx = null
      for i in [0 ... @conf.celles]
        @panels[i].position = i
        @panels[i].frame = i
        @panels[i].x = (@panels[i].position % @conf.cell_x) * @conf.cell_w
        @panels[i].y = Math.floor(@panels[i].position / @conf.cell_x) * @conf.cell_h
        @panels[i].moved = false

      # セルの入れ替えを繰り返して、シャフルする
      p = rand @conf.celles   # セルを選ぶ
      count = @conf.shuffle   # シャフル回数
      while count > 0
        [x, y] = randInAry [[1, 0], [0, 1], [-1, 0], [0, -1]]
        unless ((p % @conf.cell_x is 0 and x < 0) or
                (p % @conf.cell_x is (@conf.cell_x - 1) and x > 0) or
                (p < @conf.cell_y and y < 0) or (p > (@conf.celles - @conf.cell_x - 1) and y > 0))
          d = p + x + y * @conf.cell_x
          tmp = positions[p]
          positions[p] = positions[d]
          positions[d] = tmp
          p = d
          count--

      @hideCell_idx = p  # 画面から外すセルの id を設定する。

      # パネルを表示する
      for i in [0 ... @conf.celles]
        @panels[i].position = positions[i]
        @panels[i].x = (@panels[i].position % @conf.cell_x) * @conf.cell_w
        @panels[i].y = Math.floor(@panels[i].position / @conf.cell_x) * @conf.cell_h

      @panels[@hideCell_idx].x = @panels[@hideCell_idx].y = 320 unless @hideCell_idx is null
    
    checkFinish: ->
      isFinish = true
      for i in [0 ... @conf.celles]
        isFinish = false if @panels[i].position isnt parseInt(i, 10)
      return isFinish

    gameover: ->
      @panels[@hideCell_idx].tl.moveTo( (@panels[@hideCell_idx].position % @conf.cell_x) * @conf.cell_w,
                                       Math.floor(@panels[@hideCell_idx].position / @conf.cell_x) * @conf.cell_h,
                                       game.fps / 2, QUAD_EASEOUT)
      @panels[@hideCell_idx].tl.then =>
        endTime = new Date().getTime() - game.startTime
        alert "#{(endTime / 1000).toFixed(2)} 秒でクリア！"
        endScene = createEndScene()
        game.pushScene endScene
        @shuffle()

  # スタート画面の作成
  createStartScene = ->
    scene = new Scene()
    image = new Sprite(236, 48)
    image.image = game.assets['images/start.png']
    [image.x, image.y] = [42, 136]
    scene.addChild(image)

    scene.addEventListener Event.TOUCH_START, (e) ->
      game.popScene()
      game.startTime = new Date().getTime()  # ゲーム開始時間を取得する
    scene

  # 終了画面の作成
  createEndScene = ->
    scene = new Scene()
    image = new Sprite(320, 320)
    image.image = game.assets['images/enchant.png']
    [image.x, image.y] = [0, 0]
    scene.addChild(image)

    scene.addEventListener Event.TOUCH_START, (e) -> game.popScene()
    scene

  # ゲームの設定条件を得る。
  getConf = ->
    # http// ..../inde.html?x=4&y=5&s=1 から x=4, y=4, s=1 の様に値を取得する。
    cell_x = parseInt(getParameterByName("x", 4), 10)           # 横方向の分割数
    cell_y = parseInt(getParameterByName("y", 4), 10)           # 縦方向の分割数
    shuffle_count = parseInt(getParameterByName("s", 100), 10)  # シャッフル回数
    bgm = parseInt(getParameterByName("b", 1), 10)              # シャッフル回数
    # alert("x=#{cell_x}, y=#{cell_y}, s=#{shuffle_count}, b=#{bgm}"

    conf =
      cell_x: cell_x            # 横方向の分割数   #-- Editable
      cell_y: cell_y            # 縦方向の分割数   #-- Editable
      celles: cell_x * cell_y   # セルの総数
      cell_w: 320 / cell_x      # セルの幅
      cell_h: 320 / cell_y      # セルの高さ
      shuffle: shuffle_count    # シャッフル回数   #-- Editable
      bgm: bgm                  # 1: BGM on, 0: BGM off

  #--------- 処理本体 -----------
  game = new Game(320, 320)
  game.fps = 24
  game.preload PRELOAD_MATERIAL
  conf = getConf()

  game.onload = ->
    game.rootScene.backgroundColor = "#000000"
    board = new Board(conf)            # ゲーム画面を作成する
    game.pushScene createStartScene()  # スタート画面を表示、クリックでゲーム開始になる。

    bgm = game.assets[BGM_URL]

    # ゲーム終了の処理。クリックでゲームを再開する。
    game.checkFinish = -> board.gameover() if board.checkFinish()

    $("#bgm-on").click -> setBGM(false)
    $("#bgm-off").click -> setBGM(true)
    $("#shuffle").click ->
      x = $("#cell-x").val()
      y = $("#cell-y").val()
      s = conf.shuffle
      b = if $("#bgm-on").css("display") is "none" then 0 else 1
      window.location = "./index.html?x=#{x}&y=#{y}&s=#{s}&b=#{b}"

    # BGM の再生を on/off する。
    setBGM = (v) ->
      if v
        $("#bgm-on").show()
        $("#bgm-off").hide()
        bgm.play()
        bgm._element.loop = true  if bgm._element
        bgm.src.loop = true       if bgm.src
      else
        $("#bgm-on").hide()
        $("#bgm-off").show()
        bgm.pause()

    $("#cell-x").val(conf.cell_x)
    $("#cell-y").val(conf.cell_y)
    setBGM((conf.bgm is 1))
  
  game.start()  # ゲームを開始する
