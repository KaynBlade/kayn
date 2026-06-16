class Product {
  final int? id;
  final String title;
  final double price;
  final String description;
  final int? sellerId;
  final String? sellerName;
  final String? sellerEmail;
  final String? imagePath;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'price': price,
      'description': description,
      if (sellerId != null) 'seller_id': sellerId,
      if (sellerName != null) 'seller_name': sellerName,
      if (sellerEmail != null) 'seller_email': sellerEmail,
      'image_path': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'] ?? '',
      price: (map['price'] as num).toDouble(),
      description: map['description'] ?? '',
      sellerId: map['seller_id'],
      sellerName: map['seller_name'],
      sellerEmail: map['seller_email'],
      imagePath: map['image_path'],
    );
  }
}
