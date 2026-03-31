import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../services/premium_service.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';

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
  bool _isPremium = false;

  // Photo lists for each question
  List<String> _accomplishedPhotos = [];
  List<String> _gratefulPhotos = [];
  List<String> _winTomorrowPhotos = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTodayEntry();
    _checkPremiumStatus();
  }

  @override
  void dispose() {
    _accomplishedController.dispose();
    _gratefulController.dispose();
    _winTomorrowController.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await PremiumService.instance.isPremium();
    setState(() {
      _isPremium = isPremium;
    });
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
        _accomplishedPhotos = List.from(entry.accomplishedPhotos);
        _gratefulPhotos = List.from(entry.gratefulPhotos);
        _winTomorrowPhotos = List.from(entry.winTomorrowPhotos);
      }

      _isLoading = false;
    });
  }

  Future<void> _pickPhoto(String questionType) async {
    // Check photo limits
    List<String> currentPhotos;
    switch (questionType) {
      case 'accomplished':
        currentPhotos = _accomplishedPhotos;
        break;
      case 'grateful':
        currentPhotos = _gratefulPhotos;
        break;
      case 'winTomorrow':
        currentPhotos = _winTomorrowPhotos;
        break;
      default:
        return;
    }

    // Free users limited to 1 photo per question
    if (!_isPremium && currentPhotos.length >= 1) {
      _showUpgradeDialog();
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Copy photo to app directory
        final String savedPath = await _savePhoto(image);

        setState(() {
          switch (questionType) {
            case 'accomplished':
              _accomplishedPhotos.add(savedPath);
              break;
            case 'grateful':
              _gratefulPhotos.add(savedPath);
              break;
            case 'winTomorrow':
              _winTomorrowPhotos.add(savedPath);
              break;
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> _savePhoto(XFile image) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String photoDir = path.join(appDir.path, 'photos');
    await Directory(photoDir).create(recursive: true);

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
    final String newPath = path.join(photoDir, fileName);

    await File(image.path).copy(newPath);
    return newPath;
  }

  void _removePhoto(String questionType, int index) {
    setState(() {
      switch (questionType) {
        case 'accomplished':
          _accomplishedPhotos.removeAt(index);
          break;
        case 'grateful':
          _gratefulPhotos.removeAt(index);
          break;
        case 'winTomorrow':
          _winTomorrowPhotos.removeAt(index);
          break;
      }
    });
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text(
          'Free users can add 1 photo per question. Upgrade to Premium for unlimited photos!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              ).then((_) => _checkPremiumStatus());
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
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
      accomplishedPhotos: _accomplishedPhotos,
      gratefulPhotos: _gratefulPhotos,
      winTomorrowPhotos: _winTomorrowPhotos,
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

    // Reload to update state
    await _loadTodayEntry();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('3 Question Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              ).then((_) => _loadTodayEntry());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and streak header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateStr,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Evening Reflection',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_currentStreak > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: Color(0xFFFF6B6B),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_currentStreak',
                                      style: const TextStyle(
                                        color: Color(0xFFFF6B6B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Question 1
                    _buildQuestionCard(
                      number: '1',
                      question: 'What did I get done today?',
                      controller: _accomplishedController,
                      hint: 'Reflect on your accomplishments...',
                      photos: _accomplishedPhotos,
                      questionType: 'accomplished',
                    ),

                    const SizedBox(height: 16),

                    // Question 2
                    _buildQuestionCard(
                      number: '2',
                      question: 'What am I grateful for?',
                      controller: _gratefulController,
                      hint: 'Express gratitude...',
                      photos: _gratefulPhotos,
                      questionType: 'grateful',
                    ),

                    const SizedBox(height: 16),

                    // Question 3
                    _buildQuestionCard(
                      number: '3',
                      question: 'How will I win tomorrow?',
                      controller: _winTomorrowController,
                      hint: 'Plan for success...',
                      photos: _winTomorrowPhotos,
                      questionType: 'winTomorrow',
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
                            : Text(
                                _todayEntry == null ? 'Save Entry' : 'Update Entry',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuestionCard({
    required String number,
    required String question,
    required TextEditingController controller,
    required String hint,
    required List<String> photos,
    required String questionType,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
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
                        fontSize: 16,
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
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Photo section
            if (photos.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...photos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photoPath = entry.value;
                    return _buildPhotoThumbnail(photoPath, questionType, index);
                  }),
                  _buildAddPhotoButton(questionType),
                ],
              )
            else
              _buildAddPhotoButton(questionType),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String photoPath, String questionType, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(photoPath),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => _removePhoto(questionType, index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(String questionType) {
    return GestureDetector(
      onTap: () => _pickPhoto(questionType),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              !_isPremium ? '1 free' : 'Add',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
