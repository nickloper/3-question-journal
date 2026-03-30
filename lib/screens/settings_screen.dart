import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    final enabled = await NotificationService.instance.areNotificationsEnabled();
    final time = await NotificationService.instance.getNotificationTime();

    setState(() {
      _notificationsEnabled = enabled;
      _notificationTime = TimeOfDay(
        hour: time['hour']!,
        minute: time['minute']!,
      );
      _isLoading = false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);

    if (value) {
      await NotificationService.instance.scheduleDailyNotification(
        _notificationTime.hour,
        _notificationTime.minute,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily reminder set for ${_notificationTime.format(context)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await NotificationService.instance.disableNotifications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily reminders disabled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _notificationTime) {
      setState(() => _notificationTime = picked);

      // If notifications are enabled, reschedule with new time
      if (_notificationsEnabled) {
        await NotificationService.instance.scheduleDailyNotification(
          picked.hour,
          picked.minute,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder time updated to ${picked.format(context)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Notifications section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),

                        // Enable/disable notifications
                        SwitchListTile(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          title: const Text('Daily Reminders'),
                          subtitle: const Text(
                            'Get notified to complete your journal entry',
                          ),
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),

                        const SizedBox(height: 8),

                        // Time picker
                        ListTile(
                          enabled: _notificationsEnabled,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.access_time,
                            color: _notificationsEnabled
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          title: const Text('Reminder Time'),
                          subtitle: Text(_notificationTime.format(context)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _notificationsEnabled ? _selectTime : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // About section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Version'),
                          subtitle: const Text('1.0.0'),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '3 Question Journal helps you reflect on your day with three simple questions:\n\n'
                            '1. What did I get done today?\n'
                            '2. What am I grateful for?\n'
                            '3. How will I win tomorrow?\n\n'
                            'Build a consistent journaling habit and track your progress over time.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Data section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('Local Storage'),
                          subtitle: const Text(
                            'All your journal entries are stored locally on your device. No cloud sync or external servers.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
