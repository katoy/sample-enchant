enchant() # ライブラリの初期化

window.onload = ->
  SPEED_INIT = 2     # ボールのスピード係数の初期値
  SPEED_MAX = 5      # ボールのスピード係数の最大値

  game = new Game(240, 320)  # 240×320画面(Canvas)を作成
  game.fps = 24              # フレームレートの設定。
  game.preload ["images/pad.png", "images/ball.png", "images/block.png", "sound/se1.mp3", "sound/se2.mp3"]
  game.rootScene.backgroundColor = "blue" # ゲームの背景色を青色に設定

  game.onload = ->
    score = 0     # スコアを入れる変数
    mySounds = [game.assets["sound/se1.mp3"], game.assets["sound/se2.mp3"]]  # [ブロックの消去音, パドルでの反射音]

    # スコアを表示するラベルの作成
    scoreLabel = new Label("SCORE : #{score}")
    scoreLabel.font = "16px Tahoma"
    scoreLabel.color = "white"
    [scoreLabel.x, scoreLabel.y] = [10, 5]  # 座標
    game.rootScene.addChild scoreLabel

    # ボールの設定
    ball = new Sprite(16, 16)
    ball.image = game.assets["images/ball.png"]
    [ball.x, ball.y] = [0, 130]      # 座標
    [ball.dx, ball.dy] = [1.5, 2.5]  # X 方向の移動量, Y 方向の移動量
    ball.speed = SPEED_INIT          # ボールの最初の速さ
    game.rootScene.addChild ball

    # パドルの設定
    pad = new Sprite(32, 16)
    pad.image = game.assets["images/pad.png"]
    [pad.x, pad.y] = [game.width / 2, game.height - 40]     # 座標
    game.rootScene.addChild pad

    # ブロックを格納する配列
    blocks = []

    # ------------ ブロックを描く -----------------
    resetBlocks = ->
      blocks = []
      # ボールの設定を縦横の数だけ繰り返し生成
      for y in [0... 5]
        for x in [0 ... 7]
          blk = new Sprite(24, 12)
          blk.image = game.assets["images/block.png"]
          blk.frame = 0
          [blk.x, blk.y] = [x * 32 + 12, y * 18 + 30] # 座標
          game.rootScene.addChild blk
          blocks.push blk
      null

    # フレームイベントが発生したら処理
    game.rootScene.addEventListener Event.ENTER_FRAME, ->
  
      # ------------ ■ボールを移動させる -----------------
      moveBall = ->
        ball.x = ball.x + ball.dx * ball.speed     # X 方向の移動量を加算
        ball.y = ball.y + ball.dy * ball.speed     # Y 方向の移動量を加算
        # 画面外かどうか調べる
        ball.dx = -ball.dx  if (ball.x < 0) or (ball.x > (game.width - ball.width))
        ball.dy = -ball.dy  if ball.y < 0
        # ボールが下まで行ったらゲームオーバー
        if ball.y > game.height
          game.stop()
          alert "スコアは #{score} 点でした"
  
      # ------------ ■パドルを移動させる -----------------
      movePaddle = ->
        n = game.input.analogX / 4
        n = -6  if game.input.left       # パドルを左に移動
        n = 6  if game.input.right       # パドルを右に移動
        n = 0  if isNaN(n)               # パソコン用の対応
        pad.x = pad.x + n                # パドルを左に移動
        pad.x = 0  if pad.x < 0          # 左端かどうか調べる
        pad.x = game.width - pad.width  if pad.x > (game.width - pad.width) # 右端かどうか調べる
    
      # ------------ ■パドルとボールの接触判定を行う -----------------
      hitCheck_paddle_ball = ->
        if pad.intersect(ball)
          ball.dy = -ball.dy                        # 接触した場合はボールのY方向の移動量を逆にする
          ball.y = pad.y - ball.height - 1          # うまく跳ね返るように調整
          score += 10                               # スコアを加算(10点)
          ball.speed = ball.speed + 0.025           # 一回跳ね返すごとに移動速度を速くする。SPEED_MAX まで。
          ball.speed = SPEED_MAX  if ball.speed > SPEED_MAX
          mySounds[1].play()                        # 効果音を鳴らす
  
      # ------------ ■ブロックとボールの接触判定を行う -----------------
      hitCheck_block_ball = ->
        for blk, idx in blocks
          if ball.intersect(blk)
            ball.dy = -ball.dy               # 接触した場合はボールのY方向の移動量を逆にする
            blk.parentNode.removeChild(blk)  # 親ノードから削除
            blocks.splice(idx, 1)            # ブロックの配列から削除する。
            score += 5                       # スコアを加算(5点)
            mySounds[0].play()               # 当たった場合には効果音を鳴らす
            break
  
        # 全部消えたなら、ブロックを再描画する。
        resetBlocks()  if blocks.length < 1
  
      moveBall()
      movePaddle()
      hitCheck_paddle_ball()
      hitCheck_block_ball()
      scoreLabel.text = "SCORE : #{score}"

    resetBlocks()  # ブロックを描く
    # 傾きセンサーを設定(Android/iOS共通)
    window.addEventListener "deviceorientation", ((evt) -> game.input.analogX = evt.gamma), false

  game.start()   # game.debug()   # ゲーム処理開始
