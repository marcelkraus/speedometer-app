import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.register(defaults: [
            Configuration.appStartCounterKey: 0,
            Configuration.currentUnitDefaultsKey: Unit.kilometersPerHour.rawValue,
            Configuration.currentSpeedLimitDefaultsKey: "0"
        ])

        application.isIdleTimerDisabled = true
        StoreReviewHelper.incrementAppStartCounter()

        return true
    }
}
