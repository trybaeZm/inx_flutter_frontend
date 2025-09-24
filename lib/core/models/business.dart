class Business {
  final String id;
  final String name;
  final String? alias;
  final String? industry;
  final String? registrationNumber;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    this.alias,
    this.industry,
    this.registrationNumber,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic v) => v?.toString() ?? '';
    String? parseNullableString(dynamic v) => v == null ? null : v.toString();
    DateTime parseDate(dynamic v, {DateTime? fallback}) {
      if (v == null) return fallback ?? DateTime.now();
      final s = v.toString();
      return DateTime.tryParse(s) ?? (fallback ?? DateTime.now());
    }

    final id = parseString(json['id']);
    final name = parseString(json['business_name'] ?? json['name']);
    final alias = parseNullableString(json['company_alias'] ?? json['alias']);
    final industry = parseNullableString(json['industry']);
    final registrationNumber = parseNullableString(json['registration_number']);
    final phoneNumber = parseNullableString(json['phone'] ?? json['phone_number']);
    final createdAt = parseDate(json['created_at']);
    final updatedAt = parseDate(json['updated_at'] ?? json['created_at'], fallback: createdAt);

    return Business(
      id: id,
      name: name,
      alias: alias,
      industry: industry,
      registrationNumber: registrationNumber,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'alias': alias,
      'industry': industry,
      'registration_number': registrationNumber,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => alias?.isNotEmpty == true ? alias! : name;
  
  String get subtitle {
    final parts = <String>[];
    if (alias?.isNotEmpty == true && alias != name) {
      parts.add(alias!.substring(0, 1).toUpperCase());
    } else {
      parts.add(name.substring(0, 1).toUpperCase());
    }
    if (industry?.isNotEmpty == true) {
      parts.add(industry!.toLowerCase());
    }
    return parts.join(' • ');
  }
} 