import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

/// Service for managing AdMob advertisements
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  /// Initialize Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized || !AppConstants.enableAds) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  /// Get banner ad unit ID based on platform
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.adMobBannerIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.adMobBannerIdIos;
    }
    return '';
  }

  /// Load banner ad
  Future<BannerAd?> loadBannerAd() async {
    if (!_isInitialized) await initialize();
    if (!AppConstants.enableAds) return null;

    // Dispose existing banner
    _bannerAd?.dispose();
    _isBannerLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
        },
        onAdOpened: (ad) {},
        onAdClosed: (ad) {},
      ),
    );

    await _bannerAd!.load();
    return _bannerAd;
  }

  /// Get current banner ad
  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;

  /// Check if banner is loaded
  bool get isBannerLoaded => _isBannerLoaded;

  /// Dispose banner ad
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  /// Dispose all ads
  void dispose() {
    disposeBanner();
  }

  /// Check if ads are enabled
  bool get areAdsEnabled => AppConstants.enableAds && _isInitialized;
}

/// Widget wrapper for banner ad
/// Usage in Flutter:
/// ```dart
/// if (adService.isBannerLoaded && adService.bannerAd != null)
///   Container(
///     height: 50,
///     child: AdWidget(ad: adService.bannerAd!),
///   )
/// ```
