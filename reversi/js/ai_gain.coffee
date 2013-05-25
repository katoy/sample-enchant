
# CPU: hヒックリ返せる石が一番多い手を選ぶ。
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.turn     1: black, -1: white
# opts.canPuts[] 置くことができる候補 ([0 ... 63] の範囲の値)
class AI_Gain extends AI_Base

  constructor: ->

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
  
    console.log "#--- AI_gains "# for debug
    console.log gains  # for debug
    pos = if gainMax <= 0 then nyll else gains[gainMax][Math.floor(Math.random() * gains[gainMax].length)]
    console.log "#--- AI_Gain turn:#{turn}, pos:#{pos}"
    pos