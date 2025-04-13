//
//  ScanViewController.swift
//  QRcoder - QR code Generator
//  Copyright (C) 2020-2025 Jahn Bertsch
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import AVFoundation

final class ScanViewController: UIViewController {
    fileprivate let session = AVCaptureSession()
    fileprivate var inputDevice: AVCaptureDeviceInput?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate var position: AVCaptureDevice.Position = .front
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeCamera), name: .didChangeCamera, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.setupCapture()
                }
            }
        }
    }
    
    @objc func didChangeCamera() {
        if position == .front {
            position = .back
        } else {
            position = .front
        }
        
        setupCapture()
    }

    fileprivate func setupCapture() {
        if let inputDevice {
            session.removeInput(inputDevice)
        }
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized,
           let captureDevice = captureDevice(),
           let inputDevice = try? AVCaptureDeviceInput(device: captureDevice)
        {
            session.addInput(inputDevice)
            self.inputDevice = inputDevice
            
            if session.outputs.isEmpty {
                let metadataOutput = AVCaptureMetadataOutput()
                self.session.addOutput(metadataOutput)
                if metadataOutput.availableMetadataObjectTypes.contains(.qr) {
                    metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                    metadataOutput.metadataObjectTypes = [.qr]
                }
            }
            
            if previewLayer == nil {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = view.layer.bounds
                view.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer
            }
                        
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    fileprivate func captureDevice() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: position) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            return device
        } else {
            return nil
        }
    }
}

extension ScanViewController:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == .qr
        {
            NotificationCenter.default.post(name: .didDetectQRCode, object: metadataObject.stringValue)
        }
    }
}
