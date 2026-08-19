import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen 38: Rewards Screen
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

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
          'MY REWARDS',
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // color: Colors.amber[50],
                border: Border.all(color: Colors.amber[700]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.star, color: Colors.amber[700], size: 56),
                  const SizedBox(height: 12),
                  Text(
                    '450 Points',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      // color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available to Redeem',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'REDEEM REWARDS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildRewardItem(
              'Extra Screen Time',
              '30 minutes',
              100,
              Icons.phone_android,
              Colors.blue[700]!,
            ),
            _buildRewardItem(
              'Movie Night',
              'Family movie night',
              200,
              Icons.movie,
              Colors.purple[700]!,
            ),
            _buildRewardItem(
              'Ice Cream Trip',
              'Visit favorite ice cream shop',
              150,
              Icons.icecream,
              Colors.pink[700]!,
            ),
            _buildRewardItem(
              'Park Visit',
              'Day at the amusement park',
              300,
              Icons.park,
              Colors.green[700]!,
            ),
            _buildRewardItem(
              'Late Bedtime',
              'Stay up 1 hour extra',
              120,
              Icons.bedtime,
              Colors.indigo[700]!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(
    String title,
    String description,
    int points,
    IconData icon,
    Color color,
  ) {
    final bool canAfford = points <= 450;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: !canAfford ? Colors.grey[50] : Colors.white,
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    // color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$points points',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        // color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: canAfford ? () {} : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? Colors.black87 : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              canAfford ? 'Redeem' : 'Locked',
              style: TextStyle(
                fontSize: 12,
                color: canAfford ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
