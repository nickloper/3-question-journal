import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _accomplishedController = TextEditingController();
  final _gratefulController = TextEditingController();
  final _winTomorrowController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  JournalEntry? _todayEntry;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
  }

  @override
  void dispose() {
    _accomplishedController.dispose();
    _gratefulController.dispose();
    _winTomorrowController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayEntry() async {
    setState(() => _isLoading = true);

    final today = DateTime.now();
    final entry = await DatabaseService.instance.getEntryByDate(today);
    final streak = await DatabaseService.instance.getCurrentStreak();

    setState(() {
      _todayEntry = entry;
      _currentStreak = streak;

      if (entry != null) {
        _accomplishedController.text = entry.accomplished;
        _gratefulController.text = entry.grateful;
        _winTomorrowController.text = entry.winTomorrow;
      }

      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    // Validate that at least one field has content
    if (_accomplishedController.text.trim().isEmpty &&
        _gratefulController.text.trim().isEmpty &&
        _winTomorrowController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer at least one question'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final entry = JournalEntry(
      date: DateTime(now.year, now.month, now.day),
      accomplished: _accomplishedController.text.trim(),
      grateful: _gratefulController.text.trim(),
      winTomorrow: _winTomorrowController.text.trim(),
      createdAt: _todayEntry?.createdAt ?? now,
      updatedAt: _todayEntry != null ? now : null,
    );

    await DatabaseService.instance.saveEntry(entry);

    setState(() => _isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _todayEntry == null ? 'Entry saved! ✨' : 'Entry updated! ✨',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Reload to update streak
    await _loadTodayEntry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3 Question Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
              // Reload in case entry was modified from history
              _loadTodayEntry();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and streak display
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Question 1
                  _buildQuestionCard(
                    number: '1',
                    question: 'What did I get done today?',
                    controller: _accomplishedController,
                    hint: 'Reflect on your accomplishments...',
                  ),
                  const SizedBox(height: 16),

                  // Question 2
                  _buildQuestionCard(
                    number: '2',
                    question: 'What am I grateful for?',
                    controller: _gratefulController,
                    hint: 'Express your gratitude...',
                  ),
                  const SizedBox(height: 16),

                  // Question 3
                  _buildQuestionCard(
                    number: '3',
                    question: 'How will I win tomorrow?',
                    controller: _winTomorrowController,
                    hint: 'Set your intention...',
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveEntry,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_todayEntry == null ? 'Save Entry' : 'Update Entry'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, y').format(today);

    return Card(
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
                const Icon(Icons.local_fire_department, color: Color(0xFFFF6B6B)),
                const SizedBox(width: 8),
                Text(
                  '$_currentStreak day streak',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF6B6B),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required String number,
    required String question,
    required TextEditingController controller,
    required String hint,
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
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
