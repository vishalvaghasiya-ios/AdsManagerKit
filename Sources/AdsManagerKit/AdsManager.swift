import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
import UserMessagingPlatform
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
    
    public var interstitialAdShowCount: Int
    
    public var bannerAdErrorCount: Int
    public var interstitialAdErrorCount: Int
    public var nativeAdErrorCount: Int
    
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
    
    private var pendingTrackingCompletion: (() -> Void)?
    
    private lazy var sceneDidActivateObserver: NSObjectProtocol = {
        NotificationCenter.default.addObserver(
            forName: UIScene.didActivateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in
                    Task { @MainActor [weak self] in
                        self?.pendingTrackingCompletion?()
                        self?.pendingTrackingCompletion = nil
                    }
                }
            }
        }
    }()
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      scene.activationState == .foregroundActive else {
                    self.pendingTrackingCompletion = completion
                    _ = self.sceneDidActivateObserver
                    return
                }

                ATTrackingManager.requestTrackingAuthorization { _ in
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    public func requestUMPConsent(completion: @escaping (Bool) -> Void) {
        let parameters = RequestParameters()
        #if DEBUG
        let debugSettings = DebugSettings()
        debugSettings.geography = DebugGeography.EEA
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
                        completion(ConsentInformation.shared.consentStatus == .obtained)
                    }
                } else {
                    completion(ConsentInformation.shared.consentStatus == .obtained)
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
