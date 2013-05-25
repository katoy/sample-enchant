enchant()

window.onload = ->
  game_size = 8               # 盤面の一辺のマスの数  (8 以外ｎ整数も指定可能)
  game_board_width = 320      # 盤面表示の一辺 (pxel)
  core = new Core(game_board_width + 10, game_board_width + 10)
  
  reversi = new Reversi core, game_size, Math.floor(game_board_width / game_size)
  this.reversi = reversi
  reversi.setCPUs [new AI_First(), new AI_Random(), new AI_Gain(), new AI_Montecarlo(),
                   new AI_Negamax(2), new AI_Negamax(3), new AI_Negamax(4), new AI_Negamax(5)].slice(0)

  core.onload = ->
    board = reversi.createBoard()
    for stone in board
      core.rootScene.addChild stone
      stone.addEventListener 'touchend', ->
        reversi.exitReplay()  # 再生モードを解除して打った手を記録する。
        reversi.setPlayers()  # プレーヤの設定変化を取り込む。
        reversi.putStone @pos

  core.start()
