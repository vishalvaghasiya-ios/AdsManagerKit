import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
public struct AdsConfiguration {
    public var appOpenAdEnabled: Bool
    public var bannerAdEnabled: Bool
    public var interstitialAdEnabled: Bool
    public var nativeAdEnabled: Bool
    public var nativeAdPreloadEnabled: Bool

    public var appOpenAdUnitId: String
    public var bannerAdUnitId: String
    public var interstitialAdUnitId: String
    public var nativeAdUnitId: String

    public var interstitialAdShowCount: Int = 4

    public var bannerAdErrorCount: Int = 3
    public var interstitialAdErrorCount: Int = 3
    public var nativeAdErrorCount: Int = 3

    public init(
        appOpenAdEnabled: Bool,
        bannerAdEnabled: Bool,
        interstitialAdEnabled: Bool,
        nativeAdEnabled: Bool,
        nativeAdPreloadEnabled: Bool,
        appOpenAdUnitId: String,
        bannerAdUnitId: String,
        interstitialAdUnitId: String,
        nativeAdUnitId: String,
        interstitialAdShowCount: Int = 4,
        bannerAdErrorCount: Int = 3,
        interstitialAdErrorCount: Int = 3,
        nativeAdErrorCount: Int = 3
    ) {
        self.appOpenAdEnabled = appOpenAdEnabled
        self.bannerAdEnabled = bannerAdEnabled
        self.interstitialAdEnabled = interstitialAdEnabled
        self.nativeAdEnabled = nativeAdEnabled
        self.nativeAdPreloadEnabled = nativeAdPreloadEnabled
        self.appOpenAdUnitId = appOpenAdUnitId
        self.bannerAdUnitId = bannerAdUnitId
        self.interstitialAdUnitId = interstitialAdUnitId
        self.nativeAdUnitId = nativeAdUnitId
        self.interstitialAdShowCount = interstitialAdShowCount
        self.bannerAdErrorCount = bannerAdErrorCount
        self.interstitialAdErrorCount = interstitialAdErrorCount
        self.nativeAdErrorCount = nativeAdErrorCount
    }
}

@MainActor
public final class AdsManager: NSObject {
    
    public static let shared = AdsManager()
    
    public func setupAds(with config: AdsConfiguration) {
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
                           adType: AdType = .SMALL,
                           completion: @escaping (Bool) -> Void) {
        NativeAdManager.shared.getAd(in: containerView, adType: adType, completion: completion)
    }
    
}
