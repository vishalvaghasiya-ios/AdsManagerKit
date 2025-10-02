import GoogleMobileAds
import UIKit
public enum BannerAdType: String {
    case ADAPTIVE
    case REGULAR
}
@MainActor
final class BannerAdManager: NSObject {
    
    static let shared = BannerAdManager()
    
    private var bannerView: BannerView?
    private var completionHandler: ((Bool, CGFloat) -> Void)?
    private var bannerHeight = CGFloat(0)
    
    public func resetErrorCounter() {
        AdsConfig.currentBannerAdErrorCount = 0
    }
    
    private func incrementErrorCounter() {
        AdsConfig.currentBannerAdErrorCount += 1
    }
    
    private func hasExceededErrorLimit() -> Bool {
        return AdsConfig.currentBannerAdErrorCount >= AdsConfig.bannerAdErrorCount
    }
    
    func loadBannerAd(in containerView: UIView,
                      vc: UIViewController,
                      type: BannerAdType,
                      completion: @escaping (Bool, CGFloat) -> Void) {
        if AdsManager.shared.canRequestAds {
            if !AdsConfig.bannerAdEnabled {
                completion(false, bannerHeight)
                return
            }
            
            // ❌ If ad not loaded, try loading
            guard !hasExceededErrorLimit() else {
                print("[BannerAd] ⚠️ Max retries exceeded — not loading or showing.")
                completion(false, bannerHeight)
                return
            }
            
            let viewWidth = containerView.bounds.width > 0 ? containerView.bounds.width : UIScreen.main.bounds.width
            if type == .ADAPTIVE {
                let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
                let banner = BannerView(adSize: adaptiveSize)
                bannerHeight = adaptiveSize.size.height
                bannerView = banner
            } else {
                let regularSize = AdSize(size: CGSize(width: 320, height: 50), flags: 0)
                let banner = BannerView(adSize: regularSize)
                bannerHeight = regularSize.size.height
                bannerView = banner
            }
            let banner = bannerView!
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
            self.completionHandler = completion
        } else {
            completion(false, bannerHeight)
        }
    }
}

extension BannerAdManager: BannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("[BannerAd] loaded.")
        self.resetErrorCounter()
        completionHandler?(true, bannerHeight)
    }

    public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[BannerAd] Failed to load: \(error.localizedDescription)")
        self.incrementErrorCounter()
        completionHandler?(false, bannerHeight)
    }
}
