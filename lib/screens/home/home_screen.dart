import 'package:flutter/material.dart';
import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/auth_provider.dart';
import 'package:lu_serve/services/notes_service.dart';
import 'package:lu_serve/services/notice_service.dart';
import 'package:lu_serve/services/bus_schedule_service.dart';
import 'package:lu_serve/services/calendar_service.dart';
import 'package:lu_serve/screens/profile/profile_screen.dart';
import 'package:lu_serve/screens/admin/admin_dashboard_screen.dart';

/// Categories of recent updates surfaced on the home dashboard.
enum UpdateType { note, notice, bus, calendar }

/// Lightweight union describing a recent item shown in the home feed.
class RecentUpdate {
  final UpdateType type;
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final DateTime timestamp;

  RecentUpdate({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.timestamp,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _tabs = const [_HomeTab(), ProfileScreen()];
  }

  Future<void> _loadProfile() async {
    final authService = AuthProvider.read(context);
    authService.addListener(_onAuthChange);
    if (mounted) {
      setState(() {
        _isAdmin = authService.isAdmin;
      });
    }
  }

  void _onAuthChange() {
    if (mounted) {
      setState(() {
        _isAdmin = AuthProvider.read(context).isAdmin;
      });
    }
  }

  @override
  void dispose() {
    try {
      AuthProvider.read(context).removeListener(_onAuthChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _isAdmin ? [..._tabs, const AdminDashboardScreen()] : _tabs;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
          if (_isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: "Admin",
            ),
        ],
      ),
    );
  }
}

/// The home tab content with quick access cards and recent updates.
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Profile? _profile;
  bool _isLoadingUpdates = true;
  String? _updatesError;
  List<RecentUpdate> _recentUpdates = const [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadRecentUpdates();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = AuthProvider.read(context);
      if (mounted) {
        setState(() {
          _profile = authService.currentProfile;
        });
      }
    } catch (_) {}
  }

  /// Pulls the most recent items from notes, notices, bus schedules and
  /// calendar events, merges them, and renders the newest first.
  Future<void> _loadRecentUpdates() async {
    setState(() {
      _isLoadingUpdates = true;
      _updatesError = null;
    });

    try {
      final notes = await NotesService().getAllNotes();
      final notices = await NoticeService().getAllNotices();
      final buses = await BusScheduleService().getAllSchedules();
      final events = await CalendarService().getAllEvents();

      final updates = <RecentUpdate>[];

      for (final n in notes.take(2)) {
        updates.add(
          RecentUpdate(
            type: UpdateType.note,
            id: n.id,
            title: n.subject,
            subtitle: n.description?.isNotEmpty == true
                ? n.description!
                : '${n.courseCode} • New notes uploaded',
            icon: Icons.note,
            color: Colors.green,
            timestamp: n.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
      }

      for (final notice in notices.take(2)) {
        updates.add(
          RecentUpdate(
            type: UpdateType.notice,
            id: notice.id,
            title: notice.title,
            subtitle: notice.categoryLabel,
            icon: Icons.campaign,
            color: Colors.blue,
            timestamp:
                notice.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
      }

      for (final bus in buses.take(2)) {
        updates.add(
          RecentUpdate(
            type: UpdateType.bus,
            id: bus.id,
            title: 'Bus ${bus.busNumber}',
            subtitle: '${bus.route} • Departs ${bus.departureTime}',
            icon: Icons.directions_bus,
            color: Colors.orange,
            timestamp: bus.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
      }

      for (final event in events.take(2)) {
        final dateLabel =
            '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}';
        updates.add(
          RecentUpdate(
            type: UpdateType.calendar,
            id: event.id,
            title: event.title,
            subtitle: dateLabel,
            icon: Icons.calendar_month,
            color: Colors.purple,
            timestamp:
                event.createdAt ?? event.eventDate,
          ),
        );
      }

      updates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (!mounted) return;
      setState(() {
        _recentUpdates = updates.take(8).toList();
        _isLoadingUpdates = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _updatesError = 'Failed to load recent updates';
        _isLoadingUpdates = false;
      });
    }
  }

  /// Routes a tapped recent update to the corresponding destination.
  void _openUpdate(RecentUpdate update) {
    switch (update.type) {
      case UpdateType.note:
        Navigator.pushNamed(context, '/notes');
        break;
      case UpdateType.notice:
        Navigator.pushNamed(context, '/notices');
        break;
      case UpdateType.bus:
        Navigator.pushNamed(context, '/busSchedule');
        break;
      case UpdateType.calendar:
        Navigator.pushNamed(context, '/calendar');
        break;
    }
  }

  Widget _buildRecentUpdatesCard() {
    if (_isLoadingUpdates) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_updatesError != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: Text(_updatesError!),
          trailing: TextButton(
            onPressed: _loadRecentUpdates,
            child: const Text('Retry'),
          ),
        ),
      );
    }

    if (_recentUpdates.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.inbox_outlined, color: Colors.grey),
          title: Text('No recent updates yet'),
          subtitle: Text('New content will appear here.'),
        ),
      );
    }

    return Column(
      children: [
        for (final update in _recentUpdates)
          Card(
            child: ListTile(
              leading: Icon(update.icon, color: update.color),
              title: Text(update.title),
              subtitle: Text(update.subtitle),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => _openUpdate(update),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Text("LU Serve", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${_profile?.fullName ?? 'User'} 👋",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome back to LU Serve",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Quick Access",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildCard(
                  Icons.menu_book,
                  "Notes",
                  () => Navigator.pushNamed(context, '/notes'),
                ),
                _buildCard(
                  Icons.directions_bus,
                  "Bus Schedule",
                  () => Navigator.pushNamed(context, '/busSchedule'),
                ),
                _buildCard(
                  Icons.calendar_month,
                  "Academic Calendar",
                  () => Navigator.pushNamed(context, '/calendar'),
                ),
                _buildCard(
                  Icons.campaign,
                  "Notices",
                  () => Navigator.pushNamed(context, '/notices'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Recent Updates",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildRecentUpdatesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
