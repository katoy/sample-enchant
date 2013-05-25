
# CPU: 置ける場所候補の先頭を選ぶ。
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# opts.turn     1: black, -1: white
# opts.canPuts[] 置くことができる候補 ([0 ... 63] の範囲の値)
class AI_First
  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->
    if opts.canPuts.length is 0 then null else opts.canPuts[0]
