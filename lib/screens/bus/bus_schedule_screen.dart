import 'package:flutter/material.dart';
import 'package:lu_serve/models/bus_schedule.dart';
import 'package:lu_serve/services/bus_schedule_service.dart';

class BusScheduleScreen extends StatefulWidget {
  const BusScheduleScreen({super.key});

  @override
  State<BusScheduleScreen> createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  final _busService = BusScheduleService();
  final _searchController = TextEditingController();

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
        ).showSnackBar(SnackBar(content: Text('Failed to load schedules: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchSchedules(String query) async {
    setState(() => _isLoading = true);
    try {
      final schedules = query.isEmpty
          ? await _busService.getAllSchedules()
          : await _busService.searchSchedules(query);
      if (mounted) setState(() => _schedules = schedules);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Schedule"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Bus Route",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: _searchSchedules,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _schedules.isEmpty
                  ? const Center(
                      child: Text(
                        "No bus schedules available.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return BusCard(
                          busNo: schedule.busNumber,
                          route: schedule.route,
                          departure: schedule.departureTime,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusCard extends StatelessWidget {
  final String busNo;
  final String route;
  final String departure;

  const BusCard({
    super.key,
    required this.busNo,
    required this.route,
    required this.departure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.directions_bus, color: Colors.white),
        ),
        title: Text(busNo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(route), Text("Departure: $departure")],
        ),
      ),
    );
  }
}
