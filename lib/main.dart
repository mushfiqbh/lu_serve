import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lu_serve/screens/auth/login_screen.dart';
import 'package:lu_serve/services/auth_provider.dart';
import 'package:lu_serve/services/auth_service.dart';
import 'screens/admin/add_bus_schedule_screen.dart';
import 'screens/admin/add_calendar_event_screen.dart';
import 'screens/admin/add_notice_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_bus_schedule_screens.dart';
import 'screens/admin/manage_calendar_screen.dart';
import 'screens/admin/manage_notes_screen.dart';
import 'screens/admin/manage_notices_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/notices/notices_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/bus/bus_schedule_screen.dart';
import 'screens/calendar/academic_calendar_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/notes/upload_notes_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ozmslotaavqciggqksov.supabase.co',
    anonKey: 'sb_publishable_Oxh3CaL1nX3Xiti5OyrmxA_PyWUy2Cb',
  );

  // Create and initialize the shared AuthService
  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      authService: authService,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LU Serve',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/notes': (context) => const NotesScreen(),
          '/uploadNotes': (context) => const UploadNotesScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/busSchedule': (context) => const BusScheduleScreen(),
          '/calendar': (context) => const AcademicCalendarScreen(),
          '/adminDashboard': (context) => const AdminDashboardScreen(),
          '/manageNotes': (context) => const ManageNotesScreen(),
          '/manageBus': (context) => const ManageBusScheduleScreen(),
          '/addBusSchedule': (context) => const AddBusScheduleScreen(),
          '/manageCalendar': (context) => const ManageCalendarScreen(),
          '/addCalendarEvent': (context) => const AddCalendarEventScreen(),
          '/manageUsers': (context) => const ManageUsersScreen(),
          '/notices': (context) => const NoticesScreen(),
          '/manageNotices': (context) => const ManageNoticesScreen(),
          '/addNotice': (context) => const AddNoticeScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
