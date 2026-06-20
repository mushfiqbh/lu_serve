import 'package:flutter/material.dart';
import 'package:lu_serve/services/bus_schedule_service.dart';

class AddBusScheduleScreen extends StatefulWidget {
  const AddBusScheduleScreen({super.key});

  @override
  State<AddBusScheduleScreen> createState() => _AddBusScheduleScreenState();
}

class _AddBusScheduleScreenState extends State<AddBusScheduleScreen> {
  final _busService = BusScheduleService();
  final _busController = TextEditingController();
  final _routeController = TextEditingController();
  final _timeController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _busController.dispose();
    _routeController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _saveSchedule() async {
    if (_busController.text.trim().isEmpty ||
        _routeController.text.trim().isEmpty ||
        _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _busService.createSchedule({
        'bus_number': _busController.text.trim(),
        'route': _routeController.text.trim(),
        'departure_time': _timeController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bus Schedule"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _busController,
              decoration: InputDecoration(
                labelText: "Bus Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _routeController,
              decoration: InputDecoration(
                labelText: "Route",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: "Departure Time",
                hintText: 'e.g. 08:00 AM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Schedule",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
