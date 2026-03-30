import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static final PremiumService instance = PremiumService._init();

  PremiumService._init();

  // For now, premium status is stored locally
  // Later, this will connect to in-app purchases
  static const String _premiumKey = 'is_premium';

  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
  }

  // Premium features
  Future<bool> canAccessUnlimitedHistory() async {
    return await isPremium();
  }

  Future<bool> canAccessCloudSync() async {
    return await isPremium();
  }

  Future<bool> canAccessAnalytics() async {
    return await isPremium();
  }

  Future<bool> canExportEntries() async {
    return await isPremium();
  }

  Future<bool> canAccessCustomThemes() async {
    return await isPremium();
  }

  Future<bool> canAddMultiplePhotos() async {
    return await isPremium();
  }

  // Helper to get days of history access
  Future<int> getHistoryDaysLimit() async {
    final premium = await isPremium();
    return premium ? 999999 : 30; // 30 days for free, unlimited for premium
  }
}
