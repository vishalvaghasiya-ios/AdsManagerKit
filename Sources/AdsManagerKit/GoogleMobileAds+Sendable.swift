@preconcurrency import GoogleMobileAds

// These Google Mobile Ads types are from a pre-concurrency module and are not
// annotated as Sendable. We only use and present them on the main actor, but
// they can cross an actor boundary when passed into a Task annotated with @MainActor
// inside the load completion handler. Marking concrete SDK types as
// @unchecked @retroactive Sendable acknowledges that responsibility and silences
// the Swift 6 data race diagnostics.
//
// Note: You cannot add protocol inheritance in a protocol extension, so we do NOT
// attempt to make 'FullScreenPresentingAd' conform to Sendable here.

extension AppOpenAd: @unchecked @retroactive Sendable {}
extension InterstitialAd: @unchecked @retroactive Sendable {}
