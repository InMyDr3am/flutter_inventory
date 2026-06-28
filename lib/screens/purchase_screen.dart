// lib/screens/purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_inventory/models/product.dart';
import 'package:flutter_inventory/theme/app_theme.dart';
import 'package:flutter_inventory/services/database_helper.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  // 1. GANTI MOCK DATA DENGAN VARIABEL KOSONG INI
  List<Product> _products = [];
  bool _isLoading = true; // Tambahkan indikator loading

  final _qtyController = TextEditingController();

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

  // --- LOGIKA PENAMBAHAN STOK (RESTOK) ---
  void _showRestockDialog(Product product) {
    // ... (kode Anda yang bawahnya tetap sama)
    _qtyController.clear(); // Bersihkan form setiap kali dibuka
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restok Barang', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sisa stok saat ini: ${product.stock}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Masuk (Qty)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Iconsax.box_add),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            // KODE DATABASE MASUK DI SINI
            onPressed: () async { // <-- Tambahkan 'async' di sini
              if (_qtyController.text.isNotEmpty) {
                final qty = int.tryParse(_qtyController.text) ?? 0;
                if (qty > 0) {
                  // Hitung stok baru
                  final newStock = product.stock + qty; 

                  // 1. Simpan perubahan ke Database SQLite
                  await DatabaseHelper.instance.updateProduct(
                    product.copyWith(stock: newStock)
                  );

                  // 2. Segarkan data UI agar layar langsung berubah
                  await _refreshProducts();

                  if (context.mounted) {
                    Navigator.pop(context); // Tutup dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Berhasil menambah $qty stok ${product.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
        title: const Text('Belanja / Restok', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.shopping_cart, color: Colors.orange),
              ),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Stok saat ini: ${product.stock} | SKU: ${product.sku}'),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  elevation: 0, // Tanpa bayangan agar terlihat rata (flat design)
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showRestockDialog(product),
                child: const Text(
                  'Restok',
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}