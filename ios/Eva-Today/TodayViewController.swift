//
//  TodayViewController.swift
//  Eva-Today
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

internal final class TodayViewController: UIViewController {
    struct Constants {
        static let defaultHeight: CGFloat = 200 //Make it match with the storyboard
        static let evaURLString = "eva-emergency://today/emergency/"
    }
    
    @IBOutlet private weak var helpButton: EmergencyButton!
    private var reportInteractor: ReportInteractor!
    private var locationController: LocationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize.height = Constants.defaultHeight
        reportInteractor = ReportInteractor()
        locationController = LocationController { _ in }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateHelpButton(Persistence.reporting, animated: false)
    }
    
    @IBAction private func didPressEmergencyButton(sender: UIButton) {
        Persistence.reporting ? stopReporting() : startReporting()

    }
    
    private func startReporting() {
        guard let url = NSURL(string: Constants.evaURLString) else { return }
        updateHelpButton(true)
        let lastLocation = locationController.currentLocation
        reportInteractor.createReport(withLatitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude,
            onSuccess: { _ in
                Persistence.reporting = true
                self.extensionContext?.openURL(url, completionHandler: nil)
            }, onFailure: { _ in })
    }
    
    private func stopReporting() {
        guard let url = NSURL(string: Constants.evaURLString) else { return }
        extensionContext?.openURL(url, completionHandler: nil)
    }
    
    func updateHelpButton(reporting: Bool, animated: Bool = true) {
        helpButton.backgroundColor = reporting ? Color.okColor : Color.helpColor
        let title = reporting ? "I'm ok" : "HELP"
        helpButton.setTitle(title, forState: .Normal)
        
        guard animated else { return }
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = reporting ? kCATransitionFromLeft : kCATransitionFromRight
        transition.duration = 0.2
        helpButton.layer.addAnimation(transition, forKey: "asd")
    }
    
    
}

extension TodayViewController: NCWidgetProviding {
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        updateHelpButton(Persistence.reporting, animated: false)
        completionHandler(NCUpdateResult.NewData)
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
}