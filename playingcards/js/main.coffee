enchant()
window.onload = ->
  core = new Core(PlayingCards.WIDTH * 13, PlayingCards.HEIGHT * 5)
  # core = new Core(1000, 500)
  
  PCard = new PlayingCards(core)

  core.onload = ->
    for s in [1 .. 4]
     for n in [1 .. 13]
       card = PCard.getSprite((s - 1) * 13 + n)
       card.x = PlayingCards.WIDTH * (n - 1)
       card.y = PlayingCards.HEIGHT * (s - 1)
       #card.scaleX = 0.6;                
       #card.scaleY = 0.6;
       core.rootScene.addChild card
       # カードをクリックしたら、裏返す
       card.addEventListener 'touchend', ->
         @frame = if @frame is 0 then 1 else 0
         alert "cliked #{PCard.getName(@data)}"
  
    card = PCard.getSprite(PlayingCards.JOKER)
    card.x = PlayingCards.WIDTH * 0
    card.y = PlayingCards.HEIGHT * 4
    card.frame = 1
    core.rootScene.addChild card
    # カードをクリックしたら、裏返す
    card.addEventListener 'touchend', ->
      @frame = if @frame is 0 then 1 else 0
      alert "cliked #{PCard.getName(@data)}"

  core.start()
