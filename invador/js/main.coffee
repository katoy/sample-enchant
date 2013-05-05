enchant() # ライブラリの初期化

window.onload = ->
  game = new Game(360, 480)     # 60×480画面(Canvas)を作成
  game.fps = 24                 # フレームレートの設定
  game.preload "images/droid.png", "images/beam.png", "images/ship.png", "images/laser.png", "images/blast.png"
  game.rootScene.backgroundColor = "black"  # ゲームの背景色を黒色に設定

  # スコアを表示するラベルを作成
  score = 0                                # スコアーを格納する変数
  scoreLabel = new Label("SCORE : #{score}")
  scoreLabel.font = "16px Tahoma"
  scoreLabel.color = "white"
  [scoreLabel.x, scoreLabel.y] = [10, 5]
  game.rootScene.addChild scoreLabel

  # ステージを表示するラベルを作成
  stage = 1                                 # ステージ数を格納する変数
  stageLabel = new Label("STAGE #{stage}")
  stageLabel.font = "14px Tahoma"
  stageLabel.color = "white"
  [stageLabel.x, stageLabel.y] = [280, 450]
  stageLabel._style.zIndex = 100
  game.rootScene.addChild stageLabel
  game.end = false

  enemies = []          # 敵を格納する配列
  enemyLasers = []      # 敵のレーザービームを格納する配列
  maxLaser = 40         #
  maxStartLaser = 4     # 一度に出すレーザーの数
  rank = 100            # ランク（難易度)

  # ------------ 敵を描く -----------------
  initEnemies = ->
    enemies = []
    for y in [0 ... 5]
      for x in [0 ... 7]
        enemy = new Sprite(32, 32)
        enemy.image = game.assets["images/droid.png"]
        [enemy.x, enemy.y] = [x * (32 + 10), y * 32 + 30] # 座標
        enemy._style.zIndex = 2                           # Z座標
        enemy.tick = 0                                    # アニメーション用カウンタを初期化
        enemies.push enemy
        game.rootScene.addChild enemy
    null
  
  # ------------ 敵のレーザービームを初期化 -----------------
  initEnemyLasers = ->
    enemeLasers = []
    for i in [0 ... maxLaser]
      laser = new Sprite(4, 16)
      laser.image = game.assets["images/laser.png"]
      [laser.x, laser.y] = [0, -999] # 座標
      laser._style.zIndex = 1 # Z座標
      enemyLasers.push laser
      game.rootScene.addChild laser
    null
  
  game.onload = ->
    # 自機の設定
    fighter = new Sprite(32, 16)
    fighter.image = game.assets["images/ship.png"]
    [fighter.x, fighter.y] = [game.width / 2, game.height - 20]
    fighter._style.zIndex = 1
    game.rootScene.addChild fighter
    # 自機のビーム衝突判定用のスプライト
    fighter_body = new Sprite(24, 10)
    fighter_body._style.zIndex = 1
    game.rootScene.addChild fighter_body

    # ビームの設定
    beam = new Sprite(4, 16)
    [beam.x, beam.y] = [fighter.x + 14, fighter.y - 8]  # 自機の中央, 少し上に設置
    beam.image = game.assets["images/beam.png"]
    beam._style.zIndex = 2
    game.rootScene.addChild beam

    # 爆風の設定
    blast = new Sprite(32, 32)
    blast.image = game.assets["images/blast.png"]
    blast.y = -999
    blast._style.zIndex = 10
    game.rootScene.addChild blast

    game.keybind 32, "a"         # Space キーを A ボタンとして割り当てる

    [enemyDX, enemyDY] = [3, 0]  # 敵全体を移動させるための座標を用意する
    initEnemies()
    initEnemyLasers()

    game.rootScene.addEventListener Event.ENTER_FRAME, ->

      # ------------ 敵のレーザービームを発射する -----------------
      startEnemyLasers = ->
        pointer = Math.floor(Math.random() * rank) # レーザービームを発射する敵の配列位置を求める
        return if pointer >= enemies.length        # 敵が存在しない場合は発射しない
        for i in [0 ... maxStartLaser]
          if enemyLasers[i].y < 0         # 空いているレーザービームの配列要素があるか
            [enemyLasers[i].x, enemyLasers[i].y] = [enemies[pointer].x + 14, enemies[pointer].y + 16] # 座標を設定
            break  # 以後の処理はしない
        null
  
      # ------------ 敵のレーザービームを移動する -----------------
      moveEnemyLasers = ->
        for laser in enemyLasers
          continue if laser.y < 0  # レーザービームがない場合は繰り返しの先頭に
          laser.y += 4                # Y座標の移動処理
          if laser.y > game.height    # 画面外か？
            laser.y = -999            # 発射するレーザービームのY座標を設定
        null

      # ------------ ■ビームを発射済か否か -----------------
      isStartedBeam = -> (beam.y < fighter.y - 8)

      # ------------ ■ビームを発射する -----------------
      startBeam = ->
        beam.y -= 8 if (isStartedBeam() is false) and (game.input.a)  # A ボタンが押されたらビームを発射
  
      # ------------ ビームを移動させる -----------------
      moveBeam = ->
        if isStartedBeam()
          beam.y -= 8                              # ビームを上に移動する
          beam.y = fighter.y - 8 if beam.y < -32  # 画面外かどうか調べる

      # ------------ 自機を移動させる -----------------
      moveFighter = ->
        fighter.x = Math.max(fighter.x - 4, 0) if game.input.left                           # パドルを左に移動
        fighter.x = Math.min(fighter.x + 4, game.width - fighter.width) if game.input.right # パドルを右に移動
        beam.x = fighter.x + 14 unless isStartedBeam()       # ビームは、発射されていない場合は自機と一緒に移動

      # ----------- 敵を移動させる -----------------
      moveEnemies = ->
        reverseFlag = false
        for enemy in enemies
          [enemy.x, enemy.y] = [enemy.x + enemyDX, enemy.y + enemyDY]          
          enemy.tick++
          enemy.frame = enemy.tick >>> 4             # 敵をアニメーションさせる。 (符号なし右シフト)
          # 左右の端に到達したか調べる
          reverseFlag = true  if (enemy.y > 0) and ((enemy.x < 0) or (enemy.x > 330))
          if enemy.y > game.height - 40
            game.end = true
            game.endMessage = "帝国はエイリアンに征服されました。\nスコアは #{score} 点でした"
            return
        # 左右どちらかの端に到達した敵がいた場合の処理
        if reverseFlag
          [enemyDX, enemyDY] = [-enemyDX, 6]
        else
          enemyDY = 0

      # ------------ 敵とビームの接触判定を行う -----------------
      hitCheckBeam = ->
        return  unless isStartedBeam()  # ビームが発射されていない場合は処理しない

        for enemy, idx in enemies
          if beam.intersect(enemy)
            startBlast enemy.x, enemy.y             # 爆風発生
            beam.y = fighter.y - 8                  # 接触した場合はビームを消す
            score++                                 # スコアを加算(1点)
            enemy.parentNode.removeChild(enemy)     # 親ノードから削除
            enemies.splice(idx, 1)                  # 破壊された敵を配列から削除する。
            scoreLabel.text = "SCORE : #{score}"
            if enemies.length < 1                   # 全部倒したか調べる
              setTimeout "initEnemies()", 2000      # 2 秒後に敵を再描画
              maxStartLaser = Math.min(40, maxStartLaser + 4)  # レーザービームの数を 4 つずつ増やす, 最大 40 まで
              rank = Math.max(rank - 10, maxStartLaser) # 難易度調整
              stage++                              # ステージを 1 つ増やす
              stageLabel.text = "STAGE #{stage}"
              return

      # ------------ 自機と敵のレーザービームの接触判定を行う -----------------
      hitCheckLaser = ->
        # 衝突チェック用のスプライトの位置を設定する
        [fighter_body.x, fighter_body.y] = [fighter.x + 4, fighter.y + 6]
        for laser in enemyLasers
          if laser.intersect(fighter_body)
            game.end = true
            game.endMessage = "自機が破壊されました。もう駄目です。\nスコアは #{score} 点でした"
            return    # 以後の処理は行わないようにする

      # 爆発開始処理
      startBlast = (sx, sy) ->
        [blast.x, blast.y] = [sx, sy]  # 爆風発生
        blast.frame = 0                # 爆風のアニメーションを最初の画像に

      # 爆発アニメーション処理
      moveBlast = ->
        if blast.y > 0    # 爆風がない場合は何もしない
          blast.frame++
          # 爆風の枚数は8枚なので、それ以上の場合は爆風処理をしない
          blast.y = -999  if blast.frame is 8

      if (game.end)
        game.rootScene.backgroundColor = "red"
        game.stop()
        alert game.endMessage
        return
      startBeam()         # ビームの発射を確認
      moveBeam()          # ビームを移動させる
      moveFighter()       # 自機を移動させる（キーボード対応）
      moveEnemies()       # 敵を移動させる
      startEnemyLasers()  # 敵のレーザービームを発射する
      moveEnemyLasers()   # 敵のレーザービームを移動させる
      moveBlast()         # 爆発の処理を行う
      hitCheckBeam()      # ビームと敵の接触判定
      hitCheckLaser()     # 敵のレーザービームと自機の接触判定

  game.start()    # game.debug()
  window.initEnemies = initEnemies
