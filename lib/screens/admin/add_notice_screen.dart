import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lu_serve/models/notice.dart';
import 'package:lu_serve/services/notice_service.dart';
import 'package:lu_serve/services/supabase_service.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _noticeService = NoticeService();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  Notice? _editingNotice;
  String _selectedCategory = 'general';
  PlatformFile? _selectedImage;
  String? _existingImageUrl;

  final List<Map<String, dynamic>> _categoryOptions = [
    {'name': 'general', 'icon': Icons.campaign, 'label': 'General'},
    {'name': 'academic', 'icon': Icons.school, 'label': 'Academic'},
    {'name': 'exam', 'icon': Icons.assignment, 'label': 'Exam'},
    {'name': 'holiday', 'icon': Icons.celebration, 'label': 'Holiday'},
    {'name': 'event', 'icon': Icons.event, 'label': 'Event'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Notice && _editingNotice == null) {
      _editingNotice = args;
      _titleController.text = args.title;
      _contentController.text = args.content;
      _selectedCategory = args.category;
      _existingImageUrl = args.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedImage = result.files.first);
    }
  }

  Future<Uint8List> _readFileAsBytes(String path) async {
    final file = io.File(path);
    return await file.readAsBytes();
  }

  Future<void> _saveNotice() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
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
      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
      };

      // Upload new image if selected
      if (_selectedImage != null) {
        final fileBytes = _selectedImage!.bytes;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${_selectedImage!.name}';
        final filePath = 'notices/$fileName';

        if (fileBytes != null) {
          await supabase.storage
              .from('notices')
              .uploadBinary(filePath, fileBytes);
        } else if (_selectedImage!.path != null) {
          final bytes = await _readFileAsBytes(_selectedImage!.path!);
          await supabase.storage.from('notices').uploadBinary(filePath, bytes);
        } else {
          throw Exception('Could not read image file');
        }

        data['image_url'] = supabase.storage
            .from('notices')
            .getPublicUrl(filePath);
      } else if (_editingNotice != null && _existingImageUrl != null) {
        // Keep existing image on edit if no new image selected
        data['image_url'] = _existingImageUrl;
      }

      if (_editingNotice != null) {
        await _noticeService.updateNotice(_editingNotice!.id, data);
      } else {
        final user = supabase.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        data['created_by'] = user.id;
        await _noticeService.createNotice(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingNotice != null
                  ? 'Notice updated successfully!'
                  : 'Notice added successfully!',
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
    final isEditing = _editingNotice != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Notice" : "Add Notice"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Notice Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Notice Content",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categoryOptions.map((opt) {
                final isSelected = _selectedCategory == opt['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = opt['name']),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                            fontSize: 11,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Image (optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedImage != null || _existingImageUrl != null
                        ? Colors.blue
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: _selectedImage != null || _existingImageUrl != null
                      ? Colors.blue.withValues(alpha: 0.05)
                      : null,
                ),
                child: _selectedImage != null
                    ? _selectedImage!.bytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.memory(
                                _selectedImage!.bytes!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : _buildImagePlaceholder(_selectedImage!.name)
                    : _existingImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _buildImagePickerPrompt(),
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      )
                    : _buildImagePickerPrompt(),
              ),
            ),
            if (_selectedImage != null || _existingImageUrl != null)
              TextButton.icon(
                onPressed: () => setState(() {
                  _selectedImage = null;
                  _existingImageUrl = null;
                }),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  "Remove image",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveNotice,
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
                        isEditing ? "Update Notice" : "Add Notice",
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
        const SizedBox(height: 10),
        Text(
          "Tap to add an image",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String name) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image, size: 50, color: Colors.blue),
        const SizedBox(height: 10),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.blue),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
