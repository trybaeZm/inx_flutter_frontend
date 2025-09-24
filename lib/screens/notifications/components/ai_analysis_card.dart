import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIAnalysisCard extends ConsumerStatefulWidget {
  final VoidCallback onTriggerAnalysis;

  const AIAnalysisCard({
    Key? key,
    required this.onTriggerAnalysis,
  }) : super(key: key);

  @override
  ConsumerState<AIAnalysisCard> createState() => _AIAnalysisCardState();
}

class _AIAnalysisCardState extends ConsumerState<AIAnalysisCard> {
  bool _isAnalyzing = false;
  String _lastAnalysisTime = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Smart business insights',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              'Our AI analyzes your business data to identify patterns, anomalies, and opportunities. Get intelligent notifications about:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Features List
            _buildFeatureItem(
              theme,
              icon: Icons.trending_up,
              text: 'Revenue trends and anomalies',
              color: Colors.green,
            ),
            _buildFeatureItem(
              theme,
              icon: Icons.inventory,
              text: 'Low stock and inventory alerts',
              color: Colors.orange,
            ),
            _buildFeatureItem(
              theme,
              icon: Icons.people,
              text: 'Customer behavior insights',
              color: Colors.blue,
            ),
            _buildFeatureItem(
              theme,
              icon: Icons.account_balance_wallet,
              text: 'Financial health monitoring',
              color: Colors.purple,
            ),
            
            const SizedBox(height: 24),
            
            // Last Analysis Time
            if (_lastAnalysisTime.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last analysis: $_lastAnalysisTime',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _onTriggerAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.psychology),
                label: Text(
                  _isAnalyzing ? 'Analyzing...' : 'Trigger AI Analysis',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Info Text
            Text(
              'Analysis typically takes 10-30 seconds depending on data volume.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    ThemeData theme, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onTriggerAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      widget.onTriggerAnalysis();
      
      // Update last analysis time
      final now = DateTime.now();
      setState(() {
        _lastAnalysisTime = _formatTimeAgo(now);
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI analysis completed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during AI analysis: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Compact AI analysis card for mobile
class CompactAIAnalysisCard extends ConsumerStatefulWidget {
  final VoidCallback onTriggerAnalysis;

  const CompactAIAnalysisCard({
    Key? key,
    required this.onTriggerAnalysis,
  }) : super(key: key);

  @override
  ConsumerState<CompactAIAnalysisCard> createState() => _CompactAIAnalysisCardState();
}

class _CompactAIAnalysisCardState extends ConsumerState<CompactAIAnalysisCard> {
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Analysis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isAnalyzing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Analyzing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Get intelligent business insights and automated notifications',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _onTriggerAnalysis,
                icon: const Icon(Icons.psychology, size: 16),
                label: Text(
                  _isAnalyzing ? 'Analyzing...' : 'Run Analysis',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTriggerAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      widget.onTriggerAnalysis();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('AI analysis completed!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }
}
