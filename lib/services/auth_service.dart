import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/profile_service.dart';
import 'package:lu_serve/services/supabase_service.dart';

class AuthService extends ChangeNotifier {
  final _supabase = supabase;
  final ProfileService _profileService = ProfileService();

  Profile? _currentProfile;
  bool _isLoading = false;
  String? _error;

  Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  /// Initialize auth state and check for existing session
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for existing session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Listen for auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        await _loadProfile();
      } else {
        _currentProfile = null;
        notifyListeners();
      }
    });
  }

  /// Load the current user's profile
  Future<void> _loadProfile() async {
    try {
      _currentProfile = await _profileService.getCurrentProfile();
    } catch (e) {
      _currentProfile = null;
    }
    notifyListeners();
  }

  /// Sign up with email and password, then create a profile
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
    String? department,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (authResponse.session != null) {
        // Create the profile with additional info
        await _profileService.upsertProfile({
          'full_name': fullName,
          'email': email,
          if (studentId != null) 'student_id': studentId,
          if (department != null) 'department': department,
        });

        await _loadProfile();
      }

      return authResponse;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _loadProfile();

      return authResponse;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
      _currentProfile = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the current user's profile
  Future<Profile> updateProfile(Map<String, dynamic> updates) async {
    try {
      final profile = await _profileService.updateProfile(updates);
      _currentProfile = profile;
      notifyListeners();
      return profile;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  /// Send a password reset email
  Future<void> resetPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
