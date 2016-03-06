//
//  CameraStreamer.swift
//  Eva
//
//  Created by Camilo Vera Bezmalinovic on 3/5/16.
//  Copyright © 2016 Axiom Zen. All rights reserved.
//

import UIKit
import AVFoundation

internal class CameraStreamer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var session:AVCaptureSession?
    private var input:AVCaptureDeviceInput!
    private var output:AVCaptureVideoDataOutput!
    private var camera:AVCaptureDevice!
    private var imageHandler: (UIImage?) -> Void
    private var streamingQueue = dispatch_queue_create("camera.streamer.queue", nil)
    var streamingInterval: NSTimeInterval = 10.0
    
    init(imageHandler: (UIImage?) -> Void) {
        self.imageHandler = imageHandler
        super.init()
    }
    
    func start() throws {
        guard self.session == nil else { return }
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        for caputureDevice: AnyObject in AVCaptureDevice.devices() {
            if caputureDevice.position == AVCaptureDevicePosition.Back {
                camera = caputureDevice as? AVCaptureDevice
            }
        }
        
        input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        
        
        if(session.canAddInput(input)) {
            session.addInput(input)
        }
        
        output = AVCaptureVideoDataOutput()
        
        if(session.canAddOutput(output)) {
            session.addOutput(output)
        }
        
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
        
        output.setSampleBufferDelegate(self, queue: streamingQueue)
        
        output.alwaysDiscardsLateVideoFrames = true
        
        session.startRunning()
        
        try camera.lockForConfiguration()
        camera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        camera.unlockForConfiguration()
        
        self.session = session
    }
    
    func stop() {
        guard let session = session else { return }
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        self.session = nil
        camera = nil
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let image = self.captureImage(sampleBuffer)
        dispatch_async(dispatch_get_main_queue()) {
            self.imageHandler(image)
        }
        NSThread.sleepForTimeInterval(streamingInterval)
    }
    
    private func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        guard let colorSpace = CGColorSpaceCreateDeviceRGB() else { return nil }
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let bitsPerCompornent:Int = 8
        let bitmapInfo = CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue
        
        guard let newContext = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo) else { return nil }
        guard let imageRef = CGBitmapContextCreateImage(newContext) else { return nil }
        
        return UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
    }
}