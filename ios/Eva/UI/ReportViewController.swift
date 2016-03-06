
import UIKit
import CoreLocation
import LocalAuthentication

internal final class ReportViewController : UIViewController {
    
    @IBOutlet private var helpButton: UIButton! {
        didSet {
            helpButton.addDefaultMotionEffect()
        }
    }
    private let motionController = MotionController()
    private let locationController: LocationController
    private let interactor: ReportInteractorType
    private var reporting: Bool {
        set {
            Persistence.reporting = newValue
        }
        get {
            return Persistence.reporting
        }
    }
    private var cameraStreamer: CameraStreamer!
    private var reportId: Int?
    
    required init(interactor: ReportInteractorType = ReportInteractor()) {
        self.interactor = interactor
        self.locationController = LocationController { _ in }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.report
        title = ""
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem.profileItem(target: self, action: "openAccount")
        cameraStreamer = CameraStreamer { image in
            guard let image = image, reportId = self.reportId where self.reporting else { return }
            self.interactor.linkImage(toReportId: reportId, image: image, onSuccess: {}, onFailure: { _ in })
        }
        locationController.updateLocationHandler = { location in
            self.updateReportWithLocation(location)
        }
        motionController.motionAlertHandler = {
            guard !self.reporting else { return }
            self.reporting = true
            self.startReporting()
        }
        
        guard reporting else { return }
        startReporting()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        registerNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cameraStreamer.stop()
        unregisterNotifications()
    }
    
    @IBAction func handleRequest() {
        reporting ? stopReporting() : startReporting()
    }
    
    private func startReporting() {
        reporting = true
        updateHelpButton(true)
        
        do {
            try cameraStreamer.start()
        } catch { }
        
        let coordinate = locationController.currentLocation.coordinate
        interactor.createReport(withLatitude: coordinate.latitude, longitude: coordinate.longitude,
            onSuccess: { reportId in
                self.reportId = reportId
            }) { error in
                
        }
    }
    
    private func requireAuthenticationToStop(reply: (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        //TODO: Define a better copy
        let reason = "We have to be sure you are right"
        let policy = LAPolicy.DeviceOwnerAuthenticationWithBiometrics
        guard context.canEvaluatePolicy(policy, error: &error) else {
            reply(false)
            return
        }
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            reply(success)
        }

    }
    
    private func updateReportWithLocation(location: CLLocation) {
        guard let reportId = reportId where reporting else { return }
        let coordinate = location.coordinate
        interactor.linkLocation(toReportId: reportId, latitude: coordinate.latitude, longitude: coordinate.longitude, onSuccess: {}, onFailure: { _ in })
    }
    
    private func stopReporting() {
        if Platform.isSimulator {
            performStop()
        } else {
            requireAuthenticationToStop { success in
                guard success else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    self.performStop()
                }
            }
        }
    }

    private func performStop() {
        reporting = false
        updateHelpButton(false)
        cameraStreamer.stop()
        reportId = nil
        interactor.cancelLastReport({ }, onFailure: { _ in })
    }

    func updateHelpButton(reporting: Bool, animated: Bool = true) {
        let title = reporting ? "I'm OK" : "HELP"
        helpButton.setTitle(title, forState: .Normal)
        let normal = UIImage(named: reporting ? "ok-up" : "help-up")
        let selected = UIImage(named: reporting ? "ok-down" : "help-down")
        helpButton.setBackgroundImage(normal, forState: .Normal)
        helpButton.setBackgroundImage(selected, forState: .Highlighted)
        view.backgroundColor = Color.report
        navigationController?.navigationBar.barTintColor = Color.report
        Theme.setDefaultTheme()
        guard animated else { return }
        let transition = CATransition()
        transition.type = kCATransitionFade
        //transition.subtype = reporting ? kCATransitionFromLeft : kCATransitionFromRight
        transition.duration = 0.2
        view.window?.layer.addAnimation(transition, forKey: "asd")
    }
    
    func openAccount() {
        let controller = UINavigationController(rootViewController: AccountViewController())
        controller.modalPresentationStyle = .Custom
        controller.transitioningDelegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    private dynamic func becomeActive() {
        updateHelpButton(Persistence.reporting, animated: false)
    }
    
    private func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func unregisterNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ReportViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MaskTransition(presenting: true, position: navigationItem.rightBarButtonItem?.position ?? CGPoint.zero)
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MaskTransition(presenting: false, position: navigationItem.rightBarButtonItem?.position ?? CGPoint.zero)
    }
}
