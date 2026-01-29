import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../generated/users/users_client.dart';
import '../generated/models/user_create.dart';
import '../generated/models/user.dart';
import '../generated/models/token.dart';
import '../generated/models/body_login_users_login_post.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance!;
  static set instance(AuthService service) => _instance = service;
  final Dio _dio;
  Dio get dio => _dio;
  late final UsersClient _client;
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  String? _token;

  AuthService({required String baseUrl})
    : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    _client = UsersClient(_dio);

    // Add interceptor to include token in requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> getToken() async {
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<User> register(String email, String password) async {
    try {
      final user = await _client.registerUsersRegisterPost(
        body: UserCreate(email: email, password: password),
      );
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<Token> login(String email, String password) async {
    try {
      final response = await _client.loginUsersLoginPost(
        body: BodyLoginUsersLoginPost(username: email, password: password),
      );

      _token = response.accessToken;
      await _storage.write(key: _tokenKey, value: _token);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getMe() async {
    return await _client.readUsersMeUsersMeGet();
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }
}
