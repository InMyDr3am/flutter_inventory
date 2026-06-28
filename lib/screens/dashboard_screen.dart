import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_inventory/theme/app_theme.dart';
import 'package:flutter_inventory/screens/stock_management_screen.dart';
import 'package:flutter_inventory/screens/sales_screeen.dart';
import 'package:flutter_inventory/screens/purchase_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Pagi,',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const Text(
              'Admin Gudang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              const Text(
                'Menu Utama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMenuGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Total Pendapatan Hari Ini',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Rp 4.500.000',
            style: TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Kelola Stok', 'icon': Iconsax.box, 'color': Colors.blue},
      {'title': 'Penjualan', 'icon': Iconsax.shop, 'color': Colors.green},
      {'title': 'Belanja', 'icon': Iconsax.shopping_cart, 'color': Colors.orange},
      {'title': 'Pengguna', 'icon': Iconsax.profile_2user, 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(
          title: menuItems[index]['title'],
          icon: menuItems[index]['icon'],
          iconColor: menuItems[index]['color'],
          onTap: () {
            // === KODE NAVIGASI ===
            if (menuItems[index]['title'] == 'Kelola Stok') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StockManagementScreen()),
              );
            } else if (menuItems[index]['title'] == 'Penjualan') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SalesScreen()),
              );
            } else if (menuItems[index]['title'] == 'Belanja') { // <-- TAMBAHKAN BLOK INI
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchaseScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Membuka ${menuItems[index]['title']}...')),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}