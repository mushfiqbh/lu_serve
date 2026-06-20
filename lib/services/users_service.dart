import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/supabase_service.dart';

class UsersService {
  final _supabase = supabase;

  /// Fetch all users
  Future<List<Profile>> getAllUsers() async {
    final response = await _supabase
        .from('profiles')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Profile.fromMap(e)).toList();
  }

  /// Get total count of users
  Future<int> getUsersCount() async {
    final response = await _supabase.from('profiles').select('id');
    return (response as List).length;
  }

  /// Update a user's role (admin only)
  Future<void> updateUserRole(String userId, String role) async {
    await _supabase.from('profiles').update({'role': role}).eq('id', userId);
  }

  /// Search users by name, email, or student ID
  Future<List<Profile>> searchUsers(String query) async {
    final response = await _supabase
        .from('profiles')
        .select('*')
        .or(
          'full_name.ilike.%$query%,email.ilike.%$query%,student_id.ilike.%$query%',
        )
        .order('created_at', ascending: false);

    return (response as List).map((e) => Profile.fromMap(e)).toList();
  }
}
