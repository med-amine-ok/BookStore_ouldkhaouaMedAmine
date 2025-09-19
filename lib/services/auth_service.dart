import 'package:camera/camera.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import './storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null && response.session != null) {
        debugPrint('✅ User signed up successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        debugPrint('✅ User signed in successfully: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent to: $email');
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      rethrow;
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      debugPrint('✅ Password updated successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Password update error: $e');
      rethrow;
    }
  }

  // Get user profile from your custom table
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('user')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Get user profile error: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      // Update custom user table
      await _supabase
          .from('user')
          .update({
            if (fullName != null) 'full_name': fullName,
            if (phoneNumber != null) 'phone_number': phoneNumber,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', currentUser!.id);

      // Update auth metadata for consistency across app
      if (fullName != null || phoneNumber != null || avatarUrl != null) {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              if (fullName != null) 'full_name': fullName,
              if (phoneNumber != null) 'phone_number': phoneNumber,
              if (avatarUrl != null) 'avatar_url': avatarUrl,
            },
          ),
        );
      }

      debugPrint('✅ User profile updated successfully');
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      rethrow;
    }
  }

  // Upload and update user avatar
  Future<String?> updateUserAvatar(
    XFile? imageFile, {
    Uint8List? imageBytes,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    final storageService = StorageService();

    try {
      final avatarUrl = await storageService.uploadUserAvatar(
        currentUser!.id,
        imageFile: imageFile,
        imageBytes: imageBytes,
      );

      if (avatarUrl != null) {
        await updateUserProfile(avatarUrl: avatarUrl);

        debugPrint('✅ User avatar updated successfully');
        return avatarUrl;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Update avatar error: $e');
      rethrow;
    }
  }

  // Get JWT token
  String? get accessToken => currentSession?.accessToken;

  // Get refresh token
  String? get refreshToken => currentSession?.refreshToken;

  // Check if token needs refresh
  bool get needsRefresh {
    if (currentSession == null) return false;
    final expiresAt = currentSession!.expiresAt;
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    // Refresh if expires in next 60 seconds
    return (expiresAt! - now) < 60;
  }

  // Manually refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await _supabase.auth.refreshSession();
      debugPrint('✅ Session refreshed successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Session refresh error: $e');
      rethrow;
    }
  }
}
