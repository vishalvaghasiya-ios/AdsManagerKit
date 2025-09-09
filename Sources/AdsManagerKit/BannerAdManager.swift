import GoogleMobileAds
import UIKit

@MainActor
public final class BannerAdManager: NSObject {
    
    public static let shared = BannerAdManager()
    
    private var bannerView: BannerView?
    private var completionHandler: ((Bool) -> Void)?
    
    public func resetErrorCounter() {
        AdsConfig.currentBannerAdErrorCount = 0
    }
    
    private func incrementErrorCounter() {
        AdsConfig.currentBannerAdErrorCount += 1
    }
    
    private func hasExceededErrorLimit() -> Bool {
        return AdsConfig.currentBannerAdErrorCount >= AdsConfig.bannerAdErrorCount
    }
    
    public func loadBannerAd(in containerView: UIView,
                      vc: UIViewController,
                      completion: @escaping (Bool) -> Void) {
        
        if !AdsConfig.bannerAdEnabled {
            completion(false)
            return
        }
        
        // ❌ If ad not loaded, try loading
        guard !hasExceededErrorLimit() else {
            print("[BannerAd] ⚠️ Max retries exceeded — not loading or showing.")
            completion(false)
            return
        }
        
        let adSize = AdSize(size: CGSize(width: 320, height: 50), flags: 0) // ✅ Correct usage
        
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = AdsConfig.bannerAdUnitId
        banner.rootViewController = vc
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(banner)
        containerView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            banner.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            banner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        banner.load(Request())
        bannerView = banner
        self.completionHandler = completion
    }
}

extension BannerAdManager: BannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("[BannerAd] loaded.")
        self.resetErrorCounter()
        completionHandler?(true)
    }

    public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[BannerAd] Failed to load: \(error.localizedDescription)")
        self.incrementErrorCounter()
        completionHandler?(false)
    }
}
