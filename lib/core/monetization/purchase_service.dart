import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// Service for handling in-app purchases
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isInitialized = false;
  bool _isAvailable = false;

  // Product IDs
  static const String premiumProductId = AppConstants.premiumProductId;

  // Purchase status callback
  Function(bool isPremium)? onPurchaseUpdate;

  /// Initialize purchase service
  Future<void> initialize() async {
    if (_isInitialized || !AppConstants.enableIAP) return;

    try {
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        _isInitialized = false;
        return;
      }

      // Listen to purchase updates
      _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onError: (error) {
          // Handle purchase stream errors
        },
      );

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      throw MonetizationException.notInitialized();
    }
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify and deliver purchase
        _verifyPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error
        onPurchaseUpdate?.call(false);
      } else if (purchase.status == PurchaseStatus.restored) {
        // Handle restored purchase
        _verifyPurchase(purchase);
      }

      // Complete purchase
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// Verify purchase (implement server-side verification in production)
  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // TODO: Implement server-side verification in production
    // For now, just check product ID
    if (purchase.productID == premiumProductId) {
      onPurchaseUpdate?.call(true);
    }
  }

  /// Get available products
  Future<List<ProductDetails>> getProducts() async {
    if (!_isInitialized) await initialize();
    if (!_isAvailable) return [];

    try {
      final Set<String> productIds = {premiumProductId};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        throw MonetizationException.purchaseError(
          response.error!.message,
        );
      }

      return response.productDetails;
    } catch (e) {
      throw MonetizationException.purchaseError(e.toString());
    }
  }

  /// Purchase premium
  Future<bool> purchasePremium() async {
    if (!_isInitialized) await initialize();
    if (!_isAvailable) {
      throw MonetizationException.notInitialized();
    }

    try {
      // Get product details
      final products = await getProducts();
      final premiumProduct = products.firstWhere(
        (p) => p.id == premiumProductId,
        orElse: () => throw MonetizationException.productNotAvailable(),
      );

      // Create purchase param
      final PurchaseParam param = PurchaseParam(
        productDetails: premiumProduct,
      );

      // Buy non-consumable product (one-time purchase)
      final result = await _iap.buyNonConsumable(purchaseParam: param);
      return result;
    } catch (e) {
      throw MonetizationException.purchaseError(e.toString());
    }
  }

  /// Restore purchases (iOS)
  Future<void> restorePurchases() async {
    if (!_isInitialized) await initialize();
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      throw MonetizationException.purchaseError(e.toString());
    }
  }

  /// Check if user has active premium
  Future<bool> hasPremium() async {
    if (!_isInitialized) await initialize();
    if (!_isAvailable) return false;

    try {
      // Restore past purchases
      await _iap.restorePurchases();

      // For now, return false as premium status should be tracked
      // via purchase stream updates
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get product price as string
  Future<String> getPremiumPrice() async {
    try {
      final products = await _getProducts();
      final premiumProduct = products.firstWhere(
        (p) => p.id == premiumProductId,
        orElse: () => throw MonetizationException.productNotAvailable(),
      );

      return premiumProduct.price;
    } catch (e) {
      return '₹${AppConstants.premiumPriceMin}'; // Fallback price
    }
  }

  /// Get available products
  Future<List<ProductDetails>> _getProducts() async {
    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.error != null) {
      throw MonetizationException.purchaseError(response.error!.message);
    }
    return response.productDetails;
  }

  /// Check if purchases are available
  bool get isAvailable => _isAvailable;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose service
  void dispose() {
    // Purchase stream is automatically disposed by the plugin
  }
}
