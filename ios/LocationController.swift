//
//  LocationController.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 AxiomZen. All rights reserved.
//

import Foundation
import CoreLocation

/*
 Add to Plist File: NSLocationAlwaysUsageDescription
 Set "Application does not run in background" to NO
 Add Location updates to Capabilities in background Mode
*/
internal final class LocationController: NSObject {
    let locationManager = CLLocationManager()
    private(set) var currentLocation = CLLocation(latitude: 0, longitude: 0)
    var updateLocationHandler: (CLLocation) -> Void
    init(updateHandler: (CLLocation) -> Void) {
        updateLocationHandler = updateHandler
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO: Set here the location to NSUSerDefaults using the right suitname
        guard let lastLocation = locations.last else { return }
        //NSUserDefaults.standardUserDefaults().setObject(lastLocation, forKey: "location")
        currentLocation = lastLocation
        updateLocationHandler(lastLocation)
    }
}
