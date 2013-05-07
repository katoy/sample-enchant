// Generated by CoffeeScript 1.6.2
/*
PlayingCards.js
*/


(function() {
  var PlayingCards;

  PlayingCards = (function() {
    function PlayingCards(core) {
      this.SPRITES = [];
      if (core) {
        core.preload([PlayingCards.CARD]);
      }
    }

    PlayingCards.CARD = "images/StandardDeck.png";

    PlayingCards.WIDTH = 71;

    PlayingCards.HEIGHT = 96;

    PlayingCards.SUIT_SIZE = 4;

    PlayingCards.NUME_SIZE = 13;

    PlayingCards.CARD_SIZE = PlayingCards.SUIT_SIZE * PlayingCards.NUME_SIZE;

    PlayingCards.CLUB = 1;

    PlayingCards.DIAMOND = 2;

    PlayingCards.HEART = 3;

    PlayingCards.SPADE = 4;

    PlayingCards.ACE = 1;

    PlayingCards.TEN = 10;

    PlayingCards.JACK = 11;

    PlayingCards.QUEEN = 12;

    PlayingCards.KING = 13;

    PlayingCards.C01 = 1;

    PlayingCards.C02 = 2;

    PlayingCards.C03 = 3;

    PlayingCards.C04 = 4;

    PlayingCards.C05 = 5;

    PlayingCards.C06 = 6;

    PlayingCards.C07 = 7;

    PlayingCards.C08 = 8;

    PlayingCards.C09 = 9;

    PlayingCards.C10 = 10;

    PlayingCards.C11 = 11;

    PlayingCards.C12 = 12;

    PlayingCards.C13 = 13;

    PlayingCards.D01 = 14;

    PlayingCards.D02 = 15;

    PlayingCards.D03 = 16;

    PlayingCards.D04 = 17;

    PlayingCards.D05 = 18;

    PlayingCards.D06 = 19;

    PlayingCards.D07 = 20;

    PlayingCards.D08 = 21;

    PlayingCards.D09 = 22;

    PlayingCards.D10 = 23;

    PlayingCards.D11 = 24;

    PlayingCards.D12 = 25;

    PlayingCards.D13 = 26;

    PlayingCards.H01 = 27;

    PlayingCards.H02 = 28;

    PlayingCards.H03 = 29;

    PlayingCards.H04 = 30;

    PlayingCards.H05 = 31;

    PlayingCards.H06 = 32;

    PlayingCards.H07 = 33;

    PlayingCards.H08 = 34;

    PlayingCards.H09 = 35;

    PlayingCards.H10 = 36;

    PlayingCards.H11 = 37;

    PlayingCards.H12 = 38;

    PlayingCards.H13 = 39;

    PlayingCards.S01 = 40;

    PlayingCards.S02 = 41;

    PlayingCards.S03 = 42;

    PlayingCards.S04 = 43;

    PlayingCards.S05 = 44;

    PlayingCards.S06 = 45;

    PlayingCards.S07 = 46;

    PlayingCards.S08 = 47;

    PlayingCards.S09 = 48;

    PlayingCards.S10 = 49;

    PlayingCards.S11 = 50;

    PlayingCards.S12 = 51;

    PlayingCards.S13 = 52;

    PlayingCards.JOKER = 53;

    PlayingCards.CA = PlayingCards.C01;

    PlayingCards.C1 = PlayingCards.C01;

    PlayingCards.C2 = PlayingCards.C02;

    PlayingCards.C3 = PlayingCards.C03;

    PlayingCards.C4 = PlayingCards.C04;

    PlayingCards.C5 = PlayingCards.C05;

    PlayingCards.C6 = PlayingCards.C06;

    PlayingCards.C7 = PlayingCards.C07;

    PlayingCards.C8 = PlayingCards.C08;

    PlayingCards.C9 = PlayingCards.C09;

    PlayingCards.CT = PlayingCards.C10;

    PlayingCards.CJ = PlayingCards.C11;

    PlayingCards.CQ = PlayingCards.C12;

    PlayingCards.CK = PlayingCards.C13;

    PlayingCards.DA = PlayingCards.D01;

    PlayingCards.D1 = PlayingCards.D01;

    PlayingCards.D2 = PlayingCards.D02;

    PlayingCards.D3 = PlayingCards.D03;

    PlayingCards.D4 = PlayingCards.D04;

    PlayingCards.D5 = PlayingCards.D05;

    PlayingCards.D6 = PlayingCards.D06;

    PlayingCards.D7 = PlayingCards.D07;

    PlayingCards.D8 = PlayingCards.D08;

    PlayingCards.D9 = PlayingCards.D09;

    PlayingCards.DT = PlayingCards.D10;

    PlayingCards.DJ = PlayingCards.D11;

    PlayingCards.DQ = PlayingCards.D12;

    PlayingCards.DK = PlayingCards.D13;

    PlayingCards.HA = PlayingCards.H01;

    PlayingCards.H1 = PlayingCards.H01;

    PlayingCards.H2 = PlayingCards.H02;

    PlayingCards.H3 = PlayingCards.H03;

    PlayingCards.H4 = PlayingCards.H04;

    PlayingCards.H5 = PlayingCards.H05;

    PlayingCards.H6 = PlayingCards.H06;

    PlayingCards.H7 = PlayingCards.H07;

    PlayingCards.H8 = PlayingCards.H08;

    PlayingCards.H9 = PlayingCards.H09;

    PlayingCards.HT = PlayingCards.H10;

    PlayingCards.HJ = PlayingCards.H11;

    PlayingCards.HQ = PlayingCards.H12;

    PlayingCards.HK = PlayingCards.C13;

    PlayingCards.SA = PlayingCards.S01;

    PlayingCards.S1 = PlayingCards.S01;

    PlayingCards.S2 = PlayingCards.S02;

    PlayingCards.S3 = PlayingCards.S03;

    PlayingCards.S4 = PlayingCards.S04;

    PlayingCards.S5 = PlayingCards.S05;

    PlayingCards.S6 = PlayingCards.S06;

    PlayingCards.S7 = PlayingCards.S07;

    PlayingCards.S8 = PlayingCards.S08;

    PlayingCards.S9 = PlayingCards.S09;

    PlayingCards.ST = PlayingCards.S10;

    PlayingCards.SJ = PlayingCards.S11;

    PlayingCards.SQ = PlayingCards.C12;

    PlayingCards.SK = PlayingCards.C13;

    /*
    カードのスーツ取得
    @param card  <int> カードの通し番号
    @return      カードのスーツ
    */


    PlayingCards.prototype.getSuit = function(card) {
      if (card === PlayingCards.JOKER) {
        return 0;
      }
      if (card < 1 || PlayingCards.CARD_SIZE < card) {
        throw "#--- illegal card:" + card;
      }
      return Math.floor((card + PlayingCards.NUME_SIZE - 1) / PlayingCards.NUME_SIZE);
    };

    /*
    カードの番号取得
    @param card  <int> カードの通し番号
    @return      カードの番号
    */


    PlayingCards.prototype.getNumber = function(card) {
      if (card === PlayingCards.JOKER) {
        return 0;
      }
      if (card < 1 || PlayingCards.CARD_SIZE < card) {
        throw "#--- illegal card:" + card;
      }
      return (card - 1) % PlayingCards.NUME_SIZE + 1;
    };

    /*
    カードの通し番号取得
    @param suit    <int> カードのスーツ
    @param number  <int> カードの番号
    @return        カードの番号
    */


    PlayingCards.prototype.getData = function(suit, number) {
      if (suit === 0 || number === 0) {
        return PlayingCards.JOKER;
      }
      if (suit < 1 || PlayingCards.SUIT_SIZE < suit || number <= 0 || PlayingCards.NUME_SIZE < number) {
        throw "#--- illegal suit:" + suit + ", number:" + number;
      }
      return (suit - 1) * PlayingCards.NUME_SIZE + number;
    };

    /*
    */


    PlayingCards.prototype.getName = function(data) {
      var n, s, sname;

      if (data === PlayingCards.JOKER) {
        return "JOKER";
      }
      sname = ["C", "D", "H", "S"];
      s = this.getSuit(data);
      n = this.getNumber(data);
      return "" + sname[s - 1] + n;
    };

    /*
    dataで指定したカード画像を取得
    @param card  <int> カードの通し番号
    @return      カード画像
    */


    PlayingCards.prototype.getSprite = function(data) {
      var i, _i, _ref;

      if ((data < 1 || PlayingCards.CARD_SIZE < data) && (data !== PlayingCards.JOKER)) {
        throw "#--- illegal data:" + data;
      }
      if (this.SPRITES.length === 0) {
        for (i = _i = 1, _ref = PlayingCards.CARD_SIZE + 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          this.SPRITES.push(this._getSprite(i));
        }
      }
      return this.SPRITES[data - 1];
    };

    PlayingCards.prototype._getSprite = function(data) {
      var card, height, width, x, y;

      width = PlayingCards.WIDTH;
      height = PlayingCards.HEIGHT;
      card = new Sprite(width, height);
      card.image = new Surface(width * 2, height);
      card.data = data;
      x = data === PlayingCards.JOKER ? 0 : (this.getNumber(data) - 1) * (width + 1);
      y = data === PlayingCards.JOKER ? 4 * (height + 1) : (this.getSuit(data) - 1) * (height + 1);
      card.image.draw(enchant.Game.instance.assets[PlayingCards.CARD], x, y, width, height, 0, 0, width, height);
      x = 5 * (width + 1);
      y = 4 * (height + 1);
      card.image.draw(enchant.Game.instance.assets[PlayingCards.CARD], x, y, width, height, width, 0, width, height);
      return card;
    };

    return PlayingCards;

  })();

  enchant();

  window.onload = function() {
    var PCard, core;

    core = new Core(PlayingCards.WIDTH * 13, PlayingCards.HEIGHT * 5);
    PCard = new PlayingCards(core);
    core.onload = function() {
      var card, n, s, _i, _j;

      for (s = _i = 1; _i <= 4; s = ++_i) {
        for (n = _j = 1; _j <= 13; n = ++_j) {
          card = PCard.getSprite((s - 1) * 13 + n);
          card.x = PlayingCards.WIDTH * (n - 1);
          card.y = PlayingCards.HEIGHT * (s - 1);
          core.rootScene.addChild(card);
          card.addEventListener('touchend', function() {
            this.frame = this.frame === 0 ? 1 : 0;
            return alert("cliked " + (PCard.getName(this.data)));
          });
        }
      }
      card = PCard.getSprite(PlayingCards.JOKER);
      card.x = PlayingCards.WIDTH * 0;
      card.y = PlayingCards.HEIGHT * 4;
      card.frame = 1;
      core.rootScene.addChild(card);
      return card.addEventListener('touchend', function() {
        this.frame = this.frame === 0 ? 1 : 0;
        return alert("cliked " + (PCard.getName(this.data)));
      });
    };
    return core.start();
  };

}).call(this);
