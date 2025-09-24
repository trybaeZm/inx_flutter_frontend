import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/charts/widgets.dart';
import '../../core/services/api_service.dart';

class SalesAnalyticsScreen extends StatefulWidget {
  const SalesAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<SalesAnalyticsScreen> createState() => _SalesAnalyticsScreenState();
}

class _SalesAnalyticsScreenState extends State<SalesAnalyticsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  
  // Analytics data
  double _totalRevenue = 0;
  int _totalTransactions = 0;
  double _averageOrderValue = 0;
  double _growthRate = 0;
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _categoryData = [];
  // Forecast data
  List<Map<String, dynamic>> _actual = [];
  List<Map<String, dynamic>> _forecast = [];
  String _salesNarrative = '';

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load dashboard data for analytics
      final dashboardData = await _apiService.getDashboardData();
      final forecast = await _apiService.getSalesForecast();
      final narrative = await _apiService.getSalesNarrative();
      
      setState(() {
        _totalRevenue = dashboardData.stats.totalRevenue;
        _totalTransactions = dashboardData.stats.totalOrders;
        _averageOrderValue = _totalRevenue / _totalTransactions;
        _growthRate = dashboardData.stats.growthRate;
        
        // Convert revenue chart data
        _revenueData = dashboardData.revenueChartData.map((item) => {
          'month': item.month,
          'revenue': item.revenue,
        }).toList();
        
        // Convert category data
        _categoryData = dashboardData.categorySales.map((item) => {
          'category': item.category,
          'sales': item.sales,
          'percentage': item.percentage,
        }).toList();
        
        _actual = forecast['actual'] ?? [];
        _forecast = forecast['forecast'] ?? [];
        _salesNarrative = narrative;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load analytics: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Sales Analytics'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.red[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAnalyticsData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Metrics Cards
                      _buildMetricsCards(theme, isDark),
                      const SizedBox(height: 24),
                      
                      // Revenue Chart (actual + forecast)
                      _buildForecastChart(theme, isDark),
                      const SizedBox(height: 24),
                      
                      // Sales by Category
                      _buildCategoryChart(theme, isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricsCards(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Total Revenue',
            '\$${_totalRevenue.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
            theme,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Total Transactions',
            _totalTransactions.toString(),
            Icons.receipt_long,
            Colors.blue,
            theme,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Average Order Value',
            '\$${_averageOrderValue.toStringAsFixed(2)}',
            Icons.shopping_cart,
            Colors.orange,
            theme,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Growth Rate',
            '${_growthRate.toStringAsFixed(1)}%',
            Icons.trending_up,
            Colors.purple,
            theme,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF374151) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF374151) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Trend (Actual & Forecast)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildForecastLine(),
            ),
            const SizedBox(height: 12),
            if (_salesNarrative.isNotEmpty)
              Text(_salesNarrative, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastLine() {
    // xLabels from actual + forecast
    final xs = <String>[];
    xs.addAll(_actual.map((e) => e['ds'] as String));
    xs.addAll(_forecast.map((e) => e['ds'] as String));
    // y series
    final actualY = _actual.map((e) => (e['y'] ?? 0).toDouble()).toList();
    final forecastY = _forecast.map((e) => (e['yhat'] ?? 0).toDouble()).toList();
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
              final i = v.toInt();
              if (i >= 0 && i < xs.length) {
                final label = xs[i];
                return Text(label.substring(5), style: const TextStyle(fontSize: 10));
              }
              return const Text('');
            }),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // actual
          LineChartBarData(
            spots: actualY.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
            isCurved: true,
            color: const Color(0xFF3B82F6),
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
          // forecast
          LineChartBarData(
            spots: forecastY
                .asMap()
                .entries
                .map((e) => FlSpot((e.key + actualY.length).toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: const Color(0xFFF59E0B),
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF374151) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: _categoryData
                            .asMap()
                            .entries
                            .map((entry) => PieChartSectionData(
                                  value: entry.value['sales'],
                                  title: '${entry.value['percentage'].toStringAsFixed(1)}%',
                                  color: _getCategoryColor(entry.key),
                                  radius: 80,
                                ))
                            .toList(),
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _categoryData
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(entry.key),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        entry.value['category'],
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    return colors[index % colors.length];
  }
} 