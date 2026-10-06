class AppCategory {
  final String key;
  final String emoji;

  const AppCategory({required this.key, required this.emoji});
}

const appCategories = <AppCategory>[
  AppCategory(key: 'smartphones', emoji: '📱'),
  AppCategory(key: 'laptops', emoji: '💻'),
  AppCategory(key: 'tablets', emoji: '📲'),
  AppCategory(key: 'fragrances', emoji: '🌸'),
  AppCategory(key: 'skincare', emoji: '✨'),
  AppCategory(key: 'beauty', emoji: '💄'),
  AppCategory(key: 'groceries', emoji: '🛒'),
  AppCategory(key: 'furniture', emoji: '🛋️'),
  AppCategory(key: 'home-decoration', emoji: '🏠'),
  AppCategory(key: 'mens-shirts', emoji: '👔'),
  AppCategory(key: 'womens-dresses', emoji: '👗'),
  AppCategory(key: 'mens-shoes', emoji: '👟'),
  AppCategory(key: 'womens-shoes', emoji: '👠'),
  AppCategory(key: 'mens-watches', emoji: '⌚'),
  AppCategory(key: 'womens-watches', emoji: '💎'),
  AppCategory(key: 'sunglasses', emoji: '🕶️'),
  AppCategory(key: 'sports-accessories', emoji: '⚽'),
  AppCategory(key: 'vehicle', emoji: '🚗'),
  AppCategory(key: 'motorcycle', emoji: '🏍️'),
  AppCategory(key: 'womens-bags', emoji: '👜'),
  AppCategory(key: 'womens-jewellery', emoji: '💍'),
  AppCategory(key: 'kitchen-accessories', emoji: '🍳'),
  AppCategory(key: 'mobile-accessories', emoji: '🎧'),
  AppCategory(key: 'tops', emoji: '👕'),
];
