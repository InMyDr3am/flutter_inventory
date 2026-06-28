// lib/screens/stock_management_screen.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_inventory/models/product.dart';
import 'package:flutter_inventory/theme/app_theme.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  // Data simulasi (Mock Data) sebagai pengganti database lokal/cloud agar ringan
  final List<Product> _products = [
    Product(id: '1', sku: 'BRG001', name: 'Kopi Arabika 1kg', stock: 25, price: 120000, category: 'Minuman'),
    Product(id: '2', sku: 'BRG002', name: 'Gula Pasir 1kg', stock: 4, price: 15000, category: 'Bahan Pokok'),
    Product(id: '3', sku: 'BRG003', name: 'Susu UHT Full Cream', stock: 50, price: 18000, category: 'Minuman'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  // --- FUNGSI LOGIKA CRUD ---
  
  // 1. CREATE & UPDATE (Menambah atau Mengedit Data)
  void _saveProduct(Product? existingProduct) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        if (existingProduct == null) {
          // Aksi Tambah Baru (Create)
          _products.add(Product(
            id: DateTime.now().toString(),
            sku: _skuController.text,
            name: _nameController.text,
            stock: int.parse(_stockController.text),
            price: double.parse(_priceController.text),
            category: _categoryController.text,
          ));
        } else {
          // Aksi Edit (Update)
          final index = _products.indexWhere((p) => p.id == existingProduct.id);
          if (index != -1) {
            _products[index] = existingProduct.copyWith(
              sku: _skuController.text,
              name: _nameController.text,
              stock: int.parse(_stockController.text),
              price: double.parse(_priceController.text),
              category: _categoryController.text,
            );
          }
        }
      });
      Navigator.pop(context);
      _clearForm();
    }
  }

  // 2. DELETE (Menghapus Data)
  void _deleteProduct(String id) {
    setState(() {
      _products.removeWhere((product) => product.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dihapus')),
    );
  }

  void _clearForm() {
    _skuController.clear();
    _nameController.clear();
    _stockController.clear();
    _priceController.clear();
    _categoryController.clear();
  }

  // --- TAMPILAN FORM FORM DIALOG (BOTTOM SHEET) ---
  void _showProductForm({Product? product}) {
    if (product != null) {
      _skuController.text = product.sku;
      _nameController.text = product.name;
      _stockController.text = product.stock.toString();
      _priceController.text = product.price.toString();
      _categoryController.text = product.category;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product == null ? 'Tambah Produk Baru' : 'Edit Produk',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField(_skuController, 'Kode SKU (Contoh: BRG001)'),
                _buildTextField(_nameController, 'Nama Barang'),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_stockController, 'Stok', isNumber: true)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_priceController, 'Harga', isNumber: true)),
                  ],
                ),
                _buildTextField(_categoryController, 'Kategori'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _saveProduct(product),
                    child: const Text('Simpan Data', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // <-- Perbaikan di sini menggunakan .only()
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Field ini wajib diisi' : null,
      ),
    );
  }

  // --- TAMPILAN HALAMAN UTAMA STOK ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _products.isEmpty
          ? const Center(child: Text('Belum ada produk. Klik tombol + untuk menambah.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final isLowStock = product.stock <= 5; // Kondisi warning UX stok menipis

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('SKU: ${product.sku} | Kategori: ${product.category}'),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Indikator Stok Menipis (UX Penting)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isLowStock ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Tombol Aksi Menu Kanan (Edit & Hapus)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showProductForm(product: product);
                            } else if (value == 'delete') {
                              _deleteProduct(product.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Iconsax.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Iconsax.trash, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _showProductForm(),
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }
}