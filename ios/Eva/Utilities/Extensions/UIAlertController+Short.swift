import UIKit

extension UIAlertController {
    static func controllerWithTitle(title: String?, message: String?,
        handler: ((UIAlertAction) -> Void)? = nil) -> Self
    {
        let alertController = self.init(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: handler))
        return alertController
    }
}
