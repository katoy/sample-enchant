
# CPU: 置ける場所候補の先頭を選ぶ。
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.tyrn     1: black, -1: white
# opts.canPos[] 置くことができる候補 ([0 ... 63] の範囲の値)
class AI_Gain

  dXY = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]  # 隣のマスの相対位置

  numStone: 64
  gameSize: 8

  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->
    turn = opts.turn
    ans = null
    gains = {}
    gainMax = -1

    #  BoardState[0-64]までの2（置ける場所）を削除
    for i in [0 ... @numStone]
      if boardState[i] is 2
        boardState[i] = 0
    
    for pos in opts.canPuts
      score = @putStone(boardState, pos, turn, false)
      gainMax = score if gainMax < score
      if gains[score]
        gains[score].push pos
      else
        gains[score] = [pos]
  
    console.log gains  # for debug
    return null if gainMax <= 0 
    gains[gainMax][Math.floor(Math.random() * gains[gainMax].length)]

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

      if boardState[@xy2pos(x + ddx, y + ddy)] is turn
        [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]
  
        while c > 0
          boardState[@xy2pos(x + ddx, y + ddy)] = turn if doTurn
          [c, ddx, ddy] = [c - 1, ddx - dx, ddy - dy]
          gain++

    boardState[pos] = turn if doTurn
    gain
