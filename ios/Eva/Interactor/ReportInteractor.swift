//
//  ReportInteractor.swift
//  Eva
//
//  Created by Francisco Díaz on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit
import LocalAuthentication

internal protocol ReportInteractorType {
    func createReport(withLatitude latitude: Double, longitude: Double,
        onSuccess: (reportId: Int) -> Void, onFailure: NSError -> Void)
    func cancelLastReport(onSuccess: () -> Void, onFailure: NSError -> Void)
    func linkImage(toReportId reportId: Int, image: UIImage, onSuccess: () -> Void, onFailure: NSError -> Void)
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, onSuccess: () -> Void, onFailure: NSError -> Void)
}

internal struct ReportInteractor: ReportInteractorType {
    private struct Constants {
        static let compressionQuality: CGFloat = 0.5
    }
    
    private let dataManager: ModelDataManager
    
    init(dataManager: ModelDataManager = ModelDataManager.defaultManager()) {
        self.dataManager = dataManager
    }
    
    func createReport(withLatitude latitude: Double, longitude: Double, onSuccess: (reportId: Int) -> Void, onFailure: NSError -> Void) {
        guard let userId = Persistence.userId() else { onFailure(NSError.authError()); return }
        dataManager.createReport(withUserId: userId, latitude: latitude, longitude: longitude) { result in
            switch result {
            case .Success(let dictionary):
                guard let reportId = dictionary["id"] as? Int else { onFailure(NSError.parsingError()); return }
                onSuccess(reportId: reportId)
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func cancelLastReport(onSuccess: () -> Void, onFailure: NSError -> Void) {
        dataManager.cancelLastReport { result in
            switch result {
            case .Success(_):
                onSuccess()
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func linkImage(toReportId reportId: Int, image: UIImage, onSuccess: () -> Void, onFailure: NSError -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, Constants.compressionQuality) else {
            onFailure(NSError.imageProcessingError())
            return
        }
        dataManager.linkImage(toReportId: reportId, imageData: imageData) { result in
            switch result {
            case .Success(_):
                onSuccess()
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
    
    func linkLocation(toReportId reportId: Int, latitude: Double, longitude: Double, onSuccess: () -> Void, onFailure: NSError -> Void) {
        dataManager.linkLocation(toReportId: reportId, latitude: latitude, longitude: longitude) { result in
            switch result {
            case .Success(_):
                onSuccess()
            case .Failure(let error):
                onFailure(error)
            }
        }
    }
}
