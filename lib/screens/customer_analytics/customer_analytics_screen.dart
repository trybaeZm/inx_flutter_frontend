import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/charts/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/business_provider.dart';

class CustomerAnalyticsScreen extends ConsumerStatefulWidget {
  const CustomerAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends ConsumerState<CustomerAnalyticsScreen> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  int _male = 0;
  int _female = 0;
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _topCustomers = [];
  List<Map<String, dynamic>> _segments = [];
  String _customerNarrative = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final business = ref.read(selectedBusinessProvider);
      final businessId = business?.id;
      final gender = await _api.getCustomerGenderBreakdown(businessId: businessId);
      final locs = await _api.getCustomerLocations(businessId: businessId);
      final tops = await _api.getTopCustomers(businessId: businessId);
      final segs = await _api.getCustomerSegments(businessId: businessId);
      final narr = await _api.getCustomerNarrative(businessId: businessId);
      setState(() {
        _male = gender['male'] ?? 0;
        _female = gender['female'] ?? 0;
        _locations = locs;
        _topCustomers = tops;
        _segments = segs;
        _customerNarrative = narr;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Analytics')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Customer Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('/customer-analytics/customer_gender_ratio'),
              child: const Text('View Data'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Top Customers + Gender Ratio + New vs Repeat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _TopCustomersCard(isDark: isDark, customers: _topCustomers)),
                const SizedBox(width: 16),
                Expanded(child: _DonutCard(title: 'Customer Gender Ratio', series: const ['Male', 'Female'], values: [
                  _male.toDouble(), _female.toDouble()
                ])),
                const SizedBox(width: 16),
                Expanded(child: _segmentsDonut()),
              ],
            ),

            const SizedBox(height: 16),

            // Behavior & Engagement
            _BehaviorChartCard(isDark: isDark, locations: _locations),

            const SizedBox(height: 16),

            // AI Insights
            if (_customerNarrative.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_customerNarrative, style: theme.textTheme.bodyMedium),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopCustomersCard extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> customers;
  const _TopCustomersCard({required this.isDark, required this.customers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = customers;

    return Card(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top Customers', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...items.map((c) => _TopCustomerRow(
                  name: (c['name'] ?? '') as String,
                  percent: (c['total_revenue'] ?? 0).toDouble(),
                  highlight: false,
                  isDark: isDark,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('25.7K', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Text('last 7 days', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCustomerRow extends StatelessWidget {
  final String name;
  final double percent;
  final bool highlight;
  final bool isDark;
  const _TopCustomerRow({required this.name, required this.percent, required this.highlight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFDF4C7) : (isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (highlight) const Icon(Icons.emoji_events, size: 18, color: Color(0xFF8B8000)),
          if (highlight) const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Text('${percent.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}

class _DonutCard extends StatelessWidget {
  final String title;
  final List<String> series;
  final List<double> values;
  const _DonutCard({required this.title, required this.series, required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = [
      const Color(0xFF1E0D69),
      const Color(0xFF9FA8FF),
    ];
    return Card(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: List.generate(values.length, (i) => PieChartSectionData(
                        value: values[i],
                        color: colors[i % colors.length],
                        title: '',
                      )),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: List.generate(series.length, (i) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(series[i]),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

extension _SegDonut on _CustomerAnalyticsScreenState {
  Widget _segmentsDonut() {
    final labels = _segments.map((e) => (e['segment'] ?? '') as String).toList();
    final List<double> values = _segments
        .map((e) => ((e['count'] ?? 0) as num).toDouble())
        .toList()
        .cast<double>();
    return Card(
      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Segments', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            DonutChart(values: values, labels: labels, height: 200),
          ],
        ),
      ),
    );
  }
}
class _BehaviorChartCard extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> locations;
  const _BehaviorChartCard({required this.isDark, required this.locations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = locations.map((e) => (e['location'] ?? 'Unknown') as String).toList();
    final List<double> values = locations
        .map((e) => ((e['count'] ?? 0) as num).toDouble())
        .toList()
        .cast<double>();
    return Card(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Locations', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            GroupedBarChart(labels: labels, values: values),
          ],
        ),
      ),
    );
  }
}

class _AiInsightsCard extends StatelessWidget {
  final bool isDark;
  const _AiInsightsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isDark ? const Color(0xFF1F2937) : Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Not enough transactions to recognize significant patterns. Perform more transactions to enable in-depth data analysis.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


