import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class OrdersCard extends StatelessWidget {
  final DashboardStats stats;

  const OrdersCard({
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
                  child: Icon(Icons.shopping_bag_rounded, size: 16, color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(width: 8),
                Text('Total Orders', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              stats.totalOrders > 1000 ? '${(stats.totalOrders / 1000).toStringAsFixed(1)}K' : stats.totalOrders.toString(),
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 6),
            Text('6% vs last 7 days', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
} 