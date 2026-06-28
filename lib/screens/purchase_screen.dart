// lib/screens/purchase_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_inventory/models/product.dart';
import 'package:flutter_inventory/theme/app_theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  // Data simulasi (Mock Data). Di aplikasi nyata, data ini terhubung ke Database.
  final List<Product> _products = [
    Product(id: '1', sku: 'BRG001', name: 'Kopi Arabika 1kg', stock: 25, price: 120000, category: 'Minuman'),
    Product(id: '2', sku: 'BRG002', name: 'Gula Pasir 1kg', stock: 4, price: 15000, category: 'Bahan Pokok'),
    Product(id: '3', sku: 'BRG003', name: 'Susu UHT Full Cream', stock: 50, price: 18000, category: 'Minuman'),
  ];

  final _qtyController = TextEditingController();

  // --- LOGIKA PENAMBAHAN STOK (RESTOK) ---
  void _showRestockDialog(Product product) {
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
            onPressed: () {
              if (_qtyController.text.isNotEmpty) {
                final qty = int.tryParse(_qtyController.text) ?? 0;
                if (qty > 0) {
                  setState(() {
                    // Cari produk dan tambahkan stoknya
                    final index = _products.indexWhere((p) => p.id == product.id);
                    if (index != -1) {
                      _products[index] = product.copyWith(stock: product.stock + qty);
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil menambah $qty stok ${product.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
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