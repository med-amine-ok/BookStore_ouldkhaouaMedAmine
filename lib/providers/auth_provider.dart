import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? errorMessage;
  final bool isPasswordResetSent;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
    this.isPasswordResetSent = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? errorMessage,
    bool? isPasswordResetSent,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordResetSent: isPasswordResetSent ?? this.isPasswordResetSent,
    );
  }

  // Factory for initial state
  factory AuthState.initial() => const AuthState();

  // Factory for loading state
  factory AuthState.loading() => const AuthState(isLoading: true);

  // Factory for authenticated state
  factory AuthState.authenticated(User user) =>
      AuthState(isAuthenticated: true, user: user);

  // Factory for unauthenticated state
  factory AuthState.unauthenticated() => const AuthState();

  // Factory for error state
  factory AuthState.error(String message) => AuthState(errorMessage: message);

  // Factory for password reset sent state
  factory AuthState.passwordResetSent() =>
      const AuthState(isPasswordResetSent: true);
}

// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    final user = _authService.currentUser;
    if (user != null) {
      state = AuthState.authenticated(user);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  // Listen to auth state changes from Supabase
  void listenToAuthChanges() {
    _authService.authStateChanges.listen((authState) {
      switch (authState.event) {
        case AuthChangeEvent.signedIn:
          if (authState.session?.user != null) {
            state = AuthState.authenticated(authState.session!.user!);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = AuthState.unauthenticated();
          break;
        case AuthChangeEvent.tokenRefreshed:
          if (authState.session?.user != null) {
            state = AuthState.authenticated(authState.session!.user!);
          }
          break;
        default:
          break;
      }
    });
  }

  // Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.session != null && response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        // Sign-up successful but user needs to confirm email or similar
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.resetPassword(email);
      state = AuthState.passwordResetSent();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.signOut();
      state = AuthState.unauthenticated();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Clear password reset sent state
  void clearPasswordResetSent() {
    state = state.copyWith(isPasswordResetSent: false);
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    return await _authService.getUserProfile();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    try {
      await _authService.updateUserProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Check if token needs refresh
  bool get needsRefresh => _authService.needsRefresh;

  // Refresh session
  Future<void> refreshSession() async {
    try {
      await _authService.refreshSession();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final authNotifier = AuthNotifier(authService);

  // Start listening to auth state changes
  authNotifier.listenToAuthChanges();

  return authNotifier;
});

// Convenience providers for specific auth state properties
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});

final isPasswordResetSentProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isPasswordResetSent;
});
