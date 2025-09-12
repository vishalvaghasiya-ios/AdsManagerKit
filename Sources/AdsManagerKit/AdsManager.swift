import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
public struct AdsConfiguration {
    public var isProduction: Bool
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
        isProduction: Bool,
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
        self.isProduction = isProduction
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
        AdsConfig.isProduction = config.isProduction
        AdsConfig.appOpenAdEnabled = config.appOpenAdEnabled
        AdsConfig.bannerAdEnabled = config.bannerAdEnabled
        AdsConfig.interstitialAdEnabled = config.interstitialAdEnabled
        AdsConfig.nativeAdEnabled = config.nativeAdEnabled
        AdsConfig.nativeAdPreloadEnabled = config.nativeAdPreloadEnabled

        if AdsConfig.isProduction {
            AdsConfig.appOpenAdUnitId = config.appOpenAdUnitId
            AdsConfig.bannerAdUnitId = config.bannerAdUnitId
            AdsConfig.interstitialAdUnitId = config.interstitialAdUnitId
            AdsConfig.nativeAdUnitId = config.nativeAdUnitId
        } else {
            AdsConfig.appOpenAdUnitId = "ca-app-pub-3940256099942544/5575463023"
            AdsConfig.bannerAdUnitId = "ca-app-pub-3940256099942544/2934735716"
            AdsConfig.interstitialAdUnitId = "ca-app-pub-3940256099942544/4411468910"
            AdsConfig.nativeAdUnitId = "ca-app-pub-3940256099942544/3986624511"
        }

        AdsConfig.interstitialAdShowCount = config.interstitialAdShowCount

        AdsConfig.bannerAdErrorCount = config.bannerAdErrorCount
        AdsConfig.interstitialAdErrorCount = config.interstitialAdErrorCount
        AdsConfig.nativeAdErrorCount = config.nativeAdErrorCount
        
        self.loadOpenAd()
        self.loadInterstitial()
        self.preloadNativeAds()
    }
    
    public func requestAppTrackingPermission(completion: @escaping () -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    public func resetErrorCounters() {
        BannerAdManager.shared.resetErrorCounter()
        InterstitialAdManager.shared.resetErrorCounter()
        NativeAdManager.shared.resetErrorCounter()
    }
 
    // MARK: - App Open Ad
    public func loadOpenAd() {
        AppOpenAdManager.shared.loadOpenAd()
    }
    
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
    public func preloadNativeAds() {
        NativeAdManager.shared.preloadNativeAds()
    }
    
    public func loadNative(in containerView: UIView,
                           adType: AdType = .SMALL,
                           completion: @escaping (Bool) -> Void) {
        NativeAdManager.shared.getAd(in: containerView, adType: adType, completion: completion)
    }
    
}
