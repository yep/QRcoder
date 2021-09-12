//
//  ContentView.swift
//  QRcoder - QR-Code Generator
//  Copyright (C) 2020-2021 Jahn Bertsch
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

struct ContentViewModel {
    fileprivate static let qrTextDefault = "Enter QR-Code content here"
    var qrText = qrTextDefault
    var qrImage = UIImage()
    var qrImageUrl = URL(fileURLWithPath: "")
    var shareSheetPresented = false
    
    mutating func onTapGesture() {
        if qrText == Self.qrTextDefault {
            qrText = ""
        }
    }
    
    mutating func generateQrCode() {
        // Based on https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
        let qrData = qrText.data(using: String.Encoding.utf8)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(qrData, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 100, y: 100)
            
            if let outputImage = filter.outputImage?.transformed(by: transform) {
                let context = CIContext()
                if let cgImgage = context.createCGImage(outputImage, from: outputImage.extent) {
                    qrImage = UIImage(cgImage: cgImgage)
                }
            }
        }
    }
    
    mutating func saveQrCode() {
        generateQrCode()
        
        let documentDirectoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        guard let pngData = qrImage.pngData(), let documentDirectoryPath = documentDirectoryPaths.first else {
            return
        }
        
        do {
            let documentDirectoryURL = URL(fileURLWithPath: documentDirectoryPath)
            let imageURL = documentDirectoryURL.appendingPathComponent("QRcode.png")
            try pngData.write(to: imageURL)
            qrImageUrl = imageURL
        } catch {
            // print("could not write png: \(error.localizedDescription)")
        }
    }
}
