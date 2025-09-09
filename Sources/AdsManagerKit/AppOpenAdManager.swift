import GoogleMobileAds
import UIKit

// MARK: - AppOpenAdManager
@MainActor
final class AppOpenAdManager: NSObject {

    static let shared = AppOpenAdManager()

    private var appOpenAd: AppOpenAd?
    private var didFirstLoadFail = false
    private var completionHandler: (() -> Void)?

    private let adValidityDuration: TimeInterval = 4 * 3_600
    private var adLoadTime: Date?
    private var isLoadingAd = false
    private var isShowingAd = false

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

    func loadAndShow(completion: @escaping () -> Void) {
        self.completionHandler = completion

        if isLoadingAd || isAdAvailable() {
            completion()
            return
        }

        isLoadingAd = true
        let request = Request()
        AppOpenAd.load(
            with: AdsConfig.appOpenAdUnitId,
            request: request
        ) { ad, error in
            if let error = error {
                self.isLoadingAd = false
                self.appOpenAd = nil
                self.adLoadTime = nil
                if !self.didFirstLoadFail {
                    self.didFirstLoadFail = true
                    self.loadAndShow(completion: completion)
                } else {
                    self.completionHandler?()
                }
                print("[AppOpenAd] Failed to load: \(error)")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
            self.adLoadTime = Date()
            print("[AppOpenAd] loaded.")

            ad?.present(from: nil)
        }
    }

    func requestAppOpenAd() {
        if isLoadingAd || isAdAvailable() {
            return
        }
        if AdsConfig.appOpenAdEnabled {
            isLoadingAd = true
            AppOpenAd.load(with: AdsConfig.appOpenAdUnitId, request: Request()) { ad, error in
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
                print("[AppOpenAd] loaded.")
            }
        }
    }

    func tryToPresentAd() {
        if isShowingAd {
            print("[AppOpenAd] is already showing.")
            return
        }

        if !isAdAvailable() {
            print("[AppOpenAd] is not ready yet.")
            requestAppOpenAd()
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

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Dismissed")
        appOpenAd = nil
        isShowingAd = false
        completionHandler?()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AppOpenAd] Failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        completionHandler?()
    }

    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Will present")
    }
}
