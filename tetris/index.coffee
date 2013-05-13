# See - http://jsdo.it/y.teraoka/jVZ3
#       > jsTETRiS
#
# キー操作
#   z: 左回転、x: 右回転。
#   左、右、下矢印：ブロック移動。
#   上矢印：ブロックを一番下まで移動。

'use strict'
# ブロックの種類
TYPE_I = 0
TYPE_O = 1
TYPE_S = 2
TYPE_Z = 3
TYPE_J = 4
TYPE_L = 5
TYPE_T = 6
NUM_BLOCKTYPE = 7      # ブロックの種類数

GAME_W = 200            # ゲーム画面サイズ 横
GAME_H = 320            # ゲーム画面サイズ 縦
GAME_FPS = 30

IMAGE_URL = "image.gif" # 爆発アニメーション
PIECE_W = 12            # グリッドのサイズ
MARGIN_X = PIECE_W * 2  # Field の配置位置
MARGIN_Y = PIECE_W * 4

BLOCK_X0 = MARGIN_X + PIECE_W * 4  # 次ブロックの表示場所
BLOCK_Y0 = 10

FIELD_W = 10           # フィールドのマスの数 横
FIELD_H = 20           # フィールドのマスの数 縦

field = []              # フィールド              field[y][x] = 0  or 1
fPiece = []             # 各ピースを管理する配列  fPiece[y[x] = Piece or null
lineFlag = []           # 行が埋まったか のフラグ lineFlag[y] = true or false

enchant()
game = undefined
playScene = undefined

# meta X, meta Y から実際の表示位置を計算する。
mx2pos = (x) -> (x - 1) * PIECE_W + MARGIN_X
my2pos = (y) -> (y - 1) * PIECE_W + MARGIN_Y

# ブロックタイプの生成
randBlockType = -> Math.floor Math.random() * NUM_BLOCKTYPE

# Piece クラス
class Piece extends Sprite
  constructor: (@mx, @my, @blockType) ->
    super PIECE_W, PIECE_W
    color = ["rgba(255,   0,   0, 0.8)",
             "rgba(  0, 255,   0, 0.8)",
             "rgba(  0,   0, 255, 0.8)",
             "rgba(  0, 255, 255, 0.8)",
             "rgba(255,   0, 255, 0.8)",
             "rgba(255, 255,   0, 0.8)",
             "rgba(128, 128, 255, 0.8)"]
    surface = new Surface(PIECE_W, PIECE_W)
    surface.context.fillStyle = color[@blockType]
    surface.fillRect 0, 0, PIECE_W - 1, PIECE_W - 1
    @image = surface
    @moveTo PIECE_W * @mx, PIECE_W * @my

