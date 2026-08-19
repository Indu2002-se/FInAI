import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';

/// Screen 37: Wishlist Screen
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MY WISHLIST',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            // color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildWishlistItem('New Bicycle', 25000, Icons.pedal_bike, Colors.blue[700]!),
                  _buildWishlistItem('Video Game Console', 50000, Icons.videogame_asset, Colors.purple[700]!),
                  _buildWishlistItem('Sports Equipment', 15000, Icons.sports_soccer, Colors.green[700]!),
                  _buildWishlistItem('Art Supplies', 5000, Icons.palette, Colors.orange[700]!),
                  _buildWishlistItem('Books Collection', 8000, Icons.menu_book, Colors.brown[700]!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(text: '+ Add Wish', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItem(String name, double price, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs.${price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    // color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
                onPressed: () {},
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Save For This',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    // color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
