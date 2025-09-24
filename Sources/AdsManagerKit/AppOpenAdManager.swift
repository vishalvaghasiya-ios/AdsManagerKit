@preconcurrency import GoogleMobileAds
import UIKit

// MARK: - AppOpenAdManager
@MainActor
public final class AppOpenAdManager: NSObject {

    public static let shared = AppOpenAdManager()

    private var appOpenAd: AppOpenAd?
    private var didFirstLoadFail = false
    private var completionHandler: (@Sendable () -> Void)?

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

    public func loadAndShow(completion: @escaping @Sendable () -> Void) {
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
        ) { [weak self] ad, error in
            Task { @MainActor in
                guard let self else { return }
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
                self.isLoadingAd = false
                print("[AppOpenAd] loaded.")
                self.appOpenAd?.present(from: nil)
            }
        }
    }

    func loadOpenAd() {
        if isLoadingAd || isAdAvailable() {
            return
        }
        if AdsConfig.appOpenAdEnabled {
            isLoadingAd = true
            AppOpenAd.load(with: AdsConfig.appOpenAdUnitId, request: Request()) { [weak self] ad, error in
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

    func tryToPresentAd() {
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
        loadOpenAd()
        completionHandler?()
    }

    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[AppOpenAd] Failed to present: \(error.localizedDescription)")
        appOpenAd = nil
        isShowingAd = false
        loadOpenAd()
        completionHandler?()
    }

    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[AppOpenAd] Will present")
    }
}
