import UIKit


protocol ContextViewControllerDelegate : class {

    func contextViewControllerDidFinish(controller: ContextViewController,
        withContext context: String?)

}

class ContextViewController : UIViewController {

    @IBOutlet weak var textView: UITextView!

    var context: String?

    weak var delegate: ContextViewControllerDelegate?

    required init(context: String?) {
        self.context = context

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Situation"

        textView.text = context ?? "Describe your situation ..."
        
        if context == nil {
            textView.textColor = .grayColor()
        }

        textView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if context != nil {
            textView.becomeFirstResponder()
        }
    }


    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        delegate?.contextViewControllerDidFinish(self, withContext: context)
    }
}


//  MARK: UITextViewDelegate

extension ContextViewController : UITextViewDelegate {

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {

        if context == nil {
            textView.text = ""
            textView.textColor = .blackColor()
        }

        return true
    }

    func textViewDidChange(textView: UITextView) {
        let text = textView.text
        context = text != nil && text != "" ? text : nil
    }

}