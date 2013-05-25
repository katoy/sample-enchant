
# CPU: GAMEを数回繰り返しで勝率が一番高かった手を選ぶ。
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.turn     1: black, -1: white
# opts.canPuts[] 置くことができる候補 ([0 ... 63] の範囲の値)

class AI_Montecarlo extends AI_Base

  dXY = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]  # 隣のマスの相対位置

  numStone: 64
  gameSize: 8
  playCount: 5

  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->

    turn = opts.turn
    ans = null
    wins = {}
    winMax = -1

    #  BoardState[0-64]までの2（置ける場所）を削除
    for i in [0 ... @numStone]
      if boardState[i] is 2
        boardState[i] = 0

    winMax = -1
    wins = {}
    for pos in opts.canPuts
      winCount = 0
      drowCount = 0
      for p in [0 ... @playCount]
        workBoard = boardState.slice(0) # clone
        winer = @playGame(workBoard, turn, pos)
        # console.log "#{pos}:#{p} -> #{winer}"
        winCount++ if winer is turn
        drowCount++ if winer is 0

      winCount = -1 if winCount is 0 and drowCount is 0  
      if wins[winCount]
        wins[winCount].push pos
      else
        wins[winCount] = [pos]
      winMax = winCount if winMax < winCount

    # console.log wins  # for debug
    console.log "#--- AI_Montecarlo(playCount=#{@playCount} turn:#{turn}, pos:#{wins[winMax][0]}"
    wins[winMax][0]

  playGame: (board, turn, pos) ->

    pass = 0 
    while pass < 2
      @putStone(board, pos, turn, true) if pos >= 0

      turn *= (-1)
      canPuts = @checkInvert(board, turn)
      if canPuts.length is 0
        pos = null
        pass++ 
      else
        pos = canPuts[Math.floor( Math.random() * canPuts.length)]
        pass = 0
  
    win = 0
    win += i for i in board
    return 0 if win is 0
    return if win > 0 then 1 else -1

