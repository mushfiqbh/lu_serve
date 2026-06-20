import 'package:flutter/material.dart';
import 'package:lu_serve/models/calendar_event.dart';
import 'package:lu_serve/services/calendar_service.dart';

class AddCalendarEventScreen extends StatefulWidget {
  const AddCalendarEventScreen({super.key});

  @override
  State<AddCalendarEventScreen> createState() => _AddCalendarEventScreenState();
}

class _AddCalendarEventScreenState extends State<AddCalendarEventScreen> {
  final _calendarService = CalendarService();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isSaving = false;

  CalendarEvent? _editingEvent;
  String _selectedIcon = 'event';

  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'event', 'icon': Icons.event, 'label': 'General'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Academic'},
    {'name': 'assignment', 'icon': Icons.assignment, 'label': 'Exam'},
    {'name': 'mic', 'icon': Icons.mic, 'label': 'Seminar'},
    {'name': 'celebration', 'icon': Icons.celebration, 'label': 'Holiday'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CalendarEvent && _editingEvent == null) {
      _editingEvent = args;
      _titleController.text = args.title;
      _dateController.text = _formatDateForInput(args.eventDate);
      _selectedIcon = args.icon;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _editingEvent?.eventDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _dateController.text = _formatDateForInput(picked);
    }
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _dateController.text.trim().isEmpty) {
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
      final data = {
        'title': _titleController.text.trim(),
        'event_date': _dateController.text.trim(),
        'icon': _selectedIcon,
      };

      if (_editingEvent != null) {
        await _calendarService.updateEvent(_editingEvent!.id, data);
      } else {
        await _calendarService.createEvent(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingEvent != null
                  ? 'Event updated successfully!'
                  : 'Event added successfully!',
            ),
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
    final isEditing = _editingEvent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Calendar Event" : "Add Calendar Event"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Event Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Event Date",
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            const Text(
              "Event Icon",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _iconOptions.map((opt) {
                final isSelected = _selectedIcon == opt['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = opt['name']),
                  child: Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          opt['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.black54,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEvent,
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
                    : Text(
                        isEditing ? "Update Event" : "Save Event",
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
