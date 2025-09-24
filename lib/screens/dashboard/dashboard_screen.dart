import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_service.dart';
import '../../core/models/dashboard.dart';
import '../../widgets/common/notion_loading.dart';
import '../../widgets/common/responsive_wrapper.dart';
import 'components/total_revenue_card.dart';
import 'components/orders_card.dart';
import 'components/customer_return_card.dart';
import 'components/growth_rate_card.dart';
import 'components/customers_card.dart';
import 'components/last_transactions_table.dart';
import 'components/sales_by_category_chart.dart';
import 'components/top_selling_products.dart';
import 'components/today_orders_card.dart';
import 'components/ai_insights_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardResponse? _dashboardData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_dashboardData == null) {
      return _buildEmptyState();
    }

    return _buildDashboardContent();
  }

  Widget _buildLoadingState() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return ResponsiveWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          NotionLoading.textSkeleton(width: 200, height: 28),
          const SizedBox(height: 8),
          NotionLoading.textSkeleton(width: 300, height: 16),
          const SizedBox(height: 32),
          
          // Stats Cards Row
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 4,
            children: [
              NotionLoading.dashboardCardSkeleton(),
              NotionLoading.dashboardCardSkeleton(),
              NotionLoading.dashboardCardSkeleton(),
              NotionLoading.dashboardCardSkeleton(),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Second Row
          ResponsiveGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            children: [
              NotionLoading.dashboardCardSkeleton(),
              NotionLoading.dashboardCardSkeleton(),
              NotionLoading.dashboardCardSkeleton(),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Tables and Charts
          if (isMobile) ...[
            // Mobile: Stack vertically
            NotionLoading.cardSkeleton(height: 400),
            const SizedBox(height: 24),
            NotionLoading.cardSkeleton(height: 300),
            const SizedBox(height: 24),
            NotionLoading.cardSkeleton(height: 300),
          ] else ...[
            // Tablet/Desktop: Side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    NotionLoading.cardSkeleton(height: 400),
                    const SizedBox(height: 24),
                    NotionLoading.cardSkeleton(height: 300),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              Expanded(
                child: Column(
                  children: [
                    NotionLoading.cardSkeleton(height: 300),
                    const SizedBox(height: 24),
                    NotionLoading.cardSkeleton(height: 400),
                  ],
                ),
              ),
            ],
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return NotionLoading.emptyState(
      icon: Icons.error_outline_rounded,
      title: 'Unable to load dashboard',
      subtitle: _error,
      action: ElevatedButton(
        onPressed: _loadDashboardData,
        child: const Text('Try Again'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return NotionLoading.emptyState(
      icon: Icons.dashboard_outlined,
      title: 'No data available',
      subtitle: 'Your dashboard will appear here once you have some data.',
    );
  }

  Widget _buildDashboardContent() {
    final data = _dashboardData!;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return ResponsiveWrapper(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
          ResponsiveText(
            'Dashboard Overview',
            style: theme.textTheme.displaySmall,
          ),
              const SizedBox(height: 8),
          ResponsiveText(
                'Welcome back! Here\'s what\'s happening with your business today.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 24),

          // Metrics grid + right-side AI Insights box
          if (isMobile) ...[
            // Mobile: Stack vertically
            ResponsiveGrid(
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              spacing: 12,
              runSpacing: 12,
              children: [
                TotalRevenueCard(stats: data.stats),
                OrdersCard(stats: data.stats),
                CustomerReturnCard(stats: data.stats),
                GrowthRateCard(stats: data.stats),
                CustomersCard(stats: data.stats),
                TodayOrdersCard(
                  todayOrders: data.todayOrders,
                  todayOrdersCount: data.stats.todayOrdersCount,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // AI Insights on mobile (full width)
            AiInsightsCard(),
          ] else ...[
            // Tablet/Desktop: Side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                  child: ResponsiveGrid(
                    mobileColumns: 1,
                    tabletColumns: 2,
                    desktopColumns: 3,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                      TotalRevenueCard(stats: data.stats),
                      OrdersCard(stats: data.stats),
                      CustomerReturnCard(stats: data.stats),
                      GrowthRateCard(stats: data.stats),
                      CustomersCard(stats: data.stats),
                      TodayOrdersCard(
                            todayOrders: data.todayOrders,
                            todayOrdersCount: data.stats.todayOrdersCount,
                          ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // AI Insights - shown on tablet/desktop
                SizedBox(
                  width: MediaQuery.of(context).size.width > 1100 ? 380 : 300,
                  child: AiInsightsCard(),
                        ),
                      ],
                    ),
          ],

          const SizedBox(height: 20),

          // Charts and tables
          if (isMobile) ...[
            // Mobile: Stack vertically
            ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    'Recent Transactions',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LastTransactionsTable(transactions: data.recentTransactions),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    'Sales by Category',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  SalesByCategoryChart(categorySales: data.categorySales),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    'Top Selling Products',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TopSellingProducts(products: data.topProducts),
                ],
              ),
            ),
          ] else ...[
            // Tablet/Desktop: Side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ResponsiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResponsiveText(
                              'Recent Transactions',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            LastTransactionsTable(transactions: data.recentTransactions),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ResponsiveCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ResponsiveText(
                              'Sales by Category',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            SalesByCategoryChart(categorySales: data.categorySales),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ResponsiveCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          'Top Selling Products',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        TopSellingProducts(products: data.topProducts),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
  }
} 