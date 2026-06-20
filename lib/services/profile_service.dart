import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/supabase_service.dart';

class ProfileService {
  final _supabase = supabase;

  /// Get the current user's profile
  Future<Profile?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return Profile.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Get a profile by user ID
  Future<Profile?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Create or update the current user's profile
  Future<Profile> upsertProfile(Map<String, dynamic> profileData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final data = {
      'id': user.id,
      ...profileData,
    };

    final response = await _supabase
        .from('profiles')
        .upsert(data)
        .select()
        .single();

    return Profile.fromMap(response);
  }

  /// Update the current user's profile
  Future<Profile> updateProfile(Map<String, dynamic> updates) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final response = await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id)
        .select()
        .single();

    return Profile.fromMap(response);
  }

  /// Check if the current user is an admin
  Future<bool> isAdmin() async {
    final profile = await getCurrentProfile();
    return profile?.isAdmin ?? false;
  }
}
