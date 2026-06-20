import 'package:lu_serve/models/bus_schedule.dart';
import 'package:lu_serve/services/supabase_service.dart';

class BusScheduleService {
  final _supabase = supabase;

  /// Fetch all bus schedules
  Future<List<BusSchedule>> getAllSchedules() async {
    final response = await _supabase
        .from('bus_schedules')
        .select('*')
        .order('departure_time', ascending: true);

    return (response as List).map((e) => BusSchedule.fromMap(e)).toList();
  }

  /// Search bus schedules by route or bus number
  Future<List<BusSchedule>> searchSchedules(String query) async {
    final response = await _supabase
        .from('bus_schedules')
        .select('*')
        .or('route.ilike.%$query%,bus_number.ilike.%$query%')
        .order('departure_time', ascending: true);

    return (response as List).map((e) => BusSchedule.fromMap(e)).toList();
  }

  /// Create a new bus schedule
  Future<BusSchedule> createSchedule(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('bus_schedules')
        .insert(data)
        .select()
        .single();

    return BusSchedule.fromMap(response);
  }

  /// Update an existing bus schedule
  Future<BusSchedule> updateSchedule(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _supabase
        .from('bus_schedules')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return BusSchedule.fromMap(response);
  }

  /// Delete a bus schedule
  Future<void> deleteSchedule(String id) async {
    await _supabase.from('bus_schedules').delete().eq('id', id);
  }

  /// Get total count of bus schedules
  Future<int> getSchedulesCount() async {
    final response = await _supabase.from('bus_schedules').select('id');
    return (response as List).length;
  }
}
