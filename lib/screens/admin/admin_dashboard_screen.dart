import 'package:flutter/material.dart';
import 'package:lu_serve/services/notes_service.dart';
import 'package:lu_serve/services/bus_schedule_service.dart';
import 'package:lu_serve/services/calendar_service.dart';
import 'package:lu_serve/services/notice_service.dart';
import 'package:lu_serve/services/users_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _usersService = UsersService();
  final _notesService = NotesService();
  final _busService = BusScheduleService();
  final _calendarService = CalendarService();
  final _noticeService = NoticeService();

  int _usersCount = 0;
  int _notesCount = 0;
  int _schedulesCount = 0;
  int _eventsCount = 0;
  int _noticesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _usersService.getUsersCount(),
        _notesService.getNotesCount(),
        _busService.getSchedulesCount(),
        _calendarService.getEventsCount(),
        _noticeService.getNoticesCount(),
      ]);
      if (mounted) {
        setState(() {
          _usersCount = results[0];
          _notesCount = results[1];
          _schedulesCount = results[2];
          _eventsCount = results[3];
          _noticesCount = results[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ActionButton(
                title: "Manage Notes",
                icon: Icons.note_alt,
                onTap: () {
                  Navigator.pushNamed(context, '/manageNotes');
                },
              ),
              ActionButton(
                title: "Manage Bus Schedule",
                icon: Icons.directions_bus,
                onTap: () {
                  Navigator.pushNamed(context, '/manageBus');
                },
              ),
              ActionButton(
                title: "Manage Academic Calendar",
                icon: Icons.calendar_month,
                onTap: () {
                  Navigator.pushNamed(context, '/manageCalendar');
                },
              ),
              ActionButton(
                title: "Manage Notices",
                icon: Icons.campaign,
                onTap: () {
                  Navigator.pushNamed(context, '/manageNotices');
                },
              ),
              ActionButton(
                title: "Manage Users",
                icon: Icons.people,
                onTap: () {
                  Navigator.pushNamed(context, '/manageUsers');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(title),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
