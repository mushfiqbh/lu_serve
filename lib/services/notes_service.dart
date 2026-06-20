import 'package:lu_serve/models/note.dart';
import 'package:lu_serve/services/supabase_service.dart';

class NotesService {
  final _supabase = supabase;

  /// Fetch all notes, newest first
  Future<List<Note>> getAllNotes() async {
    final response = await _supabase
        .from('notes')
        .select('*')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Note.fromMap(e)).toList();
  }

  /// Search notes by subject or course code
  Future<List<Note>> searchNotes(String query) async {
    final response = await _supabase
        .from('notes')
        .select('*')
        .or('subject.ilike.%$query%,course_code.ilike.%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((e) => Note.fromMap(e)).toList();
  }

  /// Upload a new note record
  Future<Note> createNote(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('notes')
        .insert(data)
        .select()
        .single();

    return Note.fromMap(response);
  }

  /// Update an existing note
  Future<Note> updateNote(String id, Map<String, dynamic> updates) async {
    final response = await _supabase
        .from('notes')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return Note.fromMap(response);
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }

  /// Get total count of notes
  Future<int> getNotesCount() async {
    final response = await _supabase.from('notes').select('id');
    return (response as List).length;
  }
}
