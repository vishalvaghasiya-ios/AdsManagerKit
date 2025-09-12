import Foundation
import UIKit

public struct AdsConfig {

    // MARK: - Private helpers
    private static func getString(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }

    private static func setString(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private static func getInt(forKey key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }

    private static func setInt(_ value: Int, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // MARK: - Ad Preferences

    // MARK: - Environment
    static var isProduction: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    static var appOpenAdEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    static var bannerAdEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    static var interstitialAdEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    static var nativeAdEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    static var nativeAdPreloadEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: #function) }
        set { UserDefaults.standard.set(newValue, forKey: #function) }
    }

    // MARK: - Ad Unit IDs
    static var appOpenAdUnitId: String {
        get { getString(forKey: #function) }
        set { setString(newValue, forKey: #function) }
    }

    static var bannerAdUnitId: String {
        get { getString(forKey: #function) }
        set { setString(newValue, forKey: #function) }
    }

    static var interstitialAdUnitId: String {
        get { getString(forKey: #function) }
        set { setString(newValue, forKey: #function) }
    }

    static var nativeAdUnitId: String {
        get { getString(forKey: #function) }
        set { setString(newValue, forKey: #function) }
    }

    // MARK: - Persistent Ad Error Counts
    static var bannerAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }
    
    static var interstitialAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }
    
    static var nativeAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    // MARK: - Current Ad Error Counters (resets on app restart)
    nonisolated(unsafe) static var currentBannerAdErrorCount: Int = 0
    nonisolated(unsafe) static var currentInterstitialAdErrorCount: Int = 0
    nonisolated(unsafe) static var currentNativeAdErrorCount: Int = 0
    
    // MARK: - Interstitial Ad Counters
    static var interstitialAdShowCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }
}
