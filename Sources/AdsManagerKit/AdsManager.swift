import Foundation
import AppTrackingTransparency
import UIKit
import GoogleMobileAds
@MainActor
class AdsManager: NSObject {
    
    static let shared = AdsManager()
    
    func requestAppTrackingPermission(completion: @escaping () -> Void) {
        ATTrackingManager.requestTrackingAuthorization { _ in
            completion()
        }
    }
    
    func resetErrorCounters() {
        BannerAdManager.shared.resetErrorCounter()
        InterstitialAdManager.shared.resetErrorCounter()
        NativeAdManager.shared.resetErrorCounter()
    }
 
    // MARK: - App Open Ad
    func presentAppOpenAdIfAvailable() {
        AppOpenAdManager.shared.tryToPresentAd()
    }
    
    // MARK: - Interstitial Ad
    func loadInterstitial() {
        InterstitialAdManager.shared.loadAd()
    }
    
    func showInterstitial(from viewController: UIViewController,
                          completion: @escaping () -> Void) {
        InterstitialAdManager.shared.showAd(from: viewController, completion: completion)
    }

    // MARK: - Banner Ad
    func loadBanner(in containerView: UIView,
                    rootViewController: UIViewController,
                    completion: @escaping (Bool) -> Void) {
        BannerAdManager.shared.loadBannerAd(in: containerView, vc: rootViewController, completion: completion)
    }

    // MARK: - Native Ad
    func loadNative(in containerView: UIView,
                    completion: @escaping (Bool) -> Void) {
        NativeAdManager.shared.getAd(in: containerView, completion: completion)
    }
    
}
