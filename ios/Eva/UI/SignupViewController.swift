
import UIKit
import PhoneNumberKit


class SignupViewController : UIViewController {

    let interactor = SignUpInteractor()

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var phoneNumberField: UITextField! {
        didSet {
            phoneNumberField.textColor = Color.helpColor
        }
    }
    @IBOutlet private weak var signupButton: UIButton! {
        didSet {
            signupButton.backgroundColor = Color.helpColor
            signupButton.setTitleColor(Color.white, forState: .Normal)
        }
    }
    @IBOutlet private weak var centerConstraint: NSLayoutConstraint!
    private var isLoading: Bool = false {
        didSet {
            buttonEnabled = !isLoading
            isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
    private var buttonEnabled: Bool = true {
        didSet {
            signupButton.enabled = buttonEnabled ? true : false
            signupButton.alpha = buttonEnabled ? 1 : 0.3
        }
    }
    
    var keyboardObservers: [NSObjectProtocol] = []
    
    var phoneNumber: String {
        guard let number = phoneNumberField.text else { return "" }
        return number.trim()
    }

    var parsedPhoneNumber: PhoneNumber? {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: self.phoneNumber)
            return phoneNumber
        } catch {
            return nil
        }
    }

    @IBAction func handleSignUp() {
        guard let parsedPhoneNumber = parsedPhoneNumber else { return }

        let internationalNumber = parsedPhoneNumber.toE164()

        isLoading = true
        interactor.signUp(withPhoneNumber: internationalNumber,
            onSuccess: { signupToken in
                self.isLoading = false
                self.completeSignup(parsedPhoneNumber, signupToken: signupToken)
            }, onFailure: showError)
    }
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }

    func completeSignup(phoneNumber: PhoneNumber, signupToken: String) {
        let controller = VerificationViewController(phoneNumber: phoneNumber,
            signupToken: signupToken)
        navigationController?.pushViewController(controller, animated: true)
    }

    func showError(error: NSError) {
        isLoading = false
        let controller = UIAlertController.controllerWithTitle("Error",
            message: "Failed to sign up: \(error.localizedDescription)")
        presentViewController(controller, animated: true, completion: nil)
    }

    func updateButtonState() {
        buttonEnabled = parsedPhoneNumber != nil
    }


    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Signup"
        phoneNumberField.addTarget(self,
            action: Selector("updateButtonState"),
            forControlEvents: .EditingChanged)

        updateButtonState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
}

extension SignupViewController: KeyboardNotificationsProtocol {
    private func registerForKeyboardNotifications() {
        keyboardWillShowNotification { height, duration, curve in
            self.centerConstraint.constant = -height/2
            UIView.animateWithDuration(duration, delay: 0, options: curve, animations: {
                self.view.layoutSubviews()
                }, completion:  nil
            )
        }
        
        keyboardWillHideNotification { height, duration, curve in
            self.centerConstraint.constant = 0
            UIView.animateWithDuration(duration, delay: 0, options: curve, animations: {
                self.view.layoutSubviews()
                }, completion:  nil
            )
        }
    }
}