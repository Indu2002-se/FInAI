import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/progress_bar.dart';

/// Screen 32: Child Savings Dashboard
class ChildSavingsDashboardScreen extends ConsumerWidget {
  const ChildSavingsDashboardScreen({super.key});

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
          'MY SAVINGS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.savings, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Rs.15,000',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Savings',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MY GOALS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildGoalCard('New Bicycle', 25000, 15000, 0.6, Icons.pedal_bike),
              const SizedBox(height: 16),
              _buildGoalCard('Video Game', 5000, 3000, 0.6, Icons.videogame_asset),
              const SizedBox(height: 24),
              InfoCard(
                title: 'Chores & Rewards',
                subtitle: '3 tasks completed',
                leading: const Icon(Icons.task_alt, color: Colors.blue, size: 28),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              InfoCard(
                title: 'Financial Quiz',
                subtitle: 'Test your knowledge!',
                leading: const Icon(Icons.quiz, color: Colors.orange, size: 28),
                onTap: () {},
              ),
              const SizedBox(height: 16),
              InfoCard(
                title: 'My Wishlist',
                subtitle: '5 items',
                leading: const Icon(Icons.star, color: Colors.amber, size: 28),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(String name, double target, double saved, double progress, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs.${saved.toStringAsFixed(0)} / Rs.${target.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBarWidget(progress: progress),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% Complete',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
