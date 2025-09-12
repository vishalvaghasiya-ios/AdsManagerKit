
# AdsManagerKit

**AdsManagerKit** is a Swift Package designed to simplify the integration of Google Mobile Ads (AdMob) and Google User Messaging Platform (UMP) in your iOS projects. It handles **App Tracking Transparency (ATT)**, **banner ads**, **interstitial ads**, **native ads**, and **app open ads** with minimal setup, allowing developers to focus on app functionality while maintaining compliance with privacy regulations.  

---

## ✨ Features

- Easy-to-integrate AdMob banner, interstitial, native, and app open ads.
- Automated handling of App Tracking Transparency (ATT) prompts.
- Google UMP consent collection support.
- Supports both **Production** and **Test** ad units.
- Swift Package Manager (SPM) compatible.
- Configurable ad error counters and ad display frequency.
- Asynchronous, safe ad loading to prevent crashes on iOS 14+.


## 📦 Installation

### Swift Package Manager (SPM)

1. Open your project in Xcode.
2. Go to **File > Add Packages…**
3. Enter the repository URL:  
```swift
https://github.com/vishalvaghasiya-ios/AdsManagerKit.git
```
4. Select the desired version (latest stable recommended) and add it to your app target.
5. Import into your Swift files:

```swift
import AdsManagerKit
```
## 🚀 How to Use

1. Configure Ads

Create an AdsConfiguration object:
```swift
let adsConfig = AdsConfiguration(
    isProduction: false, // Set true for production
    appOpenAdEnabled: true,
    bannerAdEnabled: true,
    interstitialAdEnabled: true,
    nativeAdEnabled: true,
    nativeAdPreloadEnabled: true,
    
    appOpenAdUnitId: "YOUR_APP_OPEN_AD_UNIT_ID",
    bannerAdUnitId: "YOUR_BANNER_AD_UNIT_ID",
    interstitialAdUnitId: "YOUR_INTERSTITIAL_AD_UNIT_ID",
    nativeAdUnitId: "YOUR_NATIVE_AD_UNIT_ID",
    
    interstitialAdShowCount: 3,
    bannerAdErrorCount: 3,
    interstitialAdErrorCount: 3,
    nativeAdErrorCount: 3
)
```
2. Setup Ads
```swift
AdsManager.shared.setupAds(with: adsConfig)
```
3. Request App Tracking Permission (iOS 14+)
```swift
AdsManager.shared.requestAppTrackingPermission {
    print("ATT permission handled")
}
```
4. Request UMP Consent
```swift
AdsManager.shared.requestUMPConsent { granted in
    if granted {
        print("User consent obtained")
    } else {
        print("Consent not granted")
    }
}
```
**5. Loading Ads**

**Banner Ads:**
```swift
AdsManager.shared.loadBanner(in: bannerContainer, rootViewController: self) { isShown in
    print("Banner loaded: \(isShown)")
}
```
**Interstitial Ads:**
```swift
AdsManager.shared.showInterstitial(from: self) {
    print("Interstitial dismissed")
}
```
**Native Ads:**
```swift
AdsManager.shared.loadNative(in: nativeContainer, adType: .SMALL) { isLoaded in
    print("Native ad loaded: \(isLoaded)")
}
```
**App Open Ads:**
```swift
AdsManager.shared.presentAppOpenAdIfAvailable()
```


**Version**

Current Version: 1.0.0


Notes
	•	Ensure NSUserTrackingUsageDescription is added in your app’s Info.plist to prevent crashes with ATT.
	•	Use Test Ad Units when isProduction is set to false.
	•	Always request UMP consent before loading personalized ads in regions requiring GDPR compliance.


Author

**Vishal Vaghasiya**
