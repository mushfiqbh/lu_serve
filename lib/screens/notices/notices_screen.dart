import 'package:flutter/material.dart';
import 'package:lu_serve/models/notice.dart';
import 'package:lu_serve/services/notice_service.dart';

/// A page-level dialog that shows the full notice with optional image.
class _NoticeDetailDialog extends StatefulWidget {
  final Notice notice;
  const _NoticeDetailDialog({required this.notice});

  @override
  State<_NoticeDetailDialog> createState() => _NoticeDetailDialogState();
}

class _NoticeDetailDialogState extends State<_NoticeDetailDialog> {
  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: getCategoryColor(notice.category),
                  radius: 18,
                  child: Icon(
                    getCategoryIcon(notice.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: getCategoryColor(
                            notice.category,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          notice.categoryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: getCategoryColor(notice.category),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (notice.createdAt != null)
                        Text(
                          formatDate(notice.createdAt!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  if (notice.imageUrl != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () => _showFullImage(notice.imageUrl!),
                        child: Image.network(
                          notice.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : const AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    notice.content,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final _noticeService = NoticeService();
  final _searchController = TextEditingController();

  List<Notice> _notices = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);
    try {
      final notices = await _noticeService.getAllNotices();
      if (mounted) setState(() => _notices = notices);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load notices: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _searchNotices(String query) async {
    setState(() => _isLoading = true);
    try {
      final notices = query.isEmpty
          ? await _noticeService.getAllNotices()
          : await _noticeService.searchNotices(query);
      if (mounted) setState(() => _notices = notices);
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

  List<Notice> get _filteredNotices {
    if (_selectedCategory == 'all') return _notices;
    return _notices.where((n) => n.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'all',
      'academic',
      'exam',
      'holiday',
      'event',
      'general',
    ];
    final categoryLabels = {
      'all': 'All',
      'academic': 'Academic',
      'exam': 'Exam',
      'holiday': 'Holiday',
      'event': 'Event',
      'general': 'General',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Notices...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: _searchNotices,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(categoryLabels[cat]!),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredNotices.isEmpty
                  ? const Center(
                      child: Text(
                        "No notices available yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredNotices.length,
                      itemBuilder: (context, index) {
                        final notice = _filteredNotices[index];
                        return _buildNoticeCard(notice);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeCard(Notice notice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: notice.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  notice.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: getCategoryColor(notice.category),
                    child: Icon(
                      getCategoryIcon(notice.category),
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : CircleAvatar(
                backgroundColor: getCategoryColor(notice.category),
                child: Icon(
                  getCategoryIcon(notice.category),
                  color: Colors.white,
                ),
              ),
        title: Text(
          notice.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notice.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: getCategoryColor(
                      notice.category,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    notice.categoryLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: getCategoryColor(notice.category),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                if (notice.createdAt != null)
                  Text(
                    formatDate(notice.createdAt!),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _showNoticeDetail(notice),
      ),
    );
  }

  void _showNoticeDetail(Notice notice) {
    showDialog(
      context: context,
      builder: (_) => _NoticeDetailDialog(notice: notice),
    );
  }
}

// ---------------------------------------------------------------------------
// Top-level helpers used by both _NoticesScreenState and _NoticeDetailDialog
// ---------------------------------------------------------------------------

Color getCategoryColor(String category) {
  switch (category) {
    case 'academic':
      return Colors.purple;
    case 'exam':
      return Colors.red;
    case 'holiday':
      return Colors.green;
    case 'event':
      return Colors.orange;
    case 'general':
    default:
      return Colors.blue;
  }
}

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'academic':
      return Icons.school;
    case 'exam':
      return Icons.assignment;
    case 'holiday':
      return Icons.celebration;
    case 'event':
      return Icons.event;
    case 'general':
    default:
      return Icons.campaign;
  }
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
