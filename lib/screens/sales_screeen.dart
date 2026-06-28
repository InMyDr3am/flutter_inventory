// lib/screens/sales_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_inventory/models/product.dart';
import 'package:flutter_inventory/theme/app_theme.dart';
import 'package:flutter_inventory/services/database_helper.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // 1. GANTI MOCK DATA DENGAN VARIABEL KOSONG INI
  List<Product> _products = [];
  bool _isLoading = true; // Indikator loading

  final Map<String, int> _cart = {};

  // 2. TAMBAHKAN INITSTATE UNTUK MEMANGGIL DATA SAAT HALAMAN DIBUKA
  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  // 3. TAMBAHKAN FUNGSI _refreshProducts INI
  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  // --- LOGIKA KERANJANG BELANJA ---
  void _addToCart(Product product) {
    // ... (kode _addToCart dan ke bawahnya tetap sama)
    setState(() {
      final currentQty = _cart[product.id] ?? 0;
      if (currentQty < product.stock) {
        _cart[product.id] = currentQty + 1;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok tidak mencukupi!'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      final currentQty = _cart[product.id] ?? 0;
      if (currentQty > 1) {
        _cart[product.id] = currentQty - 1;
      } else {
        _cart.remove(product.id);
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    _cart.forEach((productId, qty) {
      final product = _products.firstWhere((p) => p.id == productId);
      total += product.price * qty;
    });
    return total;
  }

  // KODE DATABASE MASUK DI SINI
  void _processCheckout() async { // <-- Tambahkan 'async' di sini
    if (_cart.isEmpty) return;

    // 1. Kurangi stok setiap barang di keranjang dan simpan ke Database
    for (var productId in _cart.keys) {
      final qtyBought = _cart[productId]!; // Jumlah yang dibeli
      final product = _products.firstWhere((p) => p.id == productId);
      
      final newStock = product.stock - qtyBought; // Stok berkurang

      // Update produk ke SQLite
      await DatabaseHelper.instance.updateProduct(
        product.copyWith(stock: newStock)
      );
    }

    // 2. Segarkan tampilan UI
    await _refreshProducts();

    // 3. Tampilkan Dialog Sukses
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib diklik tombol tutup
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text('Pembayaran Berhasil', textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          'Total transaksi Rp ${_calculateTotal().toStringAsFixed(0)} telah dicatat dan stok otomatis berkurang.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => _cart.clear()); // Kosongkan keranjang
                Navigator.pop(context); // Tutup dialog sukses
              },
              child: const Text('Tutup', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAMPILAN ANTARMUKA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Penjualan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _products.isEmpty
              ? const Center(child: Text('Belum ada produk untuk dijual.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _products.length,
                  // ... (kode itemBuilder di bawahnya tetap sama)
        itemBuilder: (context, index) {
          final product = _products[index];
          final qtyInCart = _cart[product.id] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Info Produk
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text('Sisa stok: ${product.stock}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  
                  // Tombol Kuantitas (Keranjang)
                  Row(
                    children: [
                      if (qtyInCart > 0) ...[
                        IconButton(
                          icon: const Icon(Iconsax.minus_cirlce, color: Colors.red),
                          onPressed: () => _removeFromCart(product),
                        ),
                        Text(
                          '$qtyInCart',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                      IconButton(
                        icon: Icon(Iconsax.add_circle, color: qtyInCart < product.stock ? AppTheme.primaryColor : Colors.grey),
                        onPressed: qtyInCart < product.stock ? () => _addToCart(product) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // Bilah Total Belanja di Bawah (Bottom Navigation / Checkout Bar)
      bottomNavigationBar: _cart.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Tagihan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          'Rp ${_calculateTotal().toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _processCheckout,
                      child: const Row(
                        children: [
                          Icon(Iconsax.receipt_2, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Bayar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(), // Sembunyikan bilah jika keranjang kosong
    );
  }
}