class Product {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final int stock;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      barcode: json['barcode'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'stock': stock,
      'category': category,
    };
  }
}