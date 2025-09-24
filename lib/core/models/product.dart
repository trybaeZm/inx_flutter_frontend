class Product {
  final String id;
  final String productId;
  final String businessId;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? image;
  final int sold;
  final double profit;
  final String? createdAt;

  Product({
    required this.id,
    required this.productId,
    required this.businessId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.image,
    required this.sold,
    required this.profit,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'],
      image: json['image'],
      sold: json['sold'] ?? 0,
      profit: (json['profit'] ?? 0).toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class ProductCreateRequest {
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? image;
  final int sold;
  final double profit;
  final String businessId;

  ProductCreateRequest({
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.image,
    this.sold = 0,
    this.profit = 0.0,
    required this.businessId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'sold': sold,
      'profit': profit,
      'business_id': businessId,
    };
  }
}

class ProductUpdateRequest {
  final String? name;
  final String? description;
  final double? price;
  final String? category;
  final String? image;
  final int? sold;
  final double? profit;

  ProductUpdateRequest({
    this.name,
    this.description,
    this.price,
    this.category,
    this.image,
    this.sold,
    this.profit,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (category != null) data['category'] = category;
    if (image != null) data['image'] = image;
    if (sold != null) data['sold'] = sold;
    if (profit != null) data['profit'] = profit;
    return data;
  }
}

class ProductResponse {
  final String id;
  final String productId;
  final String businessId;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? image;
  final int sold;
  final double profit;
  final String? createdAt;

  ProductResponse({
    required this.id,
    required this.productId,
    required this.businessId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.image,
    required this.sold,
    required this.profit,
    this.createdAt,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'],
      image: json['image'],
      sold: json['sold'] ?? 0,
      profit: (json['profit'] ?? 0).toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class ProductListResponse {
  final List<ProductResponse> products;
  final int total;
  final int page;
  final int perPage;
  final int pages;

  ProductListResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['products'] as List?)
          ?.map((e) => ProductResponse.fromJson(e))
          .toList() ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }
} 