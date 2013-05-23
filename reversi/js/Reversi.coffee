###
リバーシ。
盤面のクラスと、単純なコンピュータ試行ルーチン２つ。
###

class Reversi
  @STONE_IMAGE_WIDTH: 50        # 画像のサイズ
  @STONE_IMAGE_HEIGHT: 50       #
  @VOID: 'images/void.jpg'      # 画像: 空マス
  @BLACK: 'images/black.jpg'    # 画像: 黒
  @WHITE: 'images/white.jpg'    # 画像: 白
  @HINT_B: 'images/hintB.jpg'   # 画像: 黒が置ける候補
  @HINT_W: 'images/hintW.jpg'   # 画像: 白が置える候補

  dXY = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]  # 隣のマスの相対位置

  # @gemSize ゲーム版の一辺のマスの数
  # @stoneDispWidth 表示する石のサイズ
  constructor: (core, @gameSize = 8, @stoneDispWidth = 1.0) ->
    @fps = core.fps
    @num_stone = @gameSize * @gameSize
    @scale = @stoneDispWidth / Reversi.STONE_IMAGE_WIDTH
    @SPRITES = []
    @BoardState = []                      # 1: 先手の石, -1: 後手の石, 0:空
    @turn = 1                             # 1:先手,  -1:後手
    @start = false                        # play 中 or Not
    @BlackStone = @WhiteStone = 0         # 石の数
    @players = [0, 0]                     # 0: プレーヤー, 1: CPU_0, 2: CPU_1
    @records = []                         # play の記録。[0...64] 打った位置、"p": パス
    @play_pos = 0                         # 再生した手数 @records[0] ... @records[@play_@pos -1] までが再生されている。
    @replay_mode = false                  # 再生中 or Not
    core.preload([Reversi.VOID, Reversi.BLACK, Reversi.WHITE, Reversi.HINT_B, Reversi.HINT_W]) # 画像のロード

  # コンピュータの思考ルーチンを登録する。
  setCPUs: (@cpus) ->
  # (x,  y) のセルは 盤内におさまっているか判定する。
  isInBoard: (x, y) -> (x >= 0) and (x < @gameSize) and (y >= 0) and (y < @gameSize)
  # (x, y) を  [0 ... 64] にマップする。
  xy2pos: (x, y) ->  x + y * @gameSize
  # [0 ... 64] を (x, y) にマップする。
  pos2xy : (pos) -> [pos % @gameSize, Math.floor(pos / @gameSize)]

　# マス目１つを１つの Sprite で表示する。
  # pos: マス目の ID。[0 ..64] の範囲の値
  _getSprite : (pos) ->
    [width, height] = [Reversi.STONE_IMAGE_WIDTH, Reversi.STONE_IMAGE_HEIGHT]
    stone = new Sprite(width, height)
    stone.image = new Surface(width * 5, height)
    stone.pos = pos
    [x, y] = @pos2xy(pos)
    stone.frame = 0
    stone.scale(@scale, @scale)
    [stone.x, stone.y] =[ x * width * @scale, y * height * @scale]

    # 黒の描画 (frame = 0)
    stone.image.draw enchant.Game.instance.assets[Reversi.VOID],   0, 0, width, height, 0, 0, width, height
    # 空の描画 (frame = 1)
    stone.image.draw enchant.Game.instance.assets[Reversi.BLACK],  0, 0, width, height, width, 0, width, height
    # 白の描画 (frame = 2)
    stone.image.draw enchant.Game.instance.assets[Reversi.WHITE],  0, 0, width, height, width * 2, 0, width, height
    # ヒント黒の描画 (frame = 3)
    stone.image.draw enchant.Game.instance.assets[Reversi.HINT_B], 0, 0, width, height, width * 3, 0, width, height
    # ヒント白の描画 (frame = 4)
    stone.image.draw enchant.Game.instance.assets[Reversi.HINT_W], 0, 0, width, height, width* 4, 0, width, height
    stone

  createBoard: ->
    @SPRITES = []
    @SPRITES.push(@_getSprite(pos)) for pos in [0 ... @num_stone]
    @firstScene()  #  4 つの石を初期配置する。
    @SPRITES

  # 4 つの石を初期配置する。
  firstScene: ->
    for i in [0 ... @num_stone]
      @SPRITES[i].frame = 0 # 空のマス目表示にする
      @BoardState[i] = 0    # 1: 先手の石, -1: 後手の石, 0:空

    first = @gameSize * (Math.floor(@gameSize/2 -1)) + Math.floor(@gameSize/2 - 1)
    @SPRITES[first].frame = @SPRITES[first + @gameSize + 1].frame = 2  # 2: white
    @BoardState[first] = @BoardState[first + @gameSize + 1] = -1       # -1: 後手
    @SPRITES[first + 1].frame = @SPRITES[first + @gameSize].frame = 1  # 1: black
    @BoardState[first + 1] = @BoardState[first + @gameSize] = 1        # 1: 先手
    @BlackStone = @WhiteStone = 2                                      # 白、黒それぞれ 2 つ
    document.myForm.black.value = document.myForm.white.value = 2      # 画面に石数を表示する

  # 置ける場所を検索する。
  checkInvert: ->
    canPuts = []   # 置ける場所 (pos) を格納する配列
    for pos in [0 ... @num_stone]
      if @BoardState[pos] is 0
        [x, y] = @pos2xy(pos)
        for i in [0 ... dXY.length]
          [dx, dy] = [dXY[i][0], dXY[i][1]]
          [c, ddx, ddy] = [1, dx, dy]
          while @isInBoard(x + ddx, y + ddy) and (@BoardState[@xy2pos(x + ddx, y + ddy)] is (-1 * @turn))
            [c, ddx, ddy] = [c + 1, ddx + dx, ddy + dy]

          if (@BoardState[@xy2pos(x + ddx,  y + ddy)] is @turn) and (c > 1)
            @BoardState[pos] = 2
            @SPRITES[pos].frame = (if (@turn > 0) then 3 else 4)
            canPuts.push pos
            break
    canPuts

  setStone: (stone, opts = {delay: 0, turn:@turn}) ->
    next_frame = if (opts.turn is 1) then 1 else 2
    if (@players[0] > 0 and @players[1] > 0) or (@replay_mode is true)
      stone.frame = next_frame
    else
      stone.tl.delay(opts.delay * @fps).then ->
        @frame = next_frame
  
  turnStone: (stone, opts = {delay:0.4, turn:@turn}) ->
    # @SPRITES[pos].frame = (if (@turn > 0) then 1 else 2)
    next_frame = if (opts.turn is 1) then 1 else 2
    if (@players[0] > 0 and @players[1] > 0) or (@replay_mode is true)
      stone.frame = next_frame
    else
      stone.tl.delay(opts.delay * @fps).scaleTo(0.1 * @scale, @scale, 0.2 * @fps).then ->
        @frame = next_frame
      .scaleTo(@scale, @scale, @fps * 0.2)

  # 置いたとき
  putStone: (pos, opts = {delay:0, turn:@turn}) ->
    unless @start
      setMessage "[スタート！]を押してください！"
    else if @BoardState[pos] isnt 2 and @replay_mode is false
      setMessage "置けません！"
    else
      #  BoardState[0-64]までの2（置ける場所）を削除
      for i in [0 ... @num_stone]
        if @BoardState[i] is 2
          @BoardState[i] = 0
          @SPRITES[i].frame = 0
    
      # pos を座標に換算
      [x, y] = @pos2xy(pos)
      setMessage "(#{x + 1}, #{y + 1}) に置きました！"
      @recordPlay [@turn, x + 1, y + 1]   # プレーを記録
     
      # ヒックリ返す石のカウント（c が返す数）
      for i in [0 ... dXY.length]
        [dx, dy] = [dXY[i][0], dXY[i][1]]
        [c, ddx, ddy] = [1, dx, dy]
        while @isInBoard(x + ddx, y + ddy) and (@BoardState[@xy2pos(x + ddx, y + ddy)] is (@turn * -1))
          [c, ddx, ddy] = [c + 1, ddx + dx, ddy + dy]

        if @BoardState[@xy2pos(x + ddx, y + ddy)] is @turn
          [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]
  
          while c > 0
            @BoardState[@xy2pos(x + ddx, y + ddy)] = @turn
            # 石数変更
            if @turn > 0
              @BlackStone++
              @WhiteStone--
            else
              @WhiteStone++
              @BlackStone--
            # @SPRITES[@xy2pos(x + ddx, y + ddy)].frame = (if (@turn > 0) then 1 else 2)
            @turnStone @SPRITES[@xy2pos(x + ddx, y + ddy)], {delay: opts.delay + 0.3, turn: @turn}
            [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]

      @BoardState[pos] = @turn
      alert(pos) unless @SPRITES[pos]
      @setStone @SPRITES[pos], {delay:opts.delay, turn:@turn}

      # 石数を変更する（置いた石）
      if @turn > 0
        @BlackStone++
      else
        @WhiteStone++
      # 石数を画面に表示する
      document.myForm.black.value = @BlackStone
      document.myForm.white.value = @WhiteStone

      @turn *= -1
      canPuts = @checkInvert()
      if canPuts.length is 0
        setMessage(if @turn > 0 then "先手はパスです！" else "後手はパスです！")
        @recordPlay [@turn, 0, 0]   # "PASS" を記録

        @turn *= -1
        canPuts = @checkInvert()
        if canPuts.length is 0     # 先手、後手 共に打つ手が無ければゲームオーバー。
          setMessage "終了"
          setStatMessage "はじめから"
          return
    
      # CPU の手
      if ((@turn is 1 and @players[0] > 0) or (@turn is -1 and @players[1] > 0)) and (@replay_mode is false)
        cpuID = if @turn is 1 then @players[0] - 1 else @players[1] - 1
        cpuPut = @cpus[cpuID].play(@BoardState.slice(0), {turn:@turn, canPuts:canPuts.slice(0)})  # slice(0) をつかって clone したものを渡す。
        @putStone(cpuPut, {delay:opts.delay + 0.8, turn:@turn}) if cpuPut != null

  # 打った手 (turn, x, y) を記録する。(turn in [1, -1], x in [1..8], y in [1..8])
  recordPlay: (pos) ->
    unless @replay_mode
      @records = @records.slice(0, @play_pos)  if @play_pos isnt @records.length
      @records.push pos
      @play_pos = @records.length

  # 譜記の再生モードを抜ける。
  exitReplay: -> @replay_mode = false

  # 譜記を再生する。
  replay: (hands, len) ->
    @replay_mode = true
    @firstScene()
    @turn = 1
    len = 0 if len < 0
    len = hands.length if len > hands.length

    if len > 0
      for i in [0 ... len]
        pos = (hands[i][1] - 1) + (hands[i][2] - 1) * @gameSize
        # PASS でなければ再生をする。
        if pos >= 0
          @turn =  hands[i][0]
          @putStone pos
      
    setMessage "初期画面を表示しています。" if (len <= 0)
    @play_pos = len
    @replay_mode = false

  # 譜記を移動する。
  historyTop: -> @replay(@records, 0)                    # 先頭へ
  historyLast: -> @replay(@records, @records.length)     # 末尾へ
  history: (step) -> @replay(@records, @play_pos + step) # 現在の位置から setp 数移動する。
  
  # 譜記録の入出力
  savePlay: ->
    alert JSON.stringify({black: @BlackStone, white: @WhiteStone, play:@records})
  loadPlay: ->
    console.log "未実装"

  # プレイヤー設定
  setPlayers: ->
    @players = [document.myForm.first.selectedIndex, document.myForm.second.selectedIndex]

  # ゲーム開始
  gameStart: ->
    unless @start
      @setPlayers()
      @start = true
      @records = []
      @play_pos = 0
      setMessage "ゲームスタート！！"
      setStatMessage "やりなおす"
      canPut = @checkInvert()
      # CPU が打つ
      if @players[0] > 0 and canPut.length > 0
        @putStone(@cpus[@players[0] - 1].play(@BoardState.slice(0), {turn:@turn, canPuts:canPut.slice(0)})) # slice(0) をつかって clone したものを渡す。
    else
      # やりなおす
      if confirm("本当にやり直しますか？")
        @firstScene()
        @turn = 1
        @start = false
        setStatMessage "スタート！"
        setMessage "やりなおしました"

  setMessage = (msg) -> document.myForm.myMsg.value = msg
  setStatMessage = (msg) -> document.myForm.start.value = msg
