//
//  ScanView.swift
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

import SwiftUI
import AVFoundation

struct ScanView: View {
    @State var detectedQRCode: String?
    @State var alertShown = false
    
    fileprivate let QRCodePublisher = NotificationCenter.default.publisher(for: .didDetectQRCode)
    
    fileprivate var cameraButton: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading) {
                Button {
                    NotificationCenter.default.post(name: .didChangeCamera, object: nil)
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera")
                    .font(.system(size: 20))
                }
                .padding()
                .background(.background)
                .opacity(0.8)
                .cornerRadius(8)
                .padding()
                
                Spacer()
            }
        }
    }
    
    fileprivate var qrCodeOverlay: some View {
        VStack {
            Spacer()
            VStack {
                Text(detectedQRCode ?? "")
                    .padding(.bottom, 5)
                Button {
                    alertShown = true
                    UIPasteboard.general.string = detectedQRCode
                } label: {
                    Image(systemName: "document.on.document").font(.system(size: Constants.iconSize))
                }
                .keyboardShortcut("c", modifiers: .command)
            }
            .padding()
            .background(.background)
            .opacity(0.8)
            .cornerRadius(8)
            .padding()
        }
    }
    
    fileprivate var permissionInfo: some View {
        VStack {
            Text("Please allow camera access in system settings to scan QR codes.")
                .foregroundColor(.secondary)
                .padding()
            
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            ScanViewContainer()
            
            #if !targetEnvironment(macCatalyst)
            cameraButton
            #endif
            
            if detectedQRCode != nil {
                qrCodeOverlay
            }
            
            if AVCaptureDevice.authorizationStatus(for: .video) == .denied ||
               AVCaptureDevice.authorizationStatus(for: .video) == .restricted
            {
                permissionInfo
            }
        }
        .onAppear() {
            detectedQRCode = nil
        }
        .onReceive(QRCodePublisher) { notification in
            print(notification)
            if let notificationObject = notification.object,
               let detectedQRCode = notificationObject as? String
            {
                self.detectedQRCode = detectedQRCode
            }
        }
        .alert(isPresented: $alertShown) {
            Alert(title: Text("Copied to clipboard"), message: Text(detectedQRCode ?? ""))
        }
    }
}

struct ScanViewContainer: UIViewControllerRepresentable {
    fileprivate let scanViewController = ScanViewController()

    func makeUIViewController(context: Context) -> some UIViewController {
         return scanViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview(traits: .fixedLayout(width: 200, height: 400)) {
    ScanView()
}
