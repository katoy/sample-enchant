
# CPU: min-max
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.tyrn     1: black, -1: white
# opts.canPos[] 置くことができる候補 ([0 ... 63] の範囲の値)

class Rating
  @rate9: [
      127, -32,  0, -1, -1, -1,  0, -32, 127,
      -32, -64, -1, -1, -1, -1, -1, -64, -32,
       0,   -1,  0, -1, -1, -1,  0,  -1,   0,
       -1,  -1, -1,  0,  0,  0, -1,  -1,  -1,
       -1,  -1, -1,  0,  0,  0, -1,  -1,  -1,
       -1,  -1, -1,  0,  0,  0, -1,  -1,  -1,
        0,  -1,  0, -1, -1, -1,  0,  -1,   0,
      -32, -64, -1, -1, -1, -1, -1, -64, -32,
      127, -32,  0, -1, -1, -1,  0, -32, 127
  ]

  @rate8: [
      127, -32,  0, -1, -1,  0, -32, 127,
      -32, -64, -1, -1, -1, -1, -64, -32,
       0,   -1,  0, -1, -1,  0,  -1,   0,
       -1,  -1, -1,  0,  0, -1,  -1,  -1,
       -1,  -1, -1,  0,  0, -1,  -1,  -1,
        0,  -1,  0, -1, -1,  0,  -1,   0,
      -32, -64, -1, -1, -1, -1, -64, -32,
      127, -32,  0, -1, -1,  0, -32, 127
  ]

  @rate7: [
      127, -32,  0, -1,  0, -32, 127,
      -32, -64, -1, -1, -1, -64, -32,
        0,  -1,  0, -1,  0,  -1,   0,
       -1,  -1, -1,  0, -1,  -1,  -1,
        0,  -1,  0, -1,  0,  -1,   0,
      -32, -64, -1, -1, -1, -64, -32,
      127, -32,  0, -1,  0, -32, 127
  ]

  @rate6: [
      127, -32,  0,  0, -32, 127,
      -32, -64, -1, -1, -64, -32,
        0,  -1,  0,  0,  -1,   0,
        0,  -1,  0,  0,  -1,   0,
      -32, -64, -1, -1, -64, -32,
      127, -32,  0,  0, -32, 127
  ]

  @rate5: [
      127, -32,  0, -32, 127,
      -32, -64, -1, -64, -32,
        0,  -1,  0,  -1,   0,
      -32, -64, -1, -64, -32,
      127, -32,  0, -32, 127
  ]

  @rate4: [
      127, -32,  -32, 127,
      -32, -64,  -64, -32,
      -32, -64,  -64, -32,
      127, -32,  -32, 127
  ]


  @evalBoard: (board, gameSize, mode) ->
    rate = Rating["rate#{gameSize}"]
    score = 0
    if mode is "gain"
      # 石数だけで評価(終盤の読みきり時)
      score += board[pos]  for pos in [0 ... rate.length]
    else
      # 石の位置に重みをつけて評価
      score += board[pos] * rate[pos] for pos in [0 ... rate.length]
    score

class AI_Negamax extends AI_Base

  constructor: (@depth = 5, @gameSize = 8) ->

  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->

    turn = opts.turn
    num_rest = 0
    #  BoardState[0-64]までの2（置ける場所）を削除
    for i in [0 ... @numStone]
      if boardState[i] is 2
        boardState[i] = 0
      num_rest++ if boardState[i] is 0

    depth = @depth
    mode = ""
    if num_rest <= 10
      mode = "gain"    # 石数だけで評価(終盤の読みきり時)
      depth = num_rest

    [v, posAry] = @negaMax(depth, boardState, turn, mode)
    pos = posAry[Math.floor(Math.random() * posAry.length)]
    console.log "#--- AI_Negamax(depth=#{@depth} turn:#{turn}, pos:#{pos}, v=#{v}"
    pos

  negaMax: (depth, board, turn, mode) ->
    if depth is 0
      return [Rating.evalBoard(board, @gameSize, mode) * turn, null]

    bestV = -32000
    bestPos = {}

    workBoard = board.slice(0)
    canPuts = @checkInvert(workBoard, turn)
    for nextPos in canPuts
      nextBoard = workBoard.slice(0) # clone
      @putStone(nextBoard, nextPos, turn, true)
      evaled = @negaMax(depth - 1, nextBoard, (-1) * turn, mode)
      v = (-1) * evaled[0]
      if bestPos[v]
        bestPos[v].push nextPos
      else
        bestPos[v] = [nextPos]
  
      bestV = v if bestV <= v
    [bestV, bestPos[bestV]]

  

