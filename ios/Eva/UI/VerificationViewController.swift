
import UIKit
import PhoneNumberKit


class VerificationViewController : UIViewController {

    let phoneNumber: PhoneNumber
    let signupToken: String

    let verifyPhoneInteractor = VerifyPhoneInteractor()

    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var verificationCodeField: UITextField!
    @IBOutlet private weak var phoneNumberLabel: UILabel!
    @IBOutlet private weak var verifyButton: UIButton! {
        didSet {
            verifyButton.backgroundColor = Color.helpColor
            verifyButton.setTitleColor(Color.white, forState: .Normal)
        }
    }
    private var isLoading: Bool = false {
        didSet {
            buttonEnabled = !isLoading
            isLoading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
    private var buttonEnabled: Bool = true {
        didSet {
            verifyButton.enabled = buttonEnabled ? true : false
            verifyButton.alpha = buttonEnabled ? 1 : 0.3
        }
    }
    
    var verificationCode: String {
        return verificationCodeField.text ?? ""
    }

    required init(phoneNumber: PhoneNumber, signupToken: String) {
        self.phoneNumber = phoneNumber
        self.signupToken = signupToken

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func handleVerify() {
        isLoading = true
        verifyPhoneInteractor.verifyPhone(withCodeNumber: verificationCode, token: signupToken,
            onSuccess: completeSignup, onFailure: showError)
    }

    func completeSignup() {
        isLoading = false
        let controller = ReportViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    func showError(error: NSError) {
        isLoading = false
        let controller = UIAlertController.controllerWithTitle("Error",
            message: "Failed to verify: \(error)")
        presentViewController(controller, animated: true, completion: nil)
    }


    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberLabel.text = phoneNumber.toInternational()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        verificationCodeField.becomeFirstResponder()
    }
}