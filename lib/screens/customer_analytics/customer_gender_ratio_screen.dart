import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/business_provider.dart';

class CustomerGenderRatioScreen extends ConsumerStatefulWidget {
  const CustomerGenderRatioScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerGenderRatioScreen> createState() => _CustomerGenderRatioScreenState();
}

class _CustomerGenderRatioScreenState extends ConsumerState<CustomerGenderRatioScreen> {
  String _selectedGender = 'All';
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  int _male = 0;
  int _female = 0;
  int _maleSales = 0;
  int _femaleSales = 0;
  double _maleRevenue = 0;
  double _femaleRevenue = 0;
  List<List<String>> _rows = [];

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
      final stats = await _api.getCustomerGenderStats(businessId: businessId);
      final customers = await _api.getCustomersRaw(limit: 500, businessId: businessId);
      setState(() {
        _male = (stats['male'] ?? 0) as int;
        _female = (stats['female'] ?? 0) as int;
        _maleSales = (stats['male_sales'] ?? 0) as int;
        _femaleSales = (stats['female_sales'] ?? 0) as int;
        _maleRevenue = (stats['male_revenue'] ?? 0).toDouble();
        _femaleRevenue = (stats['female_revenue'] ?? 0).toDouble();
        _rows = customers.map((c) => [
          (c['name'] ?? '') as String,
          (c['email'] ?? '') as String,
          (c['phone'] ?? '') as String,
          (c['location'] ?? '') as String,
          (c['created_at'] ?? '') as String,
          (c['gender'] ?? '') as String,
        ]).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final rows = _rows;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Customer Gender Ratio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select Gender', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                        ],
                        onChanged: (v) => setState(() => _selectedGender = v ?? 'All'),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(onPressed: () {}, icon: const Icon(Icons.sort), label: const Text('sort')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _kpi('ZMW ${(_maleRevenue + _femaleRevenue).toStringAsFixed(2)}', 'Revenue (completed)'),
                _kpi('${_maleSales + _femaleSales}', 'Number of Sales'),
                _kpi('${_male + _female}', 'Total Customers'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                elevation: 2,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('NAME')),
                      DataColumn(label: Text('EMAIL')),
                      DataColumn(label: Text('PHONE')),
                      DataColumn(label: Text('LOCATION')),
                      DataColumn(label: Text('JOINED DATE')),
                      DataColumn(label: Text('GENDER')),
                    ],
                    rows: rows
                        .where((r) => _selectedGender == 'All' || r.last.toString().toLowerCase() == _selectedGender.toLowerCase())
                        .map((r) => DataRow(cells: r.map((c) => DataCell(Text(c))).toList()))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpi(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF1E0D69))),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}


