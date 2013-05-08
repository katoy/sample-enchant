$ ->
  enchant()

  core = new Core(PlayingCards.WIDTH * 13, PlayingCards.HEIGHT * 4)
  # core = new Core(1000, 500)
  
  PCard = new PlayingCards(core)

  click_count = 0
  opened_name = []
  cards = []

  swapCards = (c1, c2) ->

  hideCard = (card) ->
    card.visible = false
    card.y = -999

  resetCards = ->
    click_count = 0
    for c in cards
      s = PCard.getSuit(c.data)
      n = PCard.getNumber(c.data)
      c.x = PlayingCards.WIDTH * (n - 1)
      c.y = PlayingCards.HEIGHT * (s - 1)
      c.frame = 0
      c.visible = true
    null

  shuffleCards = ->
    cards = PCard.shuffle(cards)
    p = 0
    for i in [0 ... cards.length]
      if cards[i].visible
        cards[i].x = (p % 13) * PlayingCards.WIDTH
        cards[i].y = Math.floor(p / 13) * PlayingCards.HEIGHT
        p++
    null

  turnCards = (flag) -> cards[i].frame = flag for i in [0 ... cards.length]
  turndownCards = -> turnCards(1)

  hideTurnuped = ->
    for c in cards
      hideCard(c) if c.visible and (c.frame is 0) and (c.name in opened_name)
    null
          
  click_action = (card) ->

    return if opened_name.length > 1
    return if card.frame is 0

    click_count++
    card.frame = 0
    opened_name.push PCard.num2name(card.data, true)

    if (opened_name.length is 2)
      if opened_name[0].charAt(1) is opened_name[1].charAt(1)
        setTimeout ->
          hideTurnuped()
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
      return false if c.visible
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
