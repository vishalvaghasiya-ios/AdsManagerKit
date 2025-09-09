import GoogleMobileAds
import UIKit

@MainActor
final class NativeAdManager: NSObject {
    
    static let shared = NativeAdManager()
    
    // For handling individual ad requests
    private var completionHandlers: [AdLoader: (NativeAd?) -> Void] = [:]
    private var adCache: [NativeAd] = []
    private let maxCacheCapacity = 3
    private var activeAdLoaders: [AdLoader] = []
    private var completionHandler: ((Bool) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func resetErrorCounter() {
        AdsConfig.currentNativeAdErrorCount = 0
    }
    
    private func incrementErrorCounter() {
        AdsConfig.currentNativeAdErrorCount += 1
    }
    
    private func hasExceededErrorLimit() -> Bool {
        return AdsConfig.currentNativeAdErrorCount >= AdsConfig.nativeAdErrorCount
    }
    
    // MARK: - Preload Ads
    func preloadAds(count: Int = 1) {
        for _ in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0.5)) {
                self.loadAd()
            }
        }
    }
    
    // MARK: - Get Ad (Cached or Load On Demand)
    func getAd(in containerView: UIView,
               completion: @escaping (Bool) -> Void) {
        self.completionHandler = completion
        if let ad = adCache.first {
            adCache.removeFirst()
            self.displayNativeAd(in: containerView, ad)
            // Start preloading again to maintain cache size
            loadAd()
        } else {
            // No cached ad → Load now
            loadAd { ad in
                if ad != nil {
                    self.displayNativeAd(in: containerView, ad!)
                } else {
                    self.completionHandler?(false)
                }
            }
        }
    }
    
    private func displayNativeAd(in containerView: UIView, _ nativeAd: NativeAd) {
        // Load the custom XIB
        guard let adView = Bundle.main.loadNibNamed("NativeAdView_Small", owner: nil, options: nil)?.first as? NativeAdView else {
            self.completionHandler?(false)
            return
        }
        
        // Set frame to match container
        adView.frame = containerView.bounds
        containerView.addSubview(adView)
        
        // Assign the nativeAd to GADNativeAdView
        adView.nativeAd = nativeAd
        
        // Bind assets
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        adView.callToActionView?.isUserInteractionEnabled = false // Required
    }
    
    // MARK: - Internal Ad Loader
    private func loadAd(completion: ((NativeAd?) -> Void)? = nil) {
        if !AdsConfig.nativeAdEnabled {
            self.completionHandler?(false)
            return
        }
        guard !hasExceededErrorLimit() else {
            print("[NativeAd] ⚠️ Max error attempts reached — not loading.")
            self.completionHandler?(false)
            return
        }
        
        let adLoader = AdLoader(adUnitID: AdsConfig.nativeAdUnitId,
                                rootViewController: nil,
                                adTypes: [.native],
                                options: nil)
        if let completion = completion {
            completionHandlers[adLoader] = completion
        }
        adLoader.delegate = self
        activeAdLoaders.append(adLoader)
        adLoader.load(Request())
    }
}

// MARK: - GADNativeAdLoaderDelegate
extension NativeAdManager: NativeAdLoaderDelegate {
    nonisolated func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
//        Task { @MainActor [self, adLoader] in
//            let ad = nativeAd
//            self.activeAdLoaders.removeAll { $0 === adLoader }
//            print("[NativeAd] loaded.")
//            self.resetErrorCounter()
//            if let completion = self.completionHandlers[adLoader] {
//                // On-demand load → Call completion
//                completion(ad)
//                self.completionHandler?(true)
//                self.completionHandlers.removeValue(forKey: adLoader)
//            } else {
//                // Preloaded → Cache it
//                if self.adCache.count < self.maxCacheCapacity {
//                    self.adCache.append(ad)
//                    self.completionHandler?(true)
//                    print("Cached Ads Count: \(self.adCache.count)")
//                }
//            }
//        }
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
//        Task { @MainActor [self, adLoader, error] in
//            self.activeAdLoaders.removeAll { $0 === adLoader }
//            print("[NativeAd] Debug Info: AdUnitID: \(AdsConfig.nativeAdUnitId), Error: \(error)")
//            self.incrementErrorCounter()
//            self.completionHandler?(false)
//            if let completion = self.completionHandlers[adLoader] {
//                completion(nil)
//                self.completionHandlers.removeValue(forKey: adLoader)
//            }
//        }
    }
}
