import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class TotalRevenueCard extends StatelessWidget {
  final DashboardStats stats;

  const TotalRevenueCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.trending_up_rounded, size: 16, color: Colors.green),
                ),
                const SizedBox(width: 8),
                Text('Total Revenue', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text('\$${stats.totalRevenue.toStringAsFixed(2)}', style: theme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(
              'vs last period: ${stats.growthRate.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: stats.growthRate >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 