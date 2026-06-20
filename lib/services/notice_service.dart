import 'package:lu_serve/models/notice.dart';
import 'package:lu_serve/services/supabase_service.dart';

class NoticeService {
  final _supabase = supabase;

  /// Fetch all notices, newest first
  Future<List<Notice>> getAllNotices() async {
    final response = await _supabase
        .from('notices')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Notice.fromMap(e)).toList();
  }

  /// Search notices by title or content
  Future<List<Notice>> searchNotices(String query) async {
    final response = await _supabase
        .from('notices')
        .select('*')
        .or('title.ilike.%$query%,content.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Notice.fromMap(e)).toList();
  }

  /// Create a new notice
  Future<Notice> createNotice(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('notices')
        .insert(data)
        .select()
        .single();

    return Notice.fromMap(response);
  }

  /// Update an existing notice
  Future<Notice> updateNotice(String id, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('notices')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return Notice.fromMap(response);
  }

  /// Delete a notice
  Future<void> deleteNotice(String id) async {
    await _supabase.from('notices').delete().eq('id', id);
  }

  /// Get total count of notices
  Future<int> getNoticesCount() async {
    final response = await _supabase.from('notices').select('id');
    return (response as List).length;
  }
}
