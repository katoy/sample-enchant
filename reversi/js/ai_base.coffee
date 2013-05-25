
# CPU: 
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.turn     1: black, -1: white
# opts.canPuts[] 置くことができる候補 ([0 ... 63] の範囲の値)
class AI_Base

  dXY = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]  # 隣のマスの相対位置

  numStone: 64
  gameSize: 8

  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->

  # (x, y) を  [0 ... 64] にマップする。
  xy2pos: (x, y) ->  x + y * @gameSize
  # [0 ... 64] を (x, y) にマップする。
  pos2xy : (pos) -> [pos % @gameSize, Math.floor(pos / @gameSize)]
  # (x,  y) のセルは 盤内におさまっているか判定する。
  isInBoard: (x, y) -> (x >= 0) and (x < @gameSize) and (y >= 0) and (y < @gameSize)
  
  # 手を打つ。
  # ヒックリ返る石の数を返す (置いた石は含めない)
  putStone: (boardState, pos, turn, doTurn = false) ->
    return -1 if boardState[pos] isnt 0  # can not put 

    turnX = turn * (-1)
    gain = 0
    # pos を座標に換算
    [x, y] = @pos2xy(pos)
    # ヒックリ返す石のカウント（c が返す数）
    for i in [0 ... dXY.length]
      [dx, dy] = [dXY[i][0], dXY[i][1]]
      [c, ddx, ddy] = [1, dx, dy]
      while @isInBoard(x + ddx, y + ddy) and (boardState[@xy2pos(x + ddx, y + ddy)] is turnX)
        [c, ddx, ddy] = [c + 1, ddx + dx, ddy + dy]

      if @isInBoard(x + ddx, y + ddy)  and boardState[@xy2pos(x + ddx, y + ddy)] is turn
        [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]
  
        while c > 0
          boardState[@xy2pos(x + ddx, y + ddy)] = turn if doTurn
          [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]
          gain++

    boardState[pos] = turn if doTurn
    gain

  # 置ける場所を検索する。
  checkInvert: (board, turn) ->
    canPuts = []   # 置ける場所 (pos) を格納する配列
    turnX = (-1) * turn 
    for pos in [0 ... @numStone]
      if board[pos] is 0
        [x, y] = @pos2xy(pos)
        for i in [0 ... dXY.length]
          [dx, dy] = [dXY[i][0], dXY[i][1]]
          [c, ddx, ddy] = [1, dx, dy]
          while @isInBoard(x + ddx, y + ddy) and (board[@xy2pos(x + ddx, y + ddy)] is turnX)
            [c, ddx, ddy] = [c + 1, ddx + dx, ddy + dy]

          if @isInBoard(x + ddx, y + ddy) and (board[@xy2pos(x + ddx,  y + ddy)] is turn) and (c > 1)
            canPuts.push pos
            break
    canPuts
