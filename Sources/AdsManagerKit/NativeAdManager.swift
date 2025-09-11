import GoogleMobileAds
import UIKit
public enum AdType: String {
    case SMALL = "NativeAdView_Small"
    case MEDIUM = "NativeAdView_Medium"
    case LARGE = "NativeAdView"
}
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
    
    // MARK: - Preload Native Ads
    func preloadNativeAds(count: Int = 1) {
        if AdsConfig.nativeAdPreloadEnabled {
            for i in 0..<count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    self.loadAd()
                }
            }
        }
    }
    
    // MARK: - Get Ad (Cached or Load On Demand)
    func getAd(in containerView: UIView,
               adType: AdType,
               completion: @escaping (Bool) -> Void) {
        self.completionHandler = completion
        if let ad = adCache.first {
            adCache.removeFirst()
            self.displayNativeAd(in: containerView, ad, adType: adType)
            // Start preloading again to maintain cache size
            loadAd()
        } else {
            // No cached ad → Load now
            loadAd { ad in
                if ad != nil {
                    self.displayNativeAd(in: containerView, ad!, adType: adType)
                } else {
                    self.completionHandler?(false)
                }
            }
        }
    }
    
    private func displayNativeAd(in containerView: UIView, _ nativeAd: NativeAd, adType: AdType) {
        // Load the custom XIB
        guard let adView = Bundle.module.loadNibNamed(adType.rawValue, owner: nil, options: nil)?.first as? NativeAdView else {
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
        if adType == .LARGE {
            adView.mediaView?.mediaContent = nativeAd.mediaContent
            // Optional extra assets
            (adView.advertiserView as? UILabel)?.text = nativeAd.advertiser
            (adView.priceView as? UILabel)?.text = nativeAd.price
            (adView.storeView as? UILabel)?.text = nativeAd.store
            // Set the star rating
            if let starRating = nativeAd.starRating {
                (adView.starRatingView as? UIImageView)?.image = getStarRatingImage(for: starRating)
                adView.starRatingView?.isHidden = false
            } else {
                adView.starRatingView?.isHidden = true // Hide if no rating
            }
        }
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

func getStarRatingImage(for rating: NSDecimalNumber) -> UIImage? {
    let ratingValue = rating.floatValue
    let fullStars = Int(ratingValue)
    let halfStar = ratingValue - Float(fullStars) >= 0.5 ? 1 : 0
    
    var starImages: [UIImage] = []
    
    // Add full stars
    for _ in 0..<fullStars {
        starImages.append(UIImage(systemName: "star.fill")!) // Replace with your full star image
    }
    // Add half star if applicable
    if halfStar > 0 {
        starImages.append(UIImage(systemName: "star.lefthalf.fill")!) // Replace with your half star image
    }
    // Add empty stars to fill to 5
    let emptyStars = 5 - fullStars - halfStar
    for _ in 0..<emptyStars {
        starImages.append(UIImage(systemName: "star")!) // Replace with your empty star image
    }
    
    // Combine star images into a single image view
    return combineStarImages(starImages)
}

func combineStarImages(_ images: [UIImage]) -> UIImage? {
    // Create a UIGraphics context to combine images
    let combinedWidth = images.count * 20 // Assuming each star is 20 points wide
    UIGraphicsBeginImageContext(CGSize(width: combinedWidth, height: 20))
    
    for (index, image) in images.enumerated() {
        image.draw(in: CGRect(x: index * 20, y: 0, width: 20, height: 20))
    }
    
    let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return combinedImage
}

// MARK: - GADNativeAdLoaderDelegate
extension NativeAdManager: NativeAdLoaderDelegate {
    nonisolated func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        let loaderID = ObjectIdentifier(adLoader)
        Task { @MainActor in
            self.handleAdLoaded(loaderID: loaderID, nativeAd: nativeAd)
        }
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        let loaderID = ObjectIdentifier(adLoader)
        Task { @MainActor in
            self.handleAdFailed(loaderID: loaderID, error: error)
        }
    }
}

@MainActor
private extension NativeAdManager {
    func handleAdLoaded(loaderID: ObjectIdentifier, nativeAd: NativeAd) {
        activeAdLoaders.removeAll { ObjectIdentifier($0) == loaderID }
        print("[NativeAd] loaded.")
        self.resetErrorCounter()
        if let (loader, completion) = completionHandlers.first(where: { ObjectIdentifier($0.key) == loaderID }) {
            completion(nativeAd)
            self.completionHandler?(true)
            completionHandlers.removeValue(forKey: loader)
        } else {
            if adCache.count < maxCacheCapacity {
                adCache.append(nativeAd)
                self.completionHandler?(true)
                print("Cached Ads Count: \(NativeAdManager.shared.adCache.count)")
            }
        }
    }

    func handleAdFailed(loaderID: ObjectIdentifier, error: Error) {
        activeAdLoaders.removeAll { ObjectIdentifier($0) == loaderID }
        print("[NativeAd] Debug Info: AdUnitID: \(AdsConfig.nativeAdUnitId), Error: \(error)")
        self.incrementErrorCounter()
        self.completionHandler?(false)
        if let (loader, completion) = completionHandlers.first(where: { ObjectIdentifier($0.key) == loaderID }) {
            completion(nil)
            completionHandlers.removeValue(forKey: loader)
        }
    }
}

// MARK: - Sendable Conformance for SDK Types
extension NativeAd: @unchecked @retroactive Sendable {}
extension AdLoader: @unchecked @retroactive Sendable {}
