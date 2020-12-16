//
//  ContentView.swift
//  QRcoder - QR-Code Generator
//  Copyright (C) 2020 Jahn Bertsch
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

//  Based on https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code

import SwiftUI

struct ContentView: View {
    @State fileprivate var qrText = "Enter QR-Code content here and press \"Generate\" button"
    @State fileprivate var qrImage = UIImage()
    
    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            TextEditor(text: $qrText)
                .border(Color.gray)
                .padding()
                .onTapGesture {
                    qrText = ""
                }
            
            Button("Generate QR-Code") {
                generateQrCode()
            }
            
            Image(uiImage: qrImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.white)
                .padding()
        })
    }
    
    fileprivate func generateQrCode() {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 200, height: 320))
    }
}
