import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
import UserMessagingPlatform
@MainActor
public final class AdsManager: NSObject {
    
    /// Configure all ad settings at once
    /// - Parameters:
    ///   - isProduction: True for production AdMob IDs, false for test IDs
    ///   - appOpenAdEnabled: Enable App Open Ads
    ///   - bannerAdEnabled: Enable Banner Ads
    ///   - interstitialAdEnabled: Enable Interstitial Ads
    ///   - nativeAdEnabled: Enable Native Ads
    ///   - nativeAdPreloadEnabled: Preload native ads in advance
    ///   - appOpenAdUnitId: Optional App Open Ad Unit ID (default uses placeholder/test ID)
    ///   - bannerAdUnitId: Optional Banner Ad Unit ID (default uses placeholder/test ID)
    ///   - interstitialAdUnitId: Optional Interstitial Ad Unit ID
    ///   - nativeAdUnitId: Optional Native Ad Unit ID
    ///   - interstitialAdShowCount: Max times interstitial can show per session (default 4)
    ///   - maxInterstitialAdsPerSession: Max interstitials per session (default 50)
    ///   - bannerAdErrorCount: Max banner error count (default 7)
    ///   - interstitialAdErrorCount: Max interstitial error count (default 7)
    ///   - nativeAdErrorCount: Max native ad error count (default 7)
    public static func configureAds(
        isProduction: Bool,
        appOpenAdEnabled: Bool,
        bannerAdEnabled: Bool,
        interstitialAdEnabled: Bool,
        nativeAdEnabled: Bool,
        nativeAdPreloadEnabled: Bool,
        appOpenAdUnitId: String? = nil,
        bannerAdUnitId: String? = nil,
        interstitialAdUnitId: String? = nil,
        nativeAdUnitId: String? = nil,
        interstitialAdShowCount: Int = 4,
        maxInterstitialAdsPerSession: Int = 50,
        bannerAdErrorCount: Int = 7,
        interstitialAdErrorCount: Int = 7,
        nativeAdErrorCount: Int = 7,
        completion: @Sendable @escaping () -> Void
    ) {
        // Configure AdsConfig with provided or default values
        AdsConfig.isProduction = isProduction
        AdsConfig.appOpenAdEnabled = appOpenAdEnabled
        AdsConfig.bannerAdEnabled = bannerAdEnabled
        AdsConfig.interstitialAdEnabled = interstitialAdEnabled
        AdsConfig.nativeAdEnabled = nativeAdEnabled
        AdsConfig.nativeAdPreloadEnabled = nativeAdPreloadEnabled
        
        AdsConfig.appOpenAdUnitId = appOpenAdUnitId ?? "ca-app-pub-3940256099942544/3419835294"
        AdsConfig.bannerAdUnitId = bannerAdUnitId ?? "ca-app-pub-3940256099942544/2934735716"
        AdsConfig.interstitialAdUnitId = interstitialAdUnitId ?? "ca-app-pub-3940256099942544/4411468910"
        AdsConfig.nativeAdUnitId = nativeAdUnitId ?? "ca-app-pub-3940256099942544/3986624511"
        
        AdsConfig.interstitialAdShowCount = interstitialAdShowCount
        AdsConfig.maxInterstitialAdsPerSession = maxInterstitialAdsPerSession
        
        AdsConfig.bannerAdErrorCount = bannerAdErrorCount
        AdsConfig.interstitialAdErrorCount = interstitialAdErrorCount
        AdsConfig.nativeAdErrorCount = nativeAdErrorCount
        
        // Request ATT and UMP consent, then start MobileAds
        AdsManager.configure(completion)
    }
    
    public static func configure(_ completion: @Sendable @escaping () -> Void) {
        // Request ATT first, then UMP consent
        AdsManager.shared.requestATTAuthorization { _ in
            Task { @MainActor in
                AdsManager.shared.requestUMPConsent { _ in
                    MobileAds.shared.start()
                    Task { @MainActor in
                        if ConsentInformation.shared.canRequestAds {
                            // Load initial ads if allowed
                            AdsManager.shared.loadInterstitial()
                            AdsManager.shared.preloadNativeAds()
                        }
                        completion()
                    }
                }
            }
        }
    }
    
    public static let shared = AdsManager()
    
    // Call this before setupAds
    public func requestATTAuthorization(completion: @Sendable @escaping (Bool) -> Void) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("ATT authorized ✅")
                        completion(true)
                    case .denied:
                        print("ATT denied ❌")
                        completion(false)
                    case .restricted, .notDetermined:
                        print("ATT not determined/restricted ⚠️")
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        } else {
            // ATT not required below iOS 14
            completion(true)
        }
    }
    
    public var canRequestAds: Bool {
        return ConsentInformation.shared.canRequestAds
    }
    
    public func requestUMPConsent(completion: @Sendable @escaping (Bool) -> Void) {
        let parameters = RequestParameters()
        #if DEBUG
        let debugSettings = DebugSettings()
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        #endif
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error {
                print("UMP Consent request failed: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            ConsentForm.load { form, loadError in
                if let loadError = loadError {
                    print("UMP Consent form load failed: \(loadError.localizedDescription)")
                    completion(false)
                    return
                }
                
                if ConsentInformation.shared.formStatus == .available, let form = form {
                    let rootVC = UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }?.rootViewController ?? UIViewController()
                    form.present(from: rootVC) { dismissError in
                        if let dismissError = dismissError {
                            print("UMP Consent form dismissed with error: \(dismissError.localizedDescription)")
                            completion(false)
                            return
                        }
                        completion(ConsentInformation.shared.canRequestAds)
                    }
                } else {
                    completion(ConsentInformation.shared.canRequestAds)
                }
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
