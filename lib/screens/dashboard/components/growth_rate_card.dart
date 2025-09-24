import 'package:flutter/material.dart';
import '../../../core/models/dashboard.dart';

class GrowthRateCard extends StatelessWidget {
  final DashboardStats stats;

  const GrowthRateCard({
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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.show_chart_rounded, size: 16, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Text('Growth Rate', style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${stats.growthRate >= 0 ? '+' : ''}${stats.growthRate.toStringAsFixed(1)}%',
              style: theme.textTheme.displaySmall?.copyWith(
                color: stats.growthRate >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text('Annually', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
} 