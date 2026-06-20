import 'package:flutter/material.dart';
import 'package:lu_serve/models/bus_schedule.dart';
import 'package:lu_serve/services/bus_schedule_service.dart';

class ManageBusScheduleScreen extends StatefulWidget {
  const ManageBusScheduleScreen({super.key});

  @override
  State<ManageBusScheduleScreen> createState() =>
      _ManageBusScheduleScreenState();
}

class _ManageBusScheduleScreenState extends State<ManageBusScheduleScreen> {
  final _busService = BusScheduleService();
  final _searchController = TextEditingController();
  final _busNumberController = TextEditingController();
  final _routeController = TextEditingController();
  final _timeController = TextEditingController();

  List<BusSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _busNumberController.dispose();
    _routeController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    try {
      final schedules = await _busService.getAllSchedules();
      if (mounted) setState(() => _schedules = schedules);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSchedule(BusSchedule schedule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Schedule"),
        content: Text('Delete "${schedule.busNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _busService.deleteSchedule(schedule.id);
        await _loadSchedules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showEditDialog(BusSchedule schedule) {
    _busNumberController.text = schedule.busNumber;
    _routeController.text = schedule.route;
    _timeController.text = schedule.departureTime;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _busNumberController,
              decoration: const InputDecoration(labelText: "Bus Number"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(labelText: "Route"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: "Departure Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_busNumberController.text.trim().isEmpty) return;
              try {
                await _busService.updateSchedule(schedule.id, {
                  'bus_number': _busNumberController.text.trim(),
                  'route': _routeController.text.trim(),
                  'departure_time': _timeController.text.trim(),
                });
                if (mounted) Navigator.pop(ctx);
                await _loadSchedules();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Bus Schedule"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Route",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (query) async {
                try {
                  final schedules = query.isEmpty
                      ? await _busService.getAllSchedules()
                      : await _busService.searchSchedules(query);
                  if (mounted) setState(() => _schedules = schedules);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _schedules.isEmpty
                  ? const Center(child: Text("No schedules found"))
                  : ListView.builder(
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.directions_bus,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(schedule.busNumber),
                            subtitle: Text(
                              '${schedule.route}\n${schedule.departureTime}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showEditDialog(schedule),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteSchedule(schedule),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.pushNamed(context, '/addBusSchedule');
          _loadSchedules();
        },
      ),
    );
  }
}
