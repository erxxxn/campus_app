class FoodItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final DateTime expiryDate;
  final String providerId;
  final String? imageUrl;
  final DateTime createdAt;

  FoodItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.expiryDate,
    required this.providerId,
    this.imageUrl,
    required this.createdAt,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    try {
      return FoodItem(
        id: json['_id'] ?? '',
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 0,
        expiryDate: DateTime.parse(json['expiryDate']),
        providerId: json['providerId'] ?? '',
        imageUrl: json['imageUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );
    } catch (e) {
      print('Error parsing FoodItem: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  String get formattedExpiryDate {
    return 'Expires ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}';
  }
}