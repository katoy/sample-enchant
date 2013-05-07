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
          alert "clicked #{@name}"
  
    card = PCard.getSprite(PlayingCards.JOKER)
    card.x = PlayingCards.WIDTH * 0
    card.y = PlayingCards.HEIGHT * 4
    card.frame = 1
    core.rootScene.addChild card
    # カードをクリックしたら、裏返す
    card.addEventListener 'touchend', ->
      @frame = if @frame is 0 then 1 else 0
      alert "clicked #{@name}"

    deck = PCard.deck()
    console.log(deck.join(","))
    deck = PCard.shuffle(deck)
    console.log(deck.join(","))

    console.log "C1  = #{PCard.name2num("C1")}"
    console.log "CK  = #{PCard.name2num("CK")}"
    console.log "SK  = #{PCard.name2num("SK")}"
    console.log "C01 = #{PCard.name2num("C01")}"
    console.log "C13 = #{PCard.name2num("C13")}"
    console.log "S13 = #{PCard.name2num("S13")}"
    console.log "JOKER = #{PCard.name2num("JOKER")}"

    console.log " 1  = #{PCard.num2name(1)}"
    console.log "13  = #{PCard.num2name(13)}"
    console.log "52  = #{PCard.num2name(52)}"
    console.log "53  = #{PCard.num2name(53)}"

    console.log " 1  = #{PCard.num2longname(1)}"
    console.log "13  = #{PCard.num2longname(13)}"
    console.log "52  = #{PCard.num2longname(52)}"
    console.log "53  = #{PCard.num2longname(53)}"
  core.start()
