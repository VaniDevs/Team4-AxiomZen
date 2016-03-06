import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        window = UIWindow()
        window!.backgroundColor = .whiteColor()
        Theme.setDefaultTheme()
        if Persistence.authToken() != nil {
            showReport()
        } else {
            showSignup()
        }
        window!.makeKeyAndVisible()
        return true
    }

    func showReport() {
        window!.rootViewController =
            UINavigationController(rootViewController: ReportViewController())
    }

    func showSignup() {
        let signupViewController = SignupViewController()
        window!.rootViewController =
            UINavigationController(rootViewController: signupViewController)
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        return true
    }
}