# ブロッククラス
class Block extends Group
  constructor: (@blockType) ->
    super()  
    @type = blockType
    @dir = 0
    switch blockType
      when TYPE_I
        @bPos = [
          [[1, 1, 1, 1],
           [0, 0, 0, 0],
           [0, 0, 0, 0],
           [0, 0, 0, 0]
          ],
          [[0, 1, 0, 0],
           [0, 1, 0, 0],
           [0, 1, 0, 0],
           [0, 1, 0, 0]
          ]]
      when TYPE_O
        @bPos = [
          [[1, 1],
           [1, 1]
          ]]
      when TYPE_S
        @bPos = [
          [[0, 1, 1],
           [1, 1, 0],
           [0, 0, 0]
          ],
          [[1, 0, 0],
           [1, 1, 0],
           [0, 1, 0]
          ],
          [[0, 1, 1],
           [1, 1, 0],
           [0, 0, 0]
          ],
          [[1, 0, 0],
           [1, 1, 0],
           [0, 1, 0]
          ]]
      when TYPE_Z
        @bPos = [
          [[1, 1, 0],
           [0, 1, 1],
           [0, 0, 0]
          ],
          [[0, 1, 0],
           [1, 1, 0],
           [1, 0, 0]
          ],
          [[1, 1, 0],
           [0, 1, 1],
           [0, 0, 0]
          ],
          [[0, 1, 0],
           [1, 1, 0],
           [1, 0, 0]
          ]]
      when TYPE_J
        @bPos = [
          [[1, 0, 0],
           [1, 1, 1],
           [0, 0, 0]
          ],
          [[0, 1, 0],
           [0, 1, 0],
           [1, 1, 0]
          ],
          [[1, 1, 1],
           [0, 0, 1],
           [0, 0, 0]
          ],
          [[1, 1, 0],
           [1, 0, 0],
           [1, 0, 0]
          ]]
      when TYPE_L
        @bPos = [
          [[0, 0, 1],
           [1, 1, 1],
           [0, 0, 0]
          ],
          [[1, 1, 0],
           [0, 1, 0],
           [0, 1, 0]
          ],
          [[1, 1, 1],
           [1, 0, 0],
           [0, 0, 0]
          ],
          [[1, 0, 0],
           [1, 0, 0],
           [1, 1, 0]
          ]]
      when TYPE_T
        @bPos = [
          [[0, 1, 0],
           [1, 1, 1],
           [0, 0, 0]
          ],
          [[0, 1, 0],
           [1, 1, 0],
           [0, 1, 0]
          ],
          [[1, 1, 1],
           [0, 1, 0],
           [0, 0, 0]
          ],
          [[1, 0, 0],
           [1, 1, 0],
           [1, 0, 0]
          ]]
      else
        throw "Illegal blockType:" + @blockType
    @width = @bPos[0][0].length
    @piece = []

    for i in [0 ... @width]
      for j in [0 ... @width]
        if @bPos[@dir][i][j] is 1
          p = new Piece(j, i, @blockType)
          @addChild p
          @piece.push p

    [@mx, @my] = [0, 0]
    @moveTo BLOCK_X0, BLOCK_Y0
    playScene.addChild this

  # ブロックをフィールドに配置する
  onField: ->
    [@mx, @my] = [5, 1]
    @moveTo mx2pos(@mx), my2pos(@my)

  # ブロックを固定する
  fixBlock: ->
    for i in [0 ... @piece.length]
      [mx, my] = [@piece[i].mx + @mx, @piece[i].my + @my]

      [@piece[i].mx, @piece[i].my] = [mx, my]      
      @piece[i].moveTo mx2pos(mx), my2pos(my)
      field[my][mx] = 1
      fPiece[my][mx] = @piece[i]
      @removeChild @piece[i]
      playScene.addChild fPiece[my][mx]

    playScene.removeChild this

  # 回転チェック
  # 引数:回転方向
  # 1:左回転　-1:右回転
  spinCheck: (dir) ->
    dir_next = (@dir + dir + 4) % @bPos.length
    for i in [0 ... @width]
      for j in [0 ... @width]
        return false  if field[@my + i][@mx + j] is 1  if @bPos[dir_next][i][j] is 1
    true

  # 回転する。
  # 1:左回転　-1:右回転
  spin: (dir) ->
    @dir = (@dir + dir + 4) % @bPos.length
    count = 0
    for i in [0 ... @width]
      for j in [0 ... @width]
        if @bPos[@dir][i][j] is 1
          @piece[count].mx = j
          @piece[count].my = i
          @piece[count].moveTo PIECE_W * j, PIECE_W * i
          count++

    @moveTo mx2pos(@mx), my2pos(@my)

  # 移動可能かチェック
  moveCheck: (dx, dy) ->
    for i in [0 ... @piece.length]
      [mx, my] = [@piece[i].mx + @mx + dx, @piece[i].my + @my + dy]
      # 移動不可能なら false を返す。
      return false  if my > FIELD_H + 1 or my < 0 or mx > FIELD_W + 1 or mx < 0 or field[my][mx] is 1
    true

  # 落下処理
  fall: ->
    if @moveCheck(0, 1)
      @my += 1
      @moveTo mx2pos(@mx), my2pos(@my)
      return true
    false

  # 左右移動
  move: (dir) ->
    if @moveCheck(dir, 0)
      @mx += dir
      @moveTo mx2pos(@mx), my2pos(@my)
      return true
    false

# 揃っている行を削除
lineCheck = ->
  count = 0
  num = 0
  for i in [FIELD_H .. 1]
    lineFlag[i] = false
    for j in [1 .. FIELD_W]
      count++  if field[i][j] is 1
    if count is FIELD_W
      num++
      lineFlag[i] = true      
      # 爆発エフェクト
      for j in [1 .. FIELD_W]
        b = new Blast(j, i)
        playScene.removeChild fPiece[i][j]
        field[i][j] = 0
        fPiece[i][j] = null
    count = 0

  if num > 0
    game.score_point += (num * num * 100)
    game.score_line += num

# 行落下
lineFall = ->
  i = FIELD_H
  while i >= 1
    if lineFlag[i] is false
      i--
    else
      for y in [i .. 2]
        for x in [1 .. FIELD_W]
          field[y][x] = field[y - 1][x]
          fPiece[y][x] = fPiece[y - 1][x]
          fPiece[y][x].moveTo mx2pos(x), my2pos(y)  if field[y][x] is 1
      for x in [1 .. FIELD_W]
        field[1][j] = 0
        fPiece[1][j] = null
      lineFlag[j] = lineFlag[j - 1] for j in [i .. 2]        
      lineFlag[1] = false

# フィールドの背景グリッドを生成して表示する。
createField = ->
  grid = new Surface(PIECE_W * FIELD_W, PIECE_W * FIELD_H)
  grid.context.fillStyle = "#DDD"
  for i in [0 ... FIELD_H] 
    for j in [0 ... FIELD_W]
      grid.fillRect PIECE_W * j, PIECE_W * i, PIECE_W - 1, PIECE_W - 1

  fieldGrid = new Sprite(PIECE_W * FIELD_W, PIECE_W * FIELD_H)
  fieldGrid.image = grid
  [fieldGrid.x, fieldGrid.y] = [MARGIN_X, MARGIN_Y]  
  playScene.addChild fieldGrid

