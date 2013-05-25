
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


  @evalBoard: (board, gameSize) ->
    rate = Rating["rate#{gameSize}"]
    score = 0
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

    # 残り５手になったら最後まで読む。
    depth = @depth
    depth = 5 if num_rest <= 5

    [v, pos] = @negMax(depth, boardState, turn)
    console.log "#--- AI_Negamax(depth=#{@depth} turn:#{turn}, pos:#{pos}"
    pos

  negMax: (depth, board, turn) ->
    if depth is 0
      return [Rating.evalBoard(board, @gameSize) * turn, null]

    bestV = -32000
    bestPos = null

    workBoard = board.slice(0)
    canPuts = @checkInvert(workBoard, turn)
    for nextPos in canPuts
      nextBoard = workBoard.slice(0) # clone
      @putStone(nextBoard, nextPos, turn, true)
      evaled = @negMax(depth - 1, nextBoard, (-1) * turn)
      v = (-1) * evaled[0]
      if bestV <= v
        bestV = v
        bestPos = nextPos
    [bestV, bestPos]

  # alphabeta: (depthm board, turn, alpha, beta) ->
  

