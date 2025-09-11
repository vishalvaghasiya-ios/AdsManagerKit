import GoogleMobileAds
import UIKit

@MainActor
public final class InterstitialAdManager: NSObject, FullScreenContentDelegate {
    
    public static let shared = InterstitialAdManager()
    
    private var interstitialAd: InterstitialAd?
    private var completionHandler: (() -> Void)?
    var displayCounter: Int = 0
    
    public func resetErrorCounter() {
        AdsConfig.currentInterstitialAdErrorCount = 0
    }
    
    private func incrementErrorCounter() {
        AdsConfig.currentInterstitialAdErrorCount += 1
    }
    
    private func hasExceededErrorLimit() -> Bool {
        return AdsConfig.currentInterstitialAdErrorCount >= AdsConfig.interstitialAdErrorCount
    }
    
    public func loadAndShow(completion: @escaping () -> Void) {
        self.completionHandler = completion
        
        if let ad = interstitialAd {
            print("[InterstitialAd] already loaded — presenting directly.")
            ad.present(from: nil)
            return
        }
        
        guard !hasExceededErrorLimit() else {
            print("[InterstitialAd] ⚠️ Max retries exceeded — not loading or showing.")
            completion()
            return
        }
        
        let request = Request()
        InterstitialAd.load(
            with: AdsConfig.interstitialAdUnitId,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[InterstitialAd] Failed to load: \(error.localizedDescription)")
                self.incrementErrorCounter()
                self.completionHandler?()
                return
            }
            
            self.resetErrorCounter()
            
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            ad?.present(from: nil)
            
        }
    }
    
    /// Load the interstitial ad
    func loadAd() {
        guard !hasExceededErrorLimit() else {
            print("[InterstitialAd] ⚠️ Max error attempts reached — not loading.")
            return
        }
        
        if !AdsConfig.interstitialAdEnabled {
            return
        }
        
        guard interstitialAd == nil else { return }
        
        let request = Request()
        InterstitialAd.load(with: AdsConfig.interstitialAdUnitId, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[InterstitialAd] Failed to load: \(error.localizedDescription)")
                self.incrementErrorCounter()
                return
            }
            
            self.resetErrorCounter()
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            print("[InterstitialAd] loaded and ready.")
        }
    }
    
    /// Show the ad if available, then run completion
    func showAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        guard AdsConfig.interstitialAdEnabled, let ad = interstitialAd else {
            loadAd()
            completion()
            return
        }
        
        if displayCounter >= AdsConfig.interstitialAdShowCount {
            displayCounter = 1
            resetErrorCounter()
            completionHandler = completion
            ad.present(from: viewController)
        } else {
            displayCounter += 1
            completion()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    
    public func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[InterstitialAd] Dismissed")
        interstitialAd = nil
        loadAd()
        completionHandler?()
    }
    
    public func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("[InterstitialAd] Failed to present: \(error.localizedDescription)")
        interstitialAd = nil
        loadAd()
        completionHandler?()
    }
    
    public func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("[InterstitialAd] Will present")
    }
}
