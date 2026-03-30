import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';

class EntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late TextEditingController _accomplishedController;
  late TextEditingController _gratefulController;
  late TextEditingController _winTomorrowController;

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _accomplishedController = TextEditingController(text: widget.entry.accomplished);
    _gratefulController = TextEditingController(text: widget.entry.grateful);
    _winTomorrowController = TextEditingController(text: widget.entry.winTomorrow);
  }

  @override
  void dispose() {
    _accomplishedController.dispose();
    _gratefulController.dispose();
    _winTomorrowController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final updatedEntry = widget.entry.copyWith(
      accomplished: _accomplishedController.text.trim(),
      grateful: _gratefulController.text.trim(),
      winTomorrow: _winTomorrowController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await DatabaseService.instance.saveEntry(updatedEntry);

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry updated! ✨'),
        backgroundColor: Colors.green,
      ),
    );

    // Return to previous screen
    Navigator.pop(context);
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _accomplishedController.text = widget.entry.accomplished;
      _gratefulController.text = widget.entry.grateful;
      _winTomorrowController.text = widget.entry.winTomorrow;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d, y').format(widget.entry.date);
    final canEdit = widget.entry.canEdit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        actions: [
          if (canEdit && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
              onPressed: _cancelEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Created ${DateFormat('h:mm a').format(widget.entry.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (widget.entry.updatedAt != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${DateFormat('h:mm a').format(widget.entry.updatedAt!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                    if (!canEdit) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'This entry is locked',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Questions
            _buildQuestionSection(
              number: '1',
              question: 'What did I get done today?',
              controller: _accomplishedController,
            ),
            const SizedBox(height: 16),

            _buildQuestionSection(
              number: '2',
              question: 'What am I grateful for?',
              controller: _gratefulController,
            ),
            const SizedBox(height: 16),

            _buildQuestionSection(
              number: '3',
              question: 'How will I win tomorrow?',
              controller: _winTomorrowController,
            ),

            // Save button when editing
            if (_isEditing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionSection({
    required String number,
    required String question,
    required TextEditingController controller,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Your answer...',
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.text.isEmpty
                      ? 'No answer provided'
                      : controller.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: controller.text.isEmpty
                            ? Colors.grey[400]
                            : null,
                        fontStyle: controller.text.isEmpty
                            ? FontStyle.italic
                            : null,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