# ゲームの初期設定
initPlay = ->  
  # フィールド
  for y in [0 ... FIELD_H + 2]
    field[y] = []
    field[y][x] = 0 for x in [0 ... FIELD_W + 2]

  field[y][0] = field[y][FIELD_W + 1] = 1 for y in [0 ... FIELD_H + 2]
  field[0][x] = field[FIELD_H + 1][x] = 1 for x in [0 ... FIELD_W + 2]
  
  # 各ピースを管理する配列
  for i in [0 ... FIELD_H + 2]
    fPiece[i] = []
    fPiece[i][j] = null for j in [0 ... FIELD_W + 2]

  # 行の存在フラグ
  lineFlag[i] = false for i in [0 ... FIELD_H]

# 行を削除するときの爆発エフェクト
class Blast extends Sprite
  constructor: (mx, my) ->
    super PIECE_W, PIECE_W
    @moveTo mx2pos(mx), my2pos(my)
    @image = game.assets[IMAGE_URL]
    @time = 0
    @duration = 20
    @frame = 0
    @addEventListener "enterframe", ->
      @time++
      # 爆発アニメーション
      @frame = Math.floor(@time / @duration * 5)
      @remove()  if @time is @duration
    playScene.addChild this

  # 削除
  remove: -> playScene.removeChild this

window.onload = ->
  game = new Game(GAME_W, GAME_H)
  game.fps = GAME_FPS
  # ボタンを登録しておく
  game.keybind 90, "a" # z キー
  game.keybind 88, "b" # x キー

  game.preload IMAGE_URL
  game.score_point = 0
  game.score_line = 0

  game.onload = ->    
    # サーフェイスに四角形の描画メソッドを追加
    Surface::drawRect = (x, y, w, h) ->
      @context.beginPath()
      @context.rect x, y, w, h
      @context.stroke()
    
    # サーフェイスに四角形の塗りつぶしメソッドを追加
    Surface::fillRect = (x, y, w, h) ->
      @context.beginPath()
      @context.rect x, y, w, h
      @context.fill()

    game.playScene = ->
      playScene = new Scene()
      playScene.backgroundColor = "#AAA"
      
      # 初期化処理
      initPlay()      
      # フィールド描画
      createField()      
      # ブロック生成
      nextBlock = new Block(randBlockType())
      block = new Block(randBlockType())
      block.onField()
      game.tick = 0
      rkeyCount = 5
      dkeyCount = 5
      fallFlag = true
      fallCount = GAME_FPS
      fallSpeed = GAME_FPS # 落下スピード(初期値は1秒で落下)
      fallSpan = 5
      
      # プレイ中の定期処理
      playScene.addEventListener Event.ENTER_FRAME, ->
        game.tick++
        rkeyCount--
        dkeyCount--
        fallSpan--
        fallFlag = block.fall()  if game.tick % fallSpeed is 0
        
        # キー入力
        if fallFlag
          if game.input.left & dkeyCount <= 0
            block.move -1
            dkeyCount = 5
          if game.input.right & dkeyCount <= 0
            block.move 1
            dkeyCount = 5
        
        # ブロックを最下層に固定
        if game.input.up
          while block.moveCheck(0, 1)
            block.fall()
            fallFlag = true
            game.score_point += 1
        
        # ブロック落下
        if game.input.down and fallSpan <= 0 and game.tick % fallSpeed > 5
          fallFlag = block.fall()
          if fallFlag
            fallSpan = 5
            game.score_point += 1
        
        # 左回転
        if game.input.a and rkeyCount <= 0
          if block.spinCheck(1)
            block.spin 1
            rkeyCount = 5
        
        # 右回転
        if game.input.b and rkeyCount <= 0
          if block.spinCheck(-1)
            block.spin -1
            rkeyCount = 5
        
        # ブロックが落ちなくなったら
        if fallFlag is false          
          # ブロックが固定された瞬間に行チェックし、そのあとに落下
          if fallCount is GAME_FPS
            block.fixBlock()
            lineCheck()
          lineFall()  if fallCount is 10
          fallCount--
          
          # ブロックが下に落ちることができなくなったら、終了するか、次の新しいブロックを生成する
          if fallCount <= 0
            if field[1][4] is 1 or field[1][5] is 1 or field[1][6] is 1 or field[1][7] is 1              
              # 終了処理をする
              alert "score: " + game.score_point
              game.removeScene playScene
              game.pushScene game.playScene() # ゲーム画面再表示
            else              
              # 次の新しいブロックを生成する
              block = nextBlock
              block.onField()
              nextBlock = new Block(randBlockType())
              fallCount = GAME_FPS
              fallFlag = true
              game.tick++

      playScene

    game.pushScene game.playScene()

  game.start()
