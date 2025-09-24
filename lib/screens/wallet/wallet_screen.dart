import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/business_provider.dart';
import '../../widgets/common/responsive_wrapper.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _api = ApiService();
  double balance = 0.0;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _accountCtrl = TextEditingController();
  String? _method;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _withdrawals = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() { _loading = true; _error = null; });
    try {
      final business = ref.read(selectedBusinessProvider);
      final businessId = business?.id;
      final bal = await _api.getWalletBalance(businessId: businessId);
      final wd = await _api.getWithdrawals(businessId: businessId);
      setState(() {
        balance = bal;
        _withdrawals = wd;
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: isDark ? const Color(0xFF374151) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ResponsiveWrapper(
                  child: Column(
                    children: [
                      // Balance card with actions
                      Card(
                        color: isDark ? const Color(0xFFE5E7EB).withOpacity(0.05) : const Color(0xFFF3F4F6),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          child: isMobile 
                              ? _buildMobileBalanceCard(theme, isDark)
                              : _buildDesktopBalanceCard(theme, isDark),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // History table
                      Expanded(
                        child: Card(
                          color: isDark ? const Color(0xFF374151) : Colors.white,
                          elevation: 3,
                          child: _withdrawals.isEmpty
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No withdrawals yet'),
                                ))
                              : ListView.separated(
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  itemBuilder: (_, i) {
                                    final w = _withdrawals[i];
                                    final status = (w['status'] ?? 'pending') as String;
                                    final isPending = status == 'pending';
                                    return ListTile(
                                      leading: const Icon(Icons.swap_vert),
                                      title: Text(
                                        'ZMW ${(w['amount'] ?? 0).toString()}',
                                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                                      ),
                                      subtitle: Text(
                                        '${w['method']} • ${w['account_details']} • ${w['requested_at']}',
                                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                                      ),
                                      trailing: _StatusPill(
                                        label: status,
                                        color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                                        textColor: isPending ? const Color(0xFF92400E) : const Color(0xFF065F46),
                                        icon: isPending ? Icons.access_time : Icons.check_circle,
                                        isMobile: isMobile,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemCount: _withdrawals.length,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMobileBalanceCard(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Balance', style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(
          'ZMW ${balance.toStringAsFixed(2)}',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF2563EB),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Text('Withdrawal History', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _openWithdrawDialog,
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: const Text('Request Withdrawal'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _refresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopBalanceCard(ThemeData theme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Balance', style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(
                'ZMW ${balance.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text('Withdrawal History', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: _openWithdrawDialog,
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Request Withdrawal'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: _refresh, child: const Text('Refresh')),
      ],
    );
  }

  void _openWithdrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final theme = Theme.of(context);
        final isMobile = MediaQuery.of(context).size.width < 600;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24, 
            vertical: isMobile ? 16 : 24
          ),
          child: SizedBox(
            width: isMobile ? double.infinity : 720,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMobile)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Return to Withdrawal screen'),
                        ),
                      ),
                    if (!isMobile) const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Request Withdrawal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Available Balance: ZMW ${balance.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    const Text('Amount (ZMW)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountCtrl, 
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Withdrawal Method'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _method,
                      items: const [
                        DropdownMenuItem(value: 'mobile', child: Text('Mobile Money')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                      ],
                      onChanged: (v) => setState(() => _method = v),
                      decoration: InputDecoration(
                        hintText: 'Select a method',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Account Details'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _accountCtrl,
                      decoration: InputDecoration(
                        hintText: 'Enter account number/phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 12 : 14,
                          ),
                        ),
                        child: const Text('Submit Withdrawal Request'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.05),
                        border: const Border(left: BorderSide(width: 3, color: Color(0xFF2563EB))),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Note: After submitting your withdrawal request, the TryBae team will review it and contact you to confirm before processing.',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          SizedBox(height: isMobile ? 4 : 6),
                          Text(
                            'Processing time is typically 1-3 business days after confirmation.',
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitWithdrawal() async {
    Navigator.of(context).pop();
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final method = _method ?? 'mobile';
    final account = _accountCtrl.text.trim();
    if (amount <= 0 || account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount and account details')));
      return;
    }
    try {
      final business = ref.read(selectedBusinessProvider);
      final businessId = business?.id;
      if (businessId == null || businessId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a business first')));
        return;
      }
      await _api.createWithdrawal(
        businessId: businessId,
        amount: amount,
        method: method,
        accountDetails: account,
      );
      _amountCtrl.clear();
      _accountCtrl.clear();
      _method = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request submitted')));
        await _refresh();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;
  final bool isMobile;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10, 
        vertical: isMobile ? 4 : 6
      ),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: textColor),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            label, 
            style: TextStyle(
              color: textColor, 
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}


