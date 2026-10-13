/// A market thing a child can read, match, and put in the basket.
class MarketGoods {
  const MarketGoods({
    required this.id,
    required this.marathi,
    required this.emoji,
    required this.price,
    required this.sentence,
    required this.onList,
    required this.red,
    required this.green,
    required this.blue,
    this.topRadius = 0.16,
    this.bottomRadius = 0.16,
    this.height = 0.28,
  });

  final String id;
  final String marathi;
  final String emoji;
  final int price;
  final String sentence;

  /// True when this item belongs on the opening shopping list.
  final bool onList;
  final double red;
  final double green;
  final double blue;
  final double topRadius;
  final double bottomRadius;
  final double height;
}

/// A stall the child identifies by reading its name.
class MarketShop {
  const MarketShop({
    required this.id,
    required this.marathi,
    required this.red,
    required this.green,
    required this.blue,
  });

  final String id;
  final String marathi;
  final double red;
  final double green;
  final double blue;
}

/// Original lesson words for the market. Not shelf stock.
const List<MarketGoods> marketGoods = [
  MarketGoods(
    id: 'word-apple',
    marathi: 'सफरचंद',
    emoji: '🍎',
    price: 20,
    sentence: 'मला सफरचंद घ्यायचे आहे.',
    onList: true,
    red: 0.82,
    green: 0.14,
    blue: 0.12,
  ),
  MarketGoods(
    id: 'word-carrot',
    marathi: 'गाजर',
    emoji: '🥕',
    price: 10,
    sentence: 'मला गाजर घ्यायचे आहे.',
    onList: true,
    red: 0.93,
    green: 0.45,
    blue: 0.12,
    topRadius: 0.04,
    bottomRadius: 0.1,
    height: 0.38,
  ),
  MarketGoods(
    id: 'word-banana',
    marathi: 'केळी',
    emoji: '🍌',
    price: 15,
    sentence: 'मला केळी घ्यायची आहे.',
    onList: true,
    red: 0.95,
    green: 0.82,
    blue: 0.18,
    topRadius: 0.06,
    bottomRadius: 0.11,
    height: 0.36,
  ),
  MarketGoods(
    id: 'word-mango',
    marathi: 'आंबा',
    emoji: '🥭',
    price: 30,
    sentence: 'मला आंबा घ्यायचा आहे.',
    onList: false,
    red: 0.95,
    green: 0.62,
    blue: 0.12,
    topRadius: 0.1,
    bottomRadius: 0.16,
    height: 0.3,
  ),
  MarketGoods(
    id: 'word-tomato',
    marathi: 'टोमॅटो',
    emoji: '🍅',
    price: 12,
    sentence: 'मला टोमॅटो घ्यायचा आहे.',
    onList: false,
    red: 0.86,
    green: 0.16,
    blue: 0.12,
    topRadius: 0.15,
    bottomRadius: 0.15,
    height: 0.24,
  ),
  MarketGoods(
    id: 'word-soap',
    marathi: 'साबण',
    emoji: '🧼',
    price: 18,
    sentence: 'मला साबण घ्यायचा आहे.',
    onList: false,
    red: 0.95,
    green: 0.96,
    blue: 0.97,
    topRadius: 0.12,
    bottomRadius: 0.12,
    height: 0.1,
  ),
  MarketGoods(
    id: 'word-milk',
    marathi: 'दूध',
    emoji: '🥛',
    price: 25,
    sentence: 'मला दूध घ्यायचे आहे.',
    onList: false,
    red: 0.94,
    green: 0.95,
    blue: 0.96,
    topRadius: 0.09,
    bottomRadius: 0.1,
    height: 0.42,
  ),
];

const List<MarketShop> marketShops = [
  MarketShop(
    id: 'shop-vegetable',
    marathi: 'भाजी मंडई',
    red: 0.35,
    green: 0.68,
    blue: 0.32,
  ),
  MarketShop(
    id: 'shop-fruit',
    marathi: 'फळांचे दुकान',
    red: 0.9,
    green: 0.32,
    blue: 0.22,
  ),
  MarketShop(
    id: 'shop-clothes',
    marathi: 'कपड्यांचे दुकान',
    red: 0.28,
    green: 0.48,
    blue: 0.78,
  ),
  MarketShop(
    id: 'shop-books',
    marathi: 'पुस्तकांचे दुकान',
    red: 0.55,
    green: 0.38,
    blue: 0.22,
  ),
  MarketShop(
    id: 'shop-dairy',
    marathi: 'दूध डेअरी',
    red: 0.45,
    green: 0.72,
    blue: 0.9,
  ),
];

MarketGoods? goodsById(String id) {
  for (final goods in marketGoods) {
    if (goods.id == id) {
      return goods;
    }
  }
  return null;
}

MarketShop? shopById(String id) {
  for (final shop in marketShops) {
    if (shop.id == id) {
      return shop;
    }
  }
  return null;
}
