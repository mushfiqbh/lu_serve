import 'package:flutter/material.dart';
import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/auth_provider.dart';
import 'package:lu_serve/screens/profile/profile_screen.dart';
import 'package:lu_serve/screens/admin/admin_dashboard_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.blue),
                title: const Text("Mid Term Exam Schedule Published"),
                subtitle: const Text("Check the latest exam routine."),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.note, color: Colors.green),
                title: const Text("New Notes Uploaded"),
                subtitle: const Text("Database Management System"),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.purple),
                title: const Text("Important Notice Published"),
                subtitle: const Text(
                  "Check the latest notices and announcements.",
                ),
                onTap: () => Navigator.pushNamed(context, '/notices'),
              ),
            ),
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
