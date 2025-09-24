class Customer {
  final String id;
  final String customerId;
  final String businessId;
  final String name;
  final String? email;
  final String? phone;
  final String? location;
  final String? gender;
  final String? createdAt;

  Customer({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.name,
    this.email,
    this.phone,
    this.location,
    this.gender,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      gender: json['gender'],
      createdAt: json['created_at'],
    );
  }
}

class CustomerCreateRequest {
  final String name;
  final String? email;
  final String? phone;
  final String? location;
  final String? gender;
  final String businessId;

  CustomerCreateRequest({
    required this.name,
    this.email,
    this.phone,
    this.location,
    this.gender,
    required this.businessId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'gender': gender,
      'business_id': businessId,
    };
  }
}

class CustomerUpdateRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? location;
  final String? gender;

  CustomerUpdateRequest({
    this.name,
    this.email,
    this.phone,
    this.location,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (location != null) data['location'] = location;
    if (gender != null) data['gender'] = gender;
    return data;
  }
}

class CustomerResponse {
  final String id;
  final String customerId;
  final String businessId;
  final String name;
  final String? email;
  final String? phone;
  final String? location;
  final String? gender;
  final String? createdAt;

  CustomerResponse({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.name,
    this.email,
    this.phone,
    this.location,
    this.gender,
    this.createdAt,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      gender: json['gender'],
      createdAt: json['created_at'],
    );
  }
}

class CustomerListResponse {
  final List<CustomerResponse> customers;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  CustomerListResponse({
    required this.customers,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory CustomerListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerListResponse(
      customers: (json['customers'] as List?)
          ?.map((e) => CustomerResponse.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
}

class CustomerStatsResponse {
  final int totalCustomers;
  final int activeCustomers;
  final int newCustomersThisMonth;
  final double totalCustomerValue;
  final double averageCustomerValue;

  CustomerStatsResponse({
    required this.totalCustomers,
    required this.activeCustomers,
    required this.newCustomersThisMonth,
    required this.totalCustomerValue,
    required this.averageCustomerValue,
  });

  factory CustomerStatsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerStatsResponse(
      totalCustomers: json['total_customers'] ?? 0,
      activeCustomers: json['active_customers'] ?? 0,
      newCustomersThisMonth: json['new_customers_this_month'] ?? 0,
      totalCustomerValue: (json['total_customer_value'] ?? 0).toDouble(),
      averageCustomerValue: (json['average_customer_value'] ?? 0).toDouble(),
    );
  }
} 