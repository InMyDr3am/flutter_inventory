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

  // Fungsi untuk menyalin objek dengan perubahan (sangat berguna untuk update stok)
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
}