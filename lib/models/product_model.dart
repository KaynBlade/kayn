class Product {
  final int? id;
  final String title;
  final double price;
  final String description;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
  });

  // Convert the data to a Map so that it can be stored in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
    };
  }

  // Convert a Map read from SQLite into a Product object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      description: map['description'],
    );
  }
}
