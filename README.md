# AdsManagerKit

[TOC]

## 📚 Table of Contents
- [✨ Features](#-features)
- [🛠 Requirements](#-requirements)
- [📦 Installation](#-installation)
- [🚀 Quick Start and How to Use](#-quick-start-and-how-to-use)
- [📝 Version](#-version)
- [⚠️ Notes](#-notes)
- [👤 Author](#-author)

---

**AdsManagerKit** is a Swift Package designed to simplify the integration of [Google Mobile Ads (AdMob)](https://developers.google.com/admob/ios/quick-start) and [Google User Messaging Platform (UMP)](https://developers.google.com/admob/ump/ios/quick-start) in your iOS projects. It handles **App Tracking Transparency (ATT)**, **banner ads**, **interstitial ads**, **native ads**, and **app open ads** with minimal setup, allowing developers to focus on app functionality while maintaining compliance with privacy regulations.

---

## ✨ Features

- Easy-to-integrate AdMob banner, interstitial, native, and app open ads.
- Automated handling of App Tracking Transparency (ATT) prompts.
- Google UMP consent collection support.
- Supports both **Production** and **Test** ad units.
- Swift Package Manager (SPM) compatible.
- Configurable ad error counters and ad display frequency.
- Asynchronous, safe ad loading to prevent crashes on iOS 14+.

## 🛠 Requirements

- iOS 15+
- Swift 5.9+
- Xcode 26+
- Add the [`NSUserTrackingUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription) key in your app’s Info.plist to prevent crashes with ATT.

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
import AdsManager
```

## 🚀 Quick Start and How to Use

Set up your ads by configuring ad unit IDs and enabling desired ad types using the new `configureAds` method:

```swift
// Configure Ads using the new method
AdsManager.shared.configureAds(
    appOpenId: "YOUR_APP_OPEN_AD_UNIT_ID",
    bannerId: "YOUR_BANNER_AD_UNIT_ID",
    interstitialId: "YOUR_INTERSTITIAL_AD_UNIT_ID",
    nativeId: "YOUR_NATIVE_AD_UNIT_ID",
    openAdEnabled: true,
    bannerEnabled: true,
    interstitialEnabled: true,
    nativeEnabled: true,
    nativePreloadEnabled: true
)
```

**Note:** If you enable premium mode, all ad-loading and displaying functions will automatically be skipped, effectively disabling ads throughout your app.

### Premium Mode (Optional)

You can enable or disable premium mode to stop or resume ads:

```swift
// Enable premium mode (ads disabled)
AdsManager.setToPremium(true)

// Disable premium mode (ads enabled)
AdsManager.setToPremium(false)
```

### Request App Tracking Permission (iOS 14+)

```swift
AdsManager.shared.requestAppTrackingPermission {
    print("ATT permission handled")
}
```

### Request UMP Consent

```swift
AdsManager.shared.requestUMPConsent { granted in
    print("User consent granted: \(granted)")
}
```

### Loading and Showing Ads

**Banner Ads:**  
```swift
AdsManager.shared.loadBanner(in: bannerContainer, rootViewController: self) { isShown, height in
    print("Banner loaded: \(isShown), height: \(height)")
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

### Test vs Production Ad Units

Use the `isProductionApp` flag to switch between test and production ad units. When `isProductionApp` is set to `false`, AdsManager will use test ad units to help avoid invalid traffic during development and testing. Make sure to set this flag appropriately before configuring your ads.

## 📝 Version

Current Version: 1.0.0 (Initial Release)

## ⚠️ Notes

- Ensure [`NSUserTrackingUsageDescription`](https://developer.apple.com/documentation/bundleresources/information_property_list/nsusertrackingusagedescription) is added in your app’s Info.plist to prevent crashes with ATT.  
- Use Test Ad Units when `isProduction` is set to false.  
- Always request UMP consent before loading personalized ads in regions requiring GDPR compliance.

  
### 🛠 Add Google Mobile Ads App ID
Add your **Google Mobile Ads Application ID** in your app's `Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

- Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your actual AdMob App ID from the [AdMob Console](https://apps.admob.com/).
- Make sure the App ID is **unique to your app** and correctly formatted.
- This ID is required for all AdMob ads to function properly.

## 👤 Author

Vishal Vaghasiya  
GitHub: [vishalvaghasiya-ios](https://github.com/vishalvaghasiya-ios)
