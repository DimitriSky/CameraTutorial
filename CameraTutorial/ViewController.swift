//
//  ViewController.swift
//  CameraTutorial
//
//  Created by Jameson Quave on 9/20/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?

    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh

        let devices = AVCaptureDevice.devices()

        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }

    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()

                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in })

                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO

                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in })

                device.unlockForConfiguration()
            } catch {
                print("can't lock the device")
            }
        }
    }

    func touchPercent(touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.mainScreen().bounds.size

        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPointZero

        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.locationInView(self.view).x / screenSize.width
        touchPer.y = touch.locationInView(self.view).y / screenSize.height

        // Return the populated CGPoint
        return touchPer
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchPer = touchPercent(touch)
            updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
        }
        super.touchesBegan(touches, withEvent:event)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let touchPer = touchPercent(touch)
            updateDeviceSettings(Float(touchPer.x), isoValue: Float(touchPer.y))
        }
        super.touchesBegan(touches, withEvent:event)
    }

    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .Locked
                device.unlockForConfiguration()
            } catch {
                print("can't lock the device")
            }
        }
    }

    func beginSession() {
        configureDevice()

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch let error as NSError {
            print("error: \(error)")
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
    }
    
}

