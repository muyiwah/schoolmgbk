import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Authentication state provider that persists across browser refreshes
class AuthState {
  final String? userRole;
  final String? token;
  final bool isAuthenticated;
  final bool isLoading;

  const AuthState({
    this.userRole,
    this.token,
    this.isAuthenticated = false,
    this.isLoading = true,
  });

  AuthState copyWith({
    String? userRole,
    String? token,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      userRole: userRole ?? this.userRole,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState()) {
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final savedRole = prefs.getString('saved_role');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (token != null && rememberMe && savedRole != null) {
        // User has valid stored credentials
        state = state.copyWith(
          userRole: savedRole.toLowerCase(),
          token: token,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        // No valid stored credentials
        state = state.copyWith(
          userRole: null,
          token: null,
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      // Error loading auth state, default to unauthenticated
      state = state.copyWith(
        userRole: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  Future<void> setAuthenticated({
    required String userRole,
    required String token,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('saved_role', userRole);

      state = state.copyWith(
        userRole: userRole.toLowerCase(),
        token: token,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('saved_role');
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);

      state = state.copyWith(
        userRole: null,
        token: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

// Provider for authentication state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(),
);

// Provider for current user role (derived from auth state)
final currentUserRoleProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.userRole ?? 'admin'; // Default to admin if no role
});

// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isAuthenticated;
});

// Provider for loading status
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});
