import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
public struct AdsConfiguration {
    var appOpenAdEnabled: Bool
    var bannerAdEnabled: Bool
    var interstitialAdEnabled: Bool
    var nativeAdEnabled: Bool
    var nativeAdPreloadEnabled: Bool

    var appOpenAdUnitId: String
    var bannerAdUnitId: String
    var interstitialAdUnitId: String
    var nativeAdUnitId: String

    var interstitialAdShowCount: Int = 4

    var bannerAdErrorCount: Int = 3
    var interstitialAdErrorCount: Int = 3
    var nativeAdErrorCount: Int = 3
}

@MainActor
public final class AdsManager: NSObject {
    
    public static let shared = AdsManager()
    
    func setupAds(with config: AdsConfiguration) {
        AdsConfig.appOpenAdEnabled = config.appOpenAdEnabled
        AdsConfig.bannerAdEnabled = config.bannerAdEnabled
        AdsConfig.interstitialAdEnabled = config.interstitialAdEnabled
        AdsConfig.nativeAdEnabled = config.nativeAdEnabled
        AdsConfig.nativeAdPreloadEnabled = config.nativeAdPreloadEnabled

        AdsConfig.appOpenAdUnitId = config.appOpenAdUnitId
        AdsConfig.bannerAdUnitId = config.bannerAdUnitId
        AdsConfig.interstitialAdUnitId = config.interstitialAdUnitId
        AdsConfig.nativeAdUnitId = config.nativeAdUnitId

        AdsConfig.interstitialAdShowCount = config.interstitialAdShowCount

        AdsConfig.bannerAdErrorCount = config.bannerAdErrorCount
        AdsConfig.interstitialAdErrorCount = config.interstitialAdErrorCount
        AdsConfig.nativeAdErrorCount = config.nativeAdErrorCount
    }
    
    
    public func requestAppTrackingPermission(completion: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { _ in
            completion()
        }
    }
    
    public func resetErrorCounters() {
        BannerAdManager.shared.resetErrorCounter()
        InterstitialAdManager.shared.resetErrorCounter()
        NativeAdManager.shared.resetErrorCounter()
    }
 
    // MARK: - App Open Ad
    public func presentAppOpenAdIfAvailable() {
        AppOpenAdManager.shared.tryToPresentAd()
    }
    
    // MARK: - Interstitial Ad
    public func loadInterstitial() {
        InterstitialAdManager.shared.loadAd()
    }
    
    public func showInterstitial(from viewController: UIViewController,
                                 completion: @escaping () -> Void) {
        InterstitialAdManager.shared.showAd(from: viewController, completion: completion)
    }

    // MARK: - Banner Ad
    public func loadBanner(in containerView: UIView,
                           rootViewController: UIViewController,
                           completion: @escaping (Bool) -> Void) {
        BannerAdManager.shared.loadBannerAd(in: containerView, vc: rootViewController, completion: completion)
    }

    // MARK: - Native Ad
    public func loadNative(in containerView: UIView,
                           completion: @escaping (Bool) -> Void) {
        NativeAdManager.shared.getAd(in: containerView, completion: completion)
    }
    
}
