###
PlayingCards.js
###

class PlayingCards
  constructor: (core) ->
    @SPRITES = []
    if core
      core.preload([PlayingCards.CARD])
  
  # 画像ファイル名
  @CARD: "images/StandardDeck.png"

  # 画像のサイズ
  @WIDTH:  71
  @HEIGHT: 96

  # WIDTH: @WIDTH
  # HEIGHT: @HEIGHT
  
  # 擬似定数宣言
  @SUIT_SIZE: 4    # スートの総数 (スペード、ハート、ダイア、クラブ)
  @NUME_SIZE: 13   # 番号の総数 (Ａ、２、３、４、５、６、７、８、９、１０、Ｊ，Ｑ，Ｋ)
  @CARD_SIZE: @SUIT_SIZE * @NUME_SIZE   # ジョーカーを覗いたカードの総数 (スペードのＡからクラブのＫ)

  # スーツの定義
  @CLUB:     1
  @DIAMOND:  2
  @HEART:    3
  @SPADE:    4
  
  # トランプの数定義
  @ACE:    1 # 数札の定義
  @TEN:    10
  @JACK:   11
  @QUEEN:  12
  @KING:   13
  
  # 数札（pipcards/numeralcards）他の定義
  @C01: 1 # クローバー
  @C02: 2
  @C03: 3
  @C04: 4
  @C05: 5
  @C06: 6
  @C07: 7
  @C08: 8
  @C09: 9
  @C10: 10
  @C11: 11
  @C12: 12
  @C13: 13
  @D01: 14 # ダイア
  @D02: 15
  @D03: 16
  @D04: 17
  @D05: 18
  @D06: 19
  @D07: 20
  @D08: 21
  @D09: 22
  @D10: 23
  @D11: 24
  @D12: 25
  @D13: 26
  @H01: 27 # ハート
  @H02: 28
  @H03: 29
  @H04: 30
  @H05: 31
  @H06: 32
  @H07: 33
  @H08: 34
  @H09: 35
  @H10: 36
  @H11: 37
  @H12: 38
  @H13: 39
  @S01: 40 # スペード
  @S02: 41
  @S03: 42
  @S04: 43
  @S05: 44
  @S06: 45
  @S07: 46
  @S08: 47
  @S09: 48
  @S10: 49
  @S11: 50
  @S12: 51
  @S13: 52
  @JOKER: 53 # ジョーカー

  # 別名
  @C1: @C01 # クローバー
  @C2: @C02
  @C3: @C03
  @C4: @C04
  @C5: @C05
  @C6: @C06
  @C7: @C07
  @C8: @C08
  @C9: @C09
  @CT: @C10
  @CJ: @C11
  @CQ: @C12
  @CK: @C13

  @D1: @D01 # ダイア
  @D2: @D02
  @D3: @D03
  @D4: @D04
  @D5: @D05
  @D6: @D06
  @D7: @D07
  @D8: @D08
  @D9: @D09
  @DT: @D10
  @DJ: @D11
  @DQ: @D12
  @DK: @D13

  @H1: @H01 # ハー
  @H2: @H02
  @H3: @H03
  @H4: @H04
  @H5: @H05
  @H6: @H06
  @H7: @H07
  @H8: @H08
  @H9: @H09
  @HT: @H10
  @HJ: @H11
  @HQ: @H12
  @HK: @C13

  @S1: @S01 # スペード
  @S2: @S02
  @S3: @S03
  @S4: @S04
  @S5: @S05
  @S6: @S06
  @S7: @S07
  @S8: @S08
  @S9: @S09
  @ST: @S10
  @SJ: @S11
  @SQ: @C12
  @SK: @C13

  ###
  カードのスーツ取得
  @param card  <int> カードの通し番号
  @return      カードのスーツ
  ###
  getSuit: (card) ->
    # 通し番号がジョーカーなら 0 を返す。
    return 0 if card is PlayingCards.JOKER
    
    # 通し番号が範囲外であったときはエラーを返す。
    throw "#--- illegal card:#{card}"  if card < 1 or PlayingCards.CARD_SIZE < card
    
    # マークを計算して返す。
    Math.floor((card - 1) / PlayingCards.NUME_SIZE) + 1
  
  ###
  カードの番号取得
  @param card  <int> カードの通し番号
  @return      カードの番号
  ###
  getNumber: (card) ->
    # 通し番号がジョーカーなら 0 を返す。
    return 0 if card is PlayingCards.JOKER
    
    # 通し番号が範囲外であったときはエラーを返す。
    return throw "#--- illegal card:#{card}"  if card < 1 or PlayingCards.CARD_SIZE < card
    
    # 番号を計算して返す。
    (card - 1) % PlayingCards.NUME_SIZE + 1
  
  ###
  カードの通し番号取得
  @param suit    <int> カードのスーツ
  @param number  <int> カードの番号
  @return        カードの番号
  ###
  getData: (suit, number) ->
    # スーツ、または番号がジョーカーのときはジョーカーを返す。
    return PlayingCards.JOKER  if suit is 0 or number is 0

    # スーツ、または番号が範囲外であったときはエラーを返す。
    throw "#--- illegal suit:#{suit}, number:#{number}" if suit < 1 or PlayingCards.SUIT_SIZE < suit or number <= 0 or PlayingCards.NUME_SIZE < number
    
    # 通し番号を計算して返す。
    (suit - 1) * PlayingCards.NUME_SIZE + number

  ###
  カードの番号 (1, 2, ... 13, ...) -> カード名 (C1, C2, ... CK, ...)
               53 -> JOKER
  ###
  num2name: (data, isShort = true) ->
    return "JOKER" if data is PlayingCards.JOKER

    suit_name = ["C", "D", "H", "S"]
    num_short = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"]
    s = @getSuit(data)
    n = @getNumber(data)
    if isShort
      "#{suit_name[s - 1]}#{num_short[n - 1]}"
    else
      "#{suit_name[s - 1]}#{n}"

  ###
  カードの番号 (1, 2, ... 13, ...) -> カード名 (C1, C2, ... CK, ...)
               53 -> JOKER
  ###
  num2longname: (data) ->
    return "JOKER" if data is PlayingCards.JOKER

    suit_name = ["Clubs", "Diamonds", "Hearts", "Spades"]
    num_short = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
    s = @getSuit(data)
    n = @getNumber(data)
    "#{num_short[n - 1]} of #{suit_name[s - 1]}"

  ###
  カード名 (C1, C2, ... CK, ...,)    -> カードの番号 (1, 2, ... 13, ...)
           (C01, C02, ... C13, ...,) -> カードの番号 (1, 2, ... 13, ...)
           JOKER -> 53
  ###
  name2num: (name) ->
    return PlayingCards.JOKER if name is "JOKER"

    suit = {"C":1, "D":2, "H":3, "S":4}
    num1 = {"1": 1,   "2": 2,  "3": 3,  "4": 4,  "5": 5,  "6": 6,  "7": 7,  "8": 8,  "9": 9,  "T": 10,  "J": 11,  "Q": 12,  "K": 13}
    num2 = {"01": 1, "02": 2, "03": 3, "04": 4, "05": 5, "06": 6, "07": 7, "08": 8, "09": 9, "10": 10, "11": 11, "12": 12, "13": 13}

    chars = name.split("")
    s = suit[chars[0]]
    n = null
    if chars.length is 2
      n = num1["#{chars[1]}"]
    else if chars.length is 3
      n = num1["#{chars[1]}"]
      n = num2["#{chars[1]}#{chars[2]}"]

    throw "#--- illegal name #{name}" if s == null or n == null
    return (s - 1) * PlayingCards.NUME_SIZE + n

  ###
  dataで指定したカード画像を取得
  @param card  <int> カードの通し番号
  @return      カード画像
  ###
  getSprite: (data) ->
    throw "#--- illegal data:#{data}" if (data < 1 or PlayingCards.CARD_SIZE < data) and (data isnt PlayingCards.JOKER)

    if @SPRITES.length is 0
      @SPRITES.push @_getSprite(i)  for i in [1 .. PlayingCards.CARD_SIZE + 1]

    @SPRITES[data - 1]

  _getSprite:  (data) ->
    width = PlayingCards.WIDTH
    height = PlayingCards.HEIGHT

    card = new Sprite(width, height)
    card.image = new Surface(width * 2, height)
    card.data = data
    card.name = @num2name(data)
    
    # 表の描画 (frame = 0)
    x = if (data is PlayingCards.JOKER) then 0                else (@getNumber(data) - 1) * (width + 1)
    y = if (data is PlayingCards.JOKER) then 4 * (height + 1) else (@getSuit(data) - 1) * (height + 1)
    card.image.draw enchant.Game.instance.assets[PlayingCards.CARD], x, y, width, height, 0, 0, width, height
    # 裏面の描画 (frame = 1)
    x = 5 * (width + 1)
    y = 4 * (height + 1)
    card.image.draw enchant.Game.instance.assets[PlayingCards.CARD], x, y, width, height, width, 0, width, height
    card

  deck: ->
    deck = []
    deck.push(i) for i in [1 .. PlayingCards.CARD_SIZE]
    deck

  shuffle: (cards) ->
    i = cards.length
    while(i)
      j = Math.floor(Math.random() * i , 10)
      t = cards[--i]
      cards[i] = cards[j]
      cards[j] = t
    cards
