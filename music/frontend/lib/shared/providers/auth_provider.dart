import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  AuthNotifier(this._apiClient, this._prefs) : super(const AuthState()) {
    _loadSavedAuth();
  }

  Future<void> _loadSavedAuth() async {
    final accessToken = _prefs.getString(AppConstants.accessTokenKey);
    final userJson = _prefs.getString(AppConstants.userKey);

    if (accessToken != null && userJson != null) {
      _apiClient.setAccessToken(accessToken);
      final user = User.fromJson(jsonDecode(userJson));
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  }

  Future<void> _saveAuth(AuthResponse response) async {
    await _prefs.setString(AppConstants.accessTokenKey, response.accessToken);
    await _prefs.setString(AppConstants.refreshTokenKey, response.refreshToken);
    await _prefs.setString(AppConstants.userKey, jsonEncode(response.user.toJson()));
    _apiClient.setAccessToken(response.accessToken);
  }

  Future<void> _clearAuth() async {
    await _prefs.remove(AppConstants.accessTokenKey);
    await _prefs.remove(AppConstants.refreshTokenKey);
    await _prefs.remove(AppConstants.userKey);
    _apiClient.setAccessToken(null);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _apiClient.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final authResponse = AuthResponse.fromJson(body['data']);
      await _saveAuth(authResponse);
      state = state.copyWith(
        user: authResponse.user,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _apiClient.post('/api/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final authResponse = AuthResponse.fromJson(body['data']);
      await _saveAuth(authResponse);
      state = state.copyWith(
        user: authResponse.user,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _clearAuth();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(apiClient, prefs);
});
