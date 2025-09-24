import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/dashboard.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../services/supabase_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8001/api/v1';
  static const Duration timeout = Duration(seconds: 60);
  static const Duration longTimeout = Duration(seconds: 90);
  
  // HTTP client with timeout
  final http.Client _client = http.Client();
  
  // Auth token storage
  String? _authToken;
  
  // Headers for all requests
  Map<String, String> get _headers {
    final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    };
    
    // Ensure we always send a valid Supabase access token if available
    final sessionToken = _authToken ?? SupabaseService.client.auth.currentSession?.accessToken;
    if (sessionToken != null && sessionToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ' + sessionToken;
    }
    
    return headers;
  }
    
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Set auth token for authenticated requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Initialize the API service
  static Future<void> init() async {
    // API service initialization (if needed)
    print('🚀 API Service initialized');
  }

  // Generic HTTP GET method
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 GET Request: $uri');
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ GET Error for $endpoint: $e');
      throw _handleError(e);
    }
  }

  // Public passthrough for generic GET (used by UI widgets needing simple reads)
  Future<Map<String, dynamic>> getRaw(String endpoint) async {
    return _get(endpoint);
  }

  // Generic HTTP POST method (make it public for auth)
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    return await _post(endpoint, data);
  }

  // Generic HTTP POST method (private)
  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    return _postWithTimeout(endpoint, data, timeout);
  }

  // POST with custom timeout (for long-running endpoints like RAG)
  Future<Map<String, dynamic>> _postWithTimeout(String endpoint, Map<String, dynamic> data, Duration customTimeout) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 POST Request: $uri');
      print('📤 Request Body: ${jsonEncode(data)}');
      
      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(customTimeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error for $endpoint: $e');
      throw _handleError(e);
  }
  }

  // Generic HTTP PUT method
  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 PUT Request: $uri');
      print('📤 Request Body: ${jsonEncode(data)}');
      
      final response = await _client
          .put(uri, headers: _headers, body: jsonEncode(data))
          .timeout(timeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ PUT Error for $endpoint: $e');
      throw _handleError(e);
    }
  }

  // Generic HTTP DELETE method
  Future<Map<String, dynamic>> _delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('🌐 DELETE Request: $uri');
      
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(timeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error for $endpoint: $e');
      throw _handleError(e);
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      try {
        final decoded = jsonDecode(response.body);
        // Normalize list responses into a consistent map shape
        if (decoded is List) {
          return {'data': decoded};
        }
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        // Fallback to string-ify other primitives
        return {'data': decoded};
      } catch (e) {
        throw ApiException('Invalid JSON response: ${response.body}');
      }
    } else {
      String errorMessage = 'HTTP ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['detail'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
  }
}

  // Handle errors
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return ApiException('No internet connection');
    } else if (error is http.ClientException) {
      return ApiException('Network error: ${error.message}');
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException('Unexpected error: $error');
    }
  }

  // =============================================================================
  // DASHBOARD API METHODS
  // =============================================================================

  /// Get comprehensive dashboard data
  Future<DashboardResponse> getDashboardData({String? businessId}) async {
    try {
      String endpoint = '/dashboard';
      if (businessId != null && businessId.isNotEmpty) {
        endpoint += '?business_id=$businessId';
      }

      final response = await _get(endpoint);
      return DashboardResponse.fromJson(response);
    } catch (e) {
      print('❌ Dashboard API Error: $e');
      // Re-throw the error instead of returning empty data
      // This ensures the UI shows proper error states
      throw ApiException('Failed to load dashboard data: ${e.toString()}');
    }
  }

  // =============================================================================
  // ANALYTICS API METHODS
  // =============================================================================

  Future<Map<String, int>> getCustomerGenderBreakdown({String? businessId}) async {
    String endpoint = '/analytics/customers/gender';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    return {
      'male': (res['male'] ?? 0) as int,
      'female': (res['female'] ?? 0) as int,
    };
  }

  Future<List<Map<String, dynamic>>> getCustomerLocations({String? businessId}) async {
    String endpoint = '/analytics/customers/locations';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getCustomerGenderStats({String? businessId}) async {
    String endpoint = '/analytics/customers/gender_stats';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    return res;
  }

  Future<List<Map<String, dynamic>>> getTopCustomers({int limit = 5, String? businessId}) async {
    String endpoint = '/analytics/customers/top?limit=$limit';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getSalesTotalOverTime({String period = 'monthly', String? businessId}) async {
    String endpoint = '/analytics/sales/total_over_time?period=$period';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // Lightweight customers fetch for analytics tables
  Future<List<Map<String, dynamic>>> getCustomersRaw({int limit = 100, String? businessId}) async {
    String endpoint = '/customers?limit=$limit';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // =============================================================================
  // CUSTOMER API METHODS
  // =============================================================================

  /// Get all customers
  Future<CustomerListResponse> getCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? businessId,
  }) async {
    String endpoint = '/customers?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }

    final response = await _get(endpoint);
    return CustomerListResponse.fromJson(response);
  }

  /// Get customer by ID
  Future<Customer> getCustomer(String customerId) async {
    final response = await _get('/customers/$customerId');
    return Customer.fromJson(response);
  }

  /// Create new customer
  Future<Customer> createCustomer(CustomerCreateRequest request) async {
    final response = await _post('/customers', request.toJson());
    return Customer.fromJson(response);
  }

  /// Update customer
  Future<Customer> updateCustomer(String customerId, CustomerUpdateRequest request) async {
    final response = await _put('/customers/$customerId', request.toJson());
    return Customer.fromJson(response);
  }

  /// Delete customer
  Future<void> deleteCustomer(String customerId) async {
    await _delete('/customers/$customerId');
  }

  // =============================================================================
  // PRODUCT API METHODS
  // =============================================================================

  /// Get all products
  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? businessId,
  }) async {
    String endpoint = '/products?page=$page&limit=$limit';
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=${Uri.encodeComponent(search)}';
    }
    if (category != null && category.isNotEmpty) {
      endpoint += '&category=${Uri.encodeComponent(category)}';
    }
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }

    final response = await _get(endpoint);
    return ProductListResponse.fromJson(response);
  }

  /// Get product by ID
  Future<Product> getProduct(String productId) async {
    final response = await _get('/products/$productId');
    return Product.fromJson(response);
  }

  /// Create new product
  Future<Product> createProduct(ProductCreateRequest request) async {
    final response = await _post('/products', request.toJson());
    return Product.fromJson(response);
  }

  /// Update product
  Future<Product> updateProduct(String productId, ProductUpdateRequest request) async {
    final response = await _put('/products/$productId', request.toJson());
    return Product.fromJson(response);
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    await _delete('/products/$productId');
  }

  // =============================================================================
  // BUSINESS API METHODS
  // =============================================================================

  /// Get all businesses
  Future<List<Business>> getBusinesses({int skip = 0, int limit = 100}) async {
    try {
      final response = await _get('/business?skip=$skip&limit=$limit');
      final List<dynamic> businessesJson = response['data'] ?? response as List<dynamic>;
      return businessesJson.map((json) => Business.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching businesses: $e');
      // If unauthorized, try to refresh Supabase session and retry once
      if (e is ApiException && e.statusCode == 401) {
        try {
          final session = await SupabaseService.refreshSession();
          final token = session?.accessToken ?? SupabaseService.client.auth.currentSession?.accessToken;
          if (token != null) {
            setAuthToken(token);
            final response = await _get('/business?skip=$skip&limit=$limit');
            final List<dynamic> businessesJson = response['data'] ?? response as List<dynamic>;
            return businessesJson.map((json) => Business.fromJson(json)).toList();
          }
        } catch (_) {}
      }
      throw Exception('Failed to fetch businesses: $e');
    }
  }

  /// Get business by ID
  Future<Business> getBusiness(String businessId) async {
    try {
      final response = await _get('/business/$businessId');
      return Business.fromJson(response);
    } catch (e) {
      print('❌ Error fetching business: $e');
      throw Exception('Failed to fetch business: $e');
    }
  }

  /// Create new business
  Future<Business> createBusiness({
    required String name,
    String? alias,
    String? industry,
    String? registrationNumber,
    String? phoneNumber,
  }) async {
    try {
      final response = await _post('/business', {
        'name': name,
        'alias': alias,
        'industry': industry,
        'registration_number': registrationNumber,
        'phone_number': phoneNumber,
      });
      return Business.fromJson(response);
    } catch (e) {
      print('❌ Error creating business: $e');
      throw Exception('Failed to create business: $e');
    }
  }

  /// Update business
  Future<Business> updateBusiness(
    String businessId, {
    required String name,
    String? alias,
    String? industry,
    String? registrationNumber,
    String? phoneNumber,
  }) async {
    try {
      final response = await _put('/business/$businessId', {
        'name': name,
        'alias': alias,
        'industry': industry,
        'registration_number': registrationNumber,
        'phone_number': phoneNumber,
      });
      return Business.fromJson(response);
    } catch (e) {
      print('❌ Error updating business: $e');
      throw Exception('Failed to update business: $e');
    }
  }

  /// Delete business
  Future<void> deleteBusiness(String businessId) async {
    try {
      await _delete('/business/$businessId');
    } catch (e) {
      print('❌ Error deleting business: $e');
      throw Exception('Failed to delete business: $e');
    }
  }

  // =============================================================================
  // HEALTH CHECK
  // =============================================================================

  /// Check if API is healthy
  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health Check Failed: $e');
      return false;
    }
  }

  // =============================================================================
  // WALLET API METHODS
  // =============================================================================

  Future<double> getWalletBalance({String? businessId}) async {
    String endpoint = '/wallet/balance';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    return (res['balance'] ?? 0).toDouble();
  }

  Future<List<Map<String, dynamic>>> getWithdrawals({String? businessId}) async {
    String endpoint = '/wallet/withdrawals';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createWithdrawal({
    required String businessId,
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    final body = {
      'business_id': businessId,
      'amount': amount,
      'method': method,
      'account_details': accountDetails,
    };
    final res = await _post('/wallet/withdrawals', body);
    return res;
  }

  // =============================================================================
  // AI ENDPOINTS (SALES & CUSTOMERS)
  // =============================================================================

  Future<Map<String, List<Map<String, dynamic>>>> getSalesForecast({int horizonDays = 30, String? businessId}) async {
    String endpoint = '/ai/sales/forecast?horizon_days=$horizonDays';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '&business_id=$businessId';
    }
    final res = await _get(endpoint);
    final actual = ((res['actual'] ?? []) as List).cast<Map<String, dynamic>>();
    final forecast = ((res['forecast'] ?? []) as List).cast<Map<String, dynamic>>();
    return { 'actual': actual, 'forecast': forecast };
  }

  Future<String> getSalesNarrative({String? businessId}) async {
    String endpoint = '/ai/sales/narrative';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    return (res['narrative'] ?? '') as String;
  }

  Future<List<Map<String, dynamic>>> getCustomerSegments({String? businessId}) async {
    String endpoint = '/ai/customers/segments';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    final list = (res['data'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<String> getCustomerNarrative({String? businessId}) async {
    String endpoint = '/ai/customers/narrative';
    if (businessId != null && businessId.isNotEmpty) {
      endpoint += '?business_id=$businessId';
    }
    final res = await _get(endpoint);
    return (res['narrative'] ?? '') as String;
  }

  /// Test Supabase connection
  Future<Map<String, dynamic>> testSupabaseConnection() async {
    try {
      final response = await _get('/test-connection');
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Test RAG Backend connection
  Future<Map<String, dynamic>> testRagBackendConnection() async {
    try {
      final response = await _get('/rag/recent-questions');
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Dispose method to close HTTP client
  void dispose() {
    _client.close();
  }
}

// Custom Exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (HTTP $statusCode)' : ''}';
}

// Extension for easy error handling
extension ApiServiceExtension on ApiService {
  Future<T> safeCall<T>(Future<T> Function() apiCall, {T? fallback}) async {
    try {
      return await apiCall();
    } catch (e) {
      print('🛡️ Safe API Call Failed: $e');
      if (fallback != null) {
        return fallback;
      }
      rethrow;
    }
  }

  // =============================================================================
  // LENNY RAG ENDPOINTS - Connected to Working RAG Backend
  // =============================================================================

  Future<String> lennyQuery({
    required String question,
    required String sessionId,
    required String userId,
    required String userName,
  }) async {
    final body = {
      'question': question,
      'session_id': sessionId,
    };
    final res = await _postWithTimeout('/rag/query', body, ApiService.longTimeout);
    return (res['response'] ?? '') as String;
  }

  Future<List<Map<String, dynamic>>> lennyRecentQuestions({
    required String userId,
  }) async {
    final res = await _get('/rag/recent-questions');
    final list = (res['recent'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> lennyChatSession({
    required String sessionId,
    required String userId,
  }) async {
    final res = await _get('/rag/chat-session?session_id=$sessionId');
    final list = (res['session'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> lennyChatHistory({
    required String userId,
  }) async {
    final res = await _get('/rag/chat-history');
    final list = (res['history'] ?? []) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> lennyUploadFile({
    required String fileName,
    required List<int> bytes,
    required String userId,
    required String userName,
    String? contentType,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/rag/upload-file');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);
    
    // Add file
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
      contentType: contentType != null ? MediaType.parse(contentType) : null,
    ));
    
    final streamed = await request.send().timeout(ApiService.timeout);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }
} 