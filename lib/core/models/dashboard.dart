class DashboardResponse {
  final DashboardStats stats;
  final List<RevenueChartData> revenueChartData;
  final List<CategorySales> categorySales;  // Changed from salesByCategory
  final List<TopProduct> topProducts;       // Changed from topSellingProducts
  final List<RecentTransaction> recentTransactions;
  final List<TodayOrderData> todayOrders;

  DashboardResponse({
    required this.stats,
    required this.revenueChartData,
    required this.categorySales,
    required this.topProducts,
    required this.recentTransactions,
    required this.todayOrders,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
      revenueChartData: (json['revenue_chart_data'] as List?)
          ?.map((e) => RevenueChartData.fromJson(e))
          .toList() ?? [],
      categorySales: (json['category_sales'] as List?)
          ?.map((e) => CategorySales.fromJson(e))
          .toList() ?? [],
      topProducts: (json['top_products'] as List?)
          ?.map((e) => TopProduct.fromJson(e))
          .toList() ?? [],
      recentTransactions: (json['recent_transactions'] as List?)
          ?.map((e) => RecentTransaction.fromJson(e))
          .toList() ?? [],
      todayOrders: (json['today_orders'] as List?)
          ?.map((e) => TodayOrderData.fromJson(e))
          .toList() ?? [],
    );
  }
}

class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final int totalCustomers;
  final double growthRate;
  final double customerReturnRate;
  final int todayOrders;
  final int todayOrdersCount;  // Added missing property

  DashboardStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalCustomers,
    required this.growthRate,
    required this.customerReturnRate,
    required this.todayOrders,
    required this.todayOrdersCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalOrders: (json['total_orders'] ?? 0).toInt(),
      totalCustomers: (json['total_customers'] ?? 0).toInt(),
      growthRate: (json['growth_rate'] ?? 0).toDouble(),
      customerReturnRate: (json['customer_return_rate'] ?? 0).toDouble(),
      todayOrders: (json['today_orders'] ?? 0).toInt(),
      todayOrdersCount: (json['today_orders_count'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'total_customers': totalCustomers,
      'growth_rate': growthRate,
      'customer_return_rate': customerReturnRate,
      'today_orders': todayOrders,
      'today_orders_count': todayOrdersCount,
    };
  }
}

class RevenueChartData {
  final String month;
  final double revenue;

  RevenueChartData({
    required this.month,
    required this.revenue,
  });

  factory RevenueChartData.fromJson(Map<String, dynamic> json) {
    return RevenueChartData(
      month: json['month'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'revenue': revenue,
    };
  }
}

class CategorySales {
  final String category;
  final double sales;
  final double percentage;

  CategorySales({
    required this.category,
    required this.sales,
    required this.percentage,
  });

  factory CategorySales.fromJson(Map<String, dynamic> json) {
    return CategorySales(
      category: json['category'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'sales': sales,
      'percentage': percentage,
    };
  }
}

class TopProduct {
  final String id;
  final String name;
  final String image;
  final double sales;
  final int quantity;

  TopProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.sales,
    required this.quantity,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      sales: (json['sales'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'sales': sales,
      'quantity': quantity,
    };
  }
}

class RecentTransaction {
  final String orderId;
  final String customerName;
  final double amount;
  final String status;
  final DateTime date;

  RecentTransaction({
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_name': customerName,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
    };
  }
}

class TodayOrderData {
  final String orderId;
  final String customerName;
  final double amount;
  final String status;
  final DateTime time;

  TodayOrderData({
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.time,
  });

  factory TodayOrderData.fromJson(Map<String, dynamic> json) {
    return TodayOrderData(
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_name': customerName,
      'amount': amount,
      'status': status,
      'time': time.toIso8601String(),
    };
  }
}

class ApiError {
  final String message;
  final int? statusCode;

  ApiError({
    required this.message,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? '',
      statusCode: json['status_code'],
    );
  }
}

// Loading States
enum DashboardLoadingState {
  initial,
  loading,
  loaded,
  error,
}

// Dashboard State Model for State Management
class DashboardState {
  final DashboardLoadingState loadingState;
  final DashboardResponse? data;
  final String? errorMessage;

  DashboardState({
    this.loadingState = DashboardLoadingState.initial,
    this.data,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardLoadingState? loadingState,
    DashboardResponse? data,
    String? errorMessage,
  }) {
    return DashboardState(
      loadingState: loadingState ?? this.loadingState,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => loadingState == DashboardLoadingState.loading;
  bool get hasData => data != null && loadingState == DashboardLoadingState.loaded;
  bool get hasError => loadingState == DashboardLoadingState.error;
} 