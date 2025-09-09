import Foundation
import UIKit

struct AdsConfig {

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

    // MARK: - Error/Count Variables
    static var bannerAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var currentBannerAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var interstitialAdDisplayCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var interstitialAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var currentInterstitialAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var interstitialAdShowCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var nativeAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }

    static var currentNativeAdErrorCount: Int {
        get { getInt(forKey: #function) }
        set { setInt(newValue, forKey: #function) }
    }
}
