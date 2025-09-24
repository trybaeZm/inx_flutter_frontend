import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class CustomerReturnCard extends StatelessWidget {
  final DashboardStats stats;

  const CustomerReturnCard({
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
                  child: Icon(Icons.repeat, size: 16, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Text('Customer Return Rate', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 10),
            Text('${stats.customerReturnRate.toStringAsFixed(1)}%', style: theme.textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(
              stats.customerReturnRate > 0 ? 'Customers returning' : 'No repeat customers yet',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
} 