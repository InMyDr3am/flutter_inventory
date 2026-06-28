// lib/models/product.dart

class Product {
  final String id;
  final String sku;
  final String name;
  final int stock;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.stock,
    required this.price,
    required this.category,
  });

  Product copyWith({
    String? id,
    String? sku,
    String? name,
    int? stock,
    double? price,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }

  // 1. Mengubah format Objek Produk menjadi Peta Data (Map) untuk disimpan ke Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'stock': stock,
      'price': price,
      'category': category,
    };
  }

  // 2. Mengubah data dari Database (Map) kembali menjadi Objek Produk di Flutter
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      sku: map['sku'],
      name: map['name'],
      stock: map['stock'] as int,
      price: (map['price'] as num).toDouble(),
      category: map['category'],
    );
  }
}