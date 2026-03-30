import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static final PremiumService instance = PremiumService._init();

  PremiumService._init();

  final InAppPurchase _iap = InAppPurchase.instance;

  // Product IDs - these must match what you set up in Google Play Console
  static const String monthlySubscriptionId = 'journal_plus_monthly';
  static const String annualSubscriptionId = 'journal_plus_annual';

  static const String _premiumKey = 'is_premium';
  static const String _subscriptionTypeKey = 'subscription_type';

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  // Initialize IAP
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();

    if (_isAvailable) {
      // Listen to purchase updates
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => print('Purchase stream error: $error'),
      );

      // Load products
      await _loadProducts();

      // Restore purchases (check if user already has a subscription)
      await restorePurchases();
    }
  }

  Future<void> _loadProducts() async {
    final Set<String> ids = {monthlySubscriptionId, annualSubscriptionId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  // Get available products for purchase
  List<ProductDetails> getProducts() {
    return _products;
  }

  ProductDetails? getMonthlyProduct() {
    try {
      return _products.firstWhere((p) => p.id == monthlySubscriptionId);
    } catch (e) {
      return null;
    }
  }

  ProductDetails? getAnnualProduct() {
    try {
      return _products.firstWhere((p) => p.id == annualSubscriptionId);
    } catch (e) {
      return null;
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error
          print('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase and unlock premium
          await _verifyAndUnlockPremium(purchaseDetails);
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _verifyAndUnlockPremium(PurchaseDetails purchaseDetails) async {
    // In production, you should verify the purchase with your backend server
    // For now, we'll trust the purchase status

    await setPremiumStatus(true);

    // Store subscription type
    final prefs = await SharedPreferences.getInstance();
    if (purchaseDetails.productID == monthlySubscriptionId) {
      await prefs.setString(_subscriptionTypeKey, 'monthly');
    } else if (purchaseDetails.productID == annualSubscriptionId) {
      await prefs.setString(_subscriptionTypeKey, 'annual');
    }
  }

  // Restore purchases (for users who already purchased)
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  // Check premium status
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
  }

  Future<String?> getSubscriptionType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subscriptionTypeKey);
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

  // Dispose
  void dispose() {
    _subscription?.cancel();
  }
}
