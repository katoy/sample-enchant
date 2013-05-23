enchant()

# CPU: 置ける場所候補の先頭を選ぶ。
# boardState[]  配列 [0 ... 63]でマス目の状態を保持している。 0: 空, -1: 白, 1: 黒
# canPos[]      置くことができる候補 ([0 ... 63] の範囲の値)
class AI_001
  # 次に打つ手 [0 ... 64] を返す。
  play : (boardState, opts = {}) ->
    if opts.canPuts.length is 0 then null else opts.canPuts[0]

# CPU: 置ける場所候補からランダムに選ぶ
class AI_002
  # 次に打つ手 [0 ... 64] を返す。
  play: (boardState, opts ={}) ->
    if opts.canPuts.length is 0 then null else opts.canPuts[Math.floor(Math.random() * opts.canPuts.length)]

window.onload = ->
  game_size = 8               # 盤面の一辺のマスの数  (8 以外ｎ整数も指定可能)
  game_board_width = 320      # 盤面表示の一辺 (pxel)
  core = new Core(game_board_width + 10, game_board_width + 10)
  
  reversi = new Reversi core, game_size, Math.floor(game_board_width / game_size)
  this.reversi = reversi
  reversi.setCPUs [new AI_001(), new AI_002()].slice(0)

  core.onload = ->
    board = reversi.createBoard()
    for stone in board
      core.rootScene.addChild stone
      stone.addEventListener 'touchend', ->
        reversi.exitReplay()  # 再生モードを解除して打った手を記録する。
        reversi.setPlayers()  # プレーヤの設定変化を取り込む。
        reversi.putStone @pos

  core.start()
