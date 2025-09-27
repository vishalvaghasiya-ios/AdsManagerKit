@preconcurrency import GoogleMobileAds
import UIKit

// MARK: - AppOpenAdManager
@MainActor
// [START app_open_ad_manager]
public final class AppOpenAdManager: NSObject {
    // The app open ad.
    private var appOpenAd: AppOpenAd?
    /// Maintains a reference to the delegate.
    private var appOpenAdManagerAdDidComplete: (@Sendable () -> Void)?
    private var didFirstLoadFail = false
    
    /// Keeps track of if an app open ad is loading.
    private var isLoadingAd = false
    /// Keeps track of if an app open ad is showing.
    private var isShowingAd = false
    /// Keeps track of the time when an app open ad was loaded to discard expired ad.
    private var adLoadTime: Date?
    private let adValidityDuration: TimeInterval = 4 * 3_600
    
    public static let shared = AppOpenAdManager()
    // MARK: - Private Methods
    
    private func wasLoadTimeLessThanNHoursAgo(timeoutInterval: TimeInterval) -> Bool {
        if let adLoadTime = adLoadTime {
            return Date().timeIntervalSince(adLoadTime) < timeoutInterval
        }
        return false
    }
    
    private func isAdAvailable() -> Bool {
        return appOpenAd != nil && wasLoadTimeLessThanNHoursAgo(timeoutInterval: adValidityDuration)
    }
    
    // MARK: - Public Methods
    
    public func loadAndShow(completion: @escaping @Sendable () -> Void) {
        self.appOpenAdManagerAdDidComplete = completion
        if AdsManager.shared.canRequestAds {
            if isLoadingAd || isAdAvailable() {
                completion()
                return
            }
            
            if !AdsConfig.openAdOnLaunchEnabled {
                completion()
                return
            }
            
            if let ad = appOpenAd {
                print("[AppOpenAd] will be displayed.")
                isShowingAd = true
                ad.present(from: nil)
            } else {
                isLoadingAd = true
                let request = Request()
                AppOpenAd.load(
                    with: AdsConfig.openAdUnitId,
                    request: request
                ) { [weak self] ad, error in
                    Task { @MainActor in
                        guard let self else {
                            completion()
                            return
                        }
                        if let error = error {
                            self.isLoadingAd = false
                            self.appOpenAd = nil
                            self.adLoadTime = nil
                            if !self.didFirstLoadFail {
                                self.didFirstLoadFail = true
                                self.loadAndShow(completion: completion)
                            } else {
                                completion()
                            }
                            print("[AppOpenAd] Failed to load: \(error)")
                            return
                        }
                        self.appOpenAd = ad
                        self.appOpenAd?.fullScreenContentDelegate = self
                        self.adLoadTime = Date()
                        self.isLoadingAd = false
                        print("[AppOpenAd] loaded.")
                        self.appOpenAd?.present(from: nil)
                    }
                }
            }
        } else {
            completion()
        }
    }
    
    func loadOpenAd() {
        if AdsManager.shared.canRequestAds {
            if isLoadingAd || isAdAvailable() {
                return
            }
            if AdsConfig.openAdEnabled {
                isLoadingAd = true
                AppOpenAd.load(with: AdsConfig.openAdUnitId, request: Request()) { [weak self] ad, error in
                    Task { @MainActor in
                        guard let self else { return }
                        if let error = error {
                            self.isLoadingAd = false
                            self.appOpenAd = nil
                            self.adLoadTime = nil
                            print("[AppOpenAd] Failed to load: \(error)")
                            return
                        }
                        self.appOpenAd = ad
                        self.appOpenAd?.fullScreenContentDelegate = self
                        self.adLoadTime = Date()
                        self.isLoadingAd = false
                        print("[AppOpenAd] loaded.")
                    }
                }
            }
        }
    }
    
    func tryToPresentAd() {
        // If the app open ad is already showing, do not show the ad again.
        if isShowingAd {
            print("[AppOpenAd] is already showing.")
            return
        }
        
        if !isAdAvailable() {
            print("[AppOpenAd] is not ready yet.")
            loadOpenAd()
            return
        }
        
        if let ad = appOpenAd {
            print("[AppOpenAd] will be displayed.")
            isShowingAd = true
            ad.present(from: nil)
        }
    }
}

// MARK: - FullScreenContentDelegate

extension AppOpenAdManager: FullScreenContentDelegate {
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Dismissed")
        appOpenAd = nil
        isShowingAd = false
        appOpenAdManagerAdDidComplete?()
        loadOpenAd()
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AppOpenAd] Failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        appOpenAdManagerAdDidComplete?()
        loadOpenAd()
    }
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Will present")
    }
}
