import 'package:lu_serve/models/calendar_event.dart';
import 'package:lu_serve/services/supabase_service.dart';

class CalendarService {
  final _supabase = supabase;

  /// Fetch all calendar events, ordered by date
  Future<List<CalendarEvent>> getAllEvents() async {
    final response = await _supabase
        .from('calendar_events')
        .select('*')
        .order('event_date', ascending: true);

    return (response as List).map((e) => CalendarEvent.fromMap(e)).toList();
  }

  /// Create a new calendar event
  Future<CalendarEvent> createEvent(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('calendar_events')
        .insert(data)
        .select()
        .single();

    return CalendarEvent.fromMap(response);
  }

  /// Update an existing calendar event
  Future<CalendarEvent> updateEvent(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _supabase
        .from('calendar_events')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return CalendarEvent.fromMap(response);
  }

  /// Delete a calendar event
  Future<void> deleteEvent(String id) async {
    await _supabase.from('calendar_events').delete().eq('id', id);
  }

  /// Get total count of calendar events
  Future<int> getEventsCount() async {
    final response = await _supabase.from('calendar_events').select('id');
    return (response as List).length;
  }
}
