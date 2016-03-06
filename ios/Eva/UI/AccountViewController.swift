
import UIKit
import SafariServices

class AccountViewController : UIViewController {
    struct Constants {
        static let cellReuseIdentifier = "cell"
        static let headerReuseIdentifier = "header"
        static let aboutURL = NSURL(string: "http://endingviolence.org/")!
    }
    
    enum AccountItem: String {
        case name = "Name"
        case situation = "Situation"
        case photos = "Photos"
        case privacy = "Privacy Policy"
        case tos = "Terms of Service"
        case about = "About"
        case signout = "Sign Out"
    }

    private let interactor: ProfileInteractorType

    private var name: String? {
        didSet {
            let displayName = (name ?? "").isEmpty ? "Set your name here" : name!
            let displayInitials = (name ?? "").isEmpty ? "NN" : nameInitials(name)
            nameButton.setTitle(displayName, forState: .Normal)
            avatarButton.setTitle(displayInitials, forState: .Normal)
        }
    }
    
    private var context: String?

    @IBOutlet private weak var avatarButton: UIButton! {
        didSet {
            avatarButton.layer.cornerRadius = avatarButton.bounds.midY
            avatarButton.layer.masksToBounds = true
        }
    }
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet private var tableViewHeader: UIView!
    
    let dataSource: [[AccountItem]] = [[.situation, .photos], [.about, .privacy, .tos, .signout]]

    required init(interactor: ProfileInteractorType = ProfileInteractor()) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
        tableView.tableHeaderView = tableViewHeader
        navigationItem.rightBarButtonItem = UIBarButtonItem.closeItem(target: self, action: "dismiss")
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: Constants.cellReuseIdentifier)
        let color = Color.report
        nameButton.setTitleColor(color, forState: .Normal)
        nameButton.setTitleColor(color.darkerColor(), forState: .Highlighted)
        getProfile()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        deselect()
    }
    
    @IBAction private dynamic func didPressAvatarButton() {
        addPhoto()
    }
    
    private func getProfile() {
        interactor.getUser({ user, urls in
                self.name = user.name
                self.context = user.context
                self.handleAvatar(user.avatarURL)
            }, onFailure: { _ in
        })
    }
    
    private dynamic func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    private func openPhotos() {
        navigationController?.pushViewController(PhotosViewController(), animated: true)
    }

    private func openAbout() {
        let controller = SFSafariViewController(URL: Constants.aboutURL)
        presentViewController(controller, animated: true, completion: nil)
    }


    private func openContext() {
        let controller = ContextViewController(context: context)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction private func openName() {

        let controller = UIAlertController(title: "What's your name?", message: nil, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
            guard let name = controller.textFields?.first?.text where name != self.name else { return }
            self.interactor.updateProfile(withName: name, context: self.context,
                onSuccess: self.handleResponse, onFailure: self.showError)

        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        controller.addTextFieldWithConfigurationHandler { textField in
            textField.text = self.name
            textField.autocapitalizationType = .Words
        }
        presentViewController(controller, animated: true, completion: nil)
    }

    func handleResponse(name: String?, context: String?) {
        self.name = name
        self.context = context
    }
    
    func handleAvatar(URL: NSURL?) {
        guard let URL = URL else { return }
        avatarButton.setSecureImage(withURL: URL) { response in
            switch response.result {
            case .Success(_):
                self.avatarButton.setTitle("", forState: .Normal)
            case .Failure(_):
                self.avatarButton.setTitle(self.nameInitials(self.name), forState: .Normal)
            }
        }
    }

    func showError(error: NSError) {
        let controller = UIAlertController.controllerWithTitle("Error",
            message: "Failed to update: \(error.localizedDescription)")
        presentViewController(controller, animated: true, completion: nil)
    }

    func performSignout() {
        interactor.signout()

        if let navigationController = presentingViewController as? UINavigationController {
            dismissViewControllerAnimated(true) {
                let signupController = SignupViewController()
                navigationController.setViewControllers([signupController], animated: true)
            }
        }
    }

    func deselect() {
        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRowAtIndexPath($0, animated: true)
        }
    }

    func iconAtIndexPath(indexPath: NSIndexPath) -> UIImage? {
        let item = dataSource[indexPath.section][indexPath.item]
        switch item {
        case .situation: return UIImage(named: "file.icon")
        case .photos: return UIImage(named: "photos.icon")
        default: return nil
        }
    }
    
    func labelAtIndexPath(indexPath: NSIndexPath) -> String {
        return dataSource[indexPath.section][indexPath.item].rawValue
    }

    func accessoryTypeAtIndexPath(indexPath: NSIndexPath) -> UITableViewCellAccessoryType {
        if indexPath.section == 0 {
            return .DisclosureIndicator
        } else {
            return .None
        }
    }
    
    func nameInitials(name: String? ) -> String {
        guard let name = name else { return "NN" }
        let allInitial = name.componentsSeparatedByString(" ")
            .flatMap { $0.characters.first }
            .flatMap { String($0).uppercaseString }
        let initials = allInitial[0..<min(allInitial.count, 2)]
        return initials.isEmpty ? "NN" : initials.reduce("", combine: +)
    }

    func addPhoto() {
        let actions: [String: UIImagePickerControllerSourceType] = [
            "Photo Library": .PhotoLibrary,
            "Take Photo": .Camera,
        ]
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        for (title, type) in actions {
            if UIImagePickerController.isSourceTypeAvailable(type) {
                let action = UIAlertAction(title: title, style: .Default) { _ in
                    self.openImagePicker(withSourceType: type)
                }
                alert.addAction(action)
            }
        }
        
        let action = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func openImagePicker(withSourceType type: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.sourceType = type
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }

}


// MARK: UITableViewDataSource

extension AccountViewController : UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier,
            forIndexPath: indexPath)
        cell.textLabel?.text = labelAtIndexPath(indexPath)
        cell.accessoryType = accessoryTypeAtIndexPath(indexPath)
        cell.imageView?.image = iconAtIndexPath(indexPath)
        return cell
    }
}


// MARK: UITableViewDelegate

extension AccountViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = dataSource[indexPath.section][indexPath.item]
        switch item {
        case .name: openName()
        case .photos: openPhotos()
        case .situation: openContext()
        case .signout: performSignout()
        case .about: openAbout()
        default: break
        }
    }
}

// MARK: ContextViewControllerDelegate

extension AccountViewController: ContextViewControllerDelegate {
    func contextViewControllerDidFinish(controller: ContextViewController, withContext context: String?) {
        guard self.context != context else { return }
        self.context = context
        interactor.updateProfile(withName: name, context: context, onSuccess: handleResponse, onFailure: showError)
    }
}


extension AccountViewController : UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
            picker.dismissViewControllerAnimated(true, completion: nil)

            interactor.uploadAvatarImage(image, onSuccess: handleAvatar, onFailure: showError)
    }
}

extension AccountViewController : UINavigationControllerDelegate {}

