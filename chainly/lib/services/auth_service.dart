import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication Service
/// Handles all authentication-related operations with Supabase
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user ID
  String? get currentUserId => currentUser?.id;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    return await _client.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  /// Get user display name
  String get displayName {
    final metadata = currentUser?.userMetadata;
    return metadata?['full_name'] ?? currentUser?.email?.split('@').first ?? 'User';
  }

  /// Get user email
  String get email => currentUser?.email ?? '';
}
