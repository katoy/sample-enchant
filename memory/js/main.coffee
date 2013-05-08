$ ->
  enchant()

  core = new Core(PlayingCards.WIDTH * 13,PlayingCards.HEIGHT * 5)
  # core = new Core(1000, 500)
  
  PCard = new PlayingCards(core)

  click_count = 0
  opened_name = []
  cards = []

  swapCards = (c1, c2) ->

  moveToDeck = (card) ->
    card.parentNode.removeChild(card)
    card.tl.moveTo(PlayingCards.WIDTH * 6, PlayingCards.HEIGHT * 4, 12)
    core.rootScene.addChild card

  isOnField = (card) ->
    (card.y isnt PlayingCards.HEIGHT * 4)

  resetCards = ->
    click_count = 0
    for c in cards
      s = PCard.getSuit(c.data)
      n = PCard.getNumber(c.data)
      x = PlayingCards.WIDTH * (n - 1)
      y = PlayingCards.HEIGHT * (s - 1)
      c.tl.moveTo(x, y, 12)
      if c.frame isnt 0
        c.tl.scaleTo(0.1, 1, 4)
        c.tl.then ->  @frame = 0
        c.tl.scaleTo(1.0, 1, 4)

    null

  shuffleCards = ->
    cards = PCard.shuffle(cards)
    p = 0
    for c in cards
      if isOnField(c)
        x = (p % 13) * PlayingCards.WIDTH
        y = Math.floor(p / 13) * PlayingCards.HEIGHT
        c.tl.moveTo(x, y, 12)
        p++
    null

  turnCards = (flag) ->
    for c in cards
      if isOnField(c) and c.frame isnt flag
        c.tl.scaleTo(0.1, 1, 4)
        c.tl.then ->  @frame = flag
        c.tl.scaleTo(1.0, 1, 4)
    null

  turndownCards = -> turnCards(1)

  removeTurnuped = ->
    for c in cards
      moveToDeck(c) if isOnField(c) and (c.frame is 0) and (c.name in opened_name)
    null
          
  click_action = (card) ->

    return if opened_name.length > 1
    return if card.frame is 0

    click_count++
    card.tl.scaleTo(0.1, 1, 5)
    card.tl.then -> @.frame = 0
    card.tl.scaleTo(1.0, 1, 5)
    
    opened_name.push PCard.num2name(card.data, true)

    if (opened_name.length is 2)
      if opened_name[0].charAt(1) is opened_name[1].charAt(1)
        setTimeout ->
          removeTurnuped()
          opened_name = []
          alert("Game Overe. clicked = #{click_count}")  if check_end()
        , 1000
      else
        setTimeout ->
          turndownCards()
          opened_name = []
        , 1000
  
  check_end = ->
    return false if cards.length is 0

    for c in cards
      return false if isOnField(c)
    true

  $("#reset").click ->
    resetCards()
    opened_name = []

  $("#shuffle").click ->
    shuffleCards()
    opened_name = []

  $("#turn-up").click ->
    turnCards(0)
    opened_name = []

  $("#turn-down").click ->
    turnCards(1)
    opened_name = []

  core.onload = ->
    for s in [1 .. 4]
      for n in [1 .. 13]
        card = PCard.getSprite((s - 1) * 13 + n)
        card.x = PlayingCards.WIDTH * (n - 1)
        card.y = PlayingCards.HEIGHT * (s - 1)
        cards.push card
        core.rootScene.addChild card

        # カードをクリックしたら、裏返す
        card.addEventListener 'touchend', ->
          click_action(@)
    null
    
  core.start()
