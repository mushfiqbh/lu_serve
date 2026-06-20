import 'package:flutter/material.dart';
import 'package:lu_serve/models/profile.dart';
import 'package:lu_serve/services/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();

  Profile? get _profile => AuthProvider.read(context).currentProfile;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  void _syncControllers() {
    final p = _profile;
    _fullNameController.text = p?.fullName ?? '';
    _studentIdController.text = p?.studentId ?? '';
    _departmentController.text = p?.department ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Cancelling – revert to original values
      _syncControllers();
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = AuthProvider.read(context);
      await authService.updateProfile({
        'full_name': _fullNameController.text.trim(),
        if (_studentIdController.text.trim().isNotEmpty)
          'student_id': _studentIdController.text.trim(),
        if (_departmentController.text.trim().isNotEmpty)
          'department': _departmentController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _logout() async {
    final authService = AuthProvider.read(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await authService.signOut();

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Account" : "Account"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: _isSaving ? null : _toggleEdit,
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ] else
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit),
              tooltip: "Edit Profile",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar section
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 15),

              // Name – always visible
              if (_isEditing)
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                  decoration: _inputDecoration("Full Name", Icons.person),
                )
              else
                Text(
                  profile?.fullName ?? "User",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              // Email – read-only
              if (!_isEditing) ...[
                Text(
                  profile?.email ?? "No email",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],

              const SizedBox(height: 30),

              // Student ID
              if (_isEditing) ...[
                TextFormField(
                  controller: _studentIdController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration("Student ID", Icons.badge),
                ),
                const SizedBox(height: 15),
                // Department
                TextFormField(
                  controller: _departmentController,
                  textInputAction: TextInputAction.done,
                  decoration: _inputDecoration("Department", Icons.school),
                ),
              ] else ...[
                _infoCard(
                  Icons.badge,
                  "Student ID",
                  profile?.studentId ?? "Not set",
                ),
                const SizedBox(height: 10),
                _infoCard(
                  Icons.school,
                  "Department",
                  profile?.department ?? "Not set",
                ),
                const SizedBox(height: 10),
                _infoCard(Icons.person, "Role", profile?.role ?? "student"),
              ],

              const SizedBox(height: 30),

              // Edit button (only in view mode)
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _toggleEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profile"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 15),

              // Logout button (only in view mode)
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
