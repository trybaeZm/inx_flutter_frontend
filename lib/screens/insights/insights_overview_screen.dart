import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../widgets/charts/widgets.dart';
import '../../core/models/dashboard.dart';

class InsightsOverviewScreen extends StatefulWidget {
  const InsightsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<InsightsOverviewScreen> createState() => _InsightsOverviewScreenState();
}

class _InsightsOverviewScreenState extends State<InsightsOverviewScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;

  // KPIs
  double _totalRevenue = 0;
  int _totalOrders = 0;
  double _avgOrderValue = 0;
  double _growthRate = 0;

  // Revenue trend (AI forecast)
  List<Map<String, dynamic>> _actual = [];
  List<Map<String, dynamic>> _forecast = [];
  String _salesNarrative = '';

  // Sales by category
  List<Map<String, dynamic>> _categoryData = [];

  // Customers analytics
  Map<String, int> _gender = const {'male': 0, 'female': 0};
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _topCustomers = [];
  List<Map<String, dynamic>> _segments = [];
  String _customerNarrative = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getDashboardData(),
        _api.getSalesForecast(),
        _api.getSalesNarrative(),
        _api.getCustomerGenderBreakdown(),
        _api.getCustomerLocations(),
        _api.getTopCustomers(limit: 5),
        _api.getCustomerSegments(),
        _api.getCustomerNarrative(),
      ]);
      final dashboard = results[0] as DashboardResponse;
      final forecast = results[1] as Map<String, List<Map<String, dynamic>>>;
      final salesNarr = results[2] as String;
      final gender = results[3] as Map<String, int>;
      final locs = results[4] as List<Map<String, dynamic>>;
      final top = results[5] as List<Map<String, dynamic>>;
      final segs = results[6] as List<Map<String, dynamic>>;
      final custNarr = results[7] as String;

      setState(() {
        _totalRevenue = dashboard.stats.totalRevenue;
        _totalOrders = dashboard.stats.totalOrders;
        _avgOrderValue = _totalOrders > 0 ? _totalRevenue / _totalOrders : 0;
        _growthRate = dashboard.stats.growthRate;

        _categoryData = dashboard.categorySales
            .map((e) => {
                  'category': e.category,
                  'sales': e.sales,
                  'percentage': e.percentage,
                })
            .toList();

        _actual = forecast['actual'] ?? [];
        _forecast = forecast['forecast'] ?? [];
        _salesNarrative = salesNarr;

        _gender = gender;
        _locations = locs;
        _topCustomers = top;
        _segments = segs;
        _customerNarrative = custNarr;

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load insights: ${e.toString()}';
        _loading = false;
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
        title: const Text('Insights Overview'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      _buildKpiRow(theme, isDark),
                      const SizedBox(height: 24),
                      _buildRevenueTrend(theme, isDark),
                      const SizedBox(height: 24),
                      _buildCategoryAndGender(theme, isDark),
                      const SizedBox(height: 24),
                      _buildLocationsAndSegments(theme, isDark),
                      const SizedBox(height: 24),
                      _buildTopCustomers(theme, isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Error',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildKpiRow(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(child: _metricCard(theme, isDark, 'Total Revenue', '\$${_totalRevenue.toStringAsFixed(2)}', Icons.attach_money, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard(theme, isDark, 'Total Orders', _totalOrders.toString(), Icons.receipt_long, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard(theme, isDark, 'Avg Order Value', '\$${_avgOrderValue.toStringAsFixed(2)}', Icons.shopping_cart, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _metricCard(theme, isDark, 'Growth Rate', '${_growthRate.toStringAsFixed(1)}%', Icons.trending_up, Colors.purple)),
      ],
    );
  }

  Widget _metricCard(ThemeData theme, bool isDark, String title, String value, IconData icon, Color color) {
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
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.grey[300] : Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrend(ThemeData theme, bool isDark) {
    final xs = <String>[];
    xs.addAll(_actual.map((e) => (e['ds'] ?? '') as String));
    xs.addAll(_forecast.map((e) => (e['ds'] ?? '') as String));
    final actualY = _actual.map((e) => (e['y'] ?? 0).toDouble()).toList();
    final forecastY = _forecast.map((e) => (e['yhat'] ?? 0).toDouble()).toList();

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF374151) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Trend (Actual & Forecast)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SimpleLineChart(xLabels: xs, yValues: [...actualY, ...forecastY]),
            ),
            const SizedBox(height: 12),
            if (_salesNarrative.isNotEmpty) Text(_salesNarrative, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAndGender(ThemeData theme, bool isDark) {
    final catLabels = _categoryData.map((e) => (e['category'] ?? '') as String).toList();
    final catValues = _categoryData.map((e) => ((e['sales'] ?? 0) as num).toDouble()).toList();
    final genderLabels = <String>['Male', 'Female'];
    final genderValues = <double>[((_gender['male'] ?? 0)).toDouble(), ((_gender['female'] ?? 0)).toDouble()];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales by Category', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  DonutChart(values: catValues, labels: catLabels, height: 260),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Gender', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  DonutChart(values: genderValues, labels: genderLabels, height: 260),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsAndSegments(ThemeData theme, bool isDark) {
    final locLabels = _locations.map((e) => (e['location'] ?? e['city'] ?? e['name'] ?? '') as String).toList();
    final locValues = _locations.map((e) => ((e['count'] ?? e['value'] ?? 0) as num).toDouble()).toList();

    final segLabels = _segments.map((e) => (e['segment'] ?? e['name'] ?? '') as String).toList();
    final segValues = _segments.map((e) => ((e['count'] ?? 0) as num).toDouble()).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
      child: Card(
            elevation: 2,
        color: isDark ? const Color(0xFF374151) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text('Customers by Location', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  GroupedBarChart(labels: locLabels, values: locValues),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            color: isDark ? const Color(0xFF374151) : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Segments (AI)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 16),
                  DonutChart(values: segValues, labels: segLabels, height: 260),
              const SizedBox(height: 12),
                  if (_customerNarrative.isNotEmpty) Text(_customerNarrative, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCustomers(ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF374151) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Customers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Total Orders')),
                  DataColumn(label: Text('Revenue')),
                ],
                rows: _topCustomers.map((c) {
                  final name = (c['name'] ?? c['customer_name'] ?? '—').toString();
                  final orders = ((c['orders'] ?? c['total_orders'] ?? 0) as num).toInt();
                  final revenue = ((c['revenue'] ?? c['total_amount'] ?? 0) as num).toDouble();
                  return DataRow(cells: [
                    DataCell(Text(name)),
                    DataCell(Text(orders.toString())),
                    DataCell(Text('\$${revenue.toStringAsFixed(2)}')),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
