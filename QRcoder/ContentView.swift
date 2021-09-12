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

struct ContentView: View {
    @State var viewModel = ContentViewModel()

    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            TextEditor(text: $viewModel.qrText)
                .border(Color.gray)
                .padding()
                .onChange(of: viewModel.qrText, perform: { newValue in
                    viewModel.generateQrCode()
                })
                .onTapGesture {
                    viewModel.onTapGesture()
                }
            
            HStack {
                Spacer()
                Button {
                    resignFirstResponder()
                    viewModel.saveQrCode()
                    
                    #if targetEnvironment(macCatalyst)
                    presentDocumentPicker()
                    #else
                    viewModel.shareSheetPresented = true
                    #endif
                } label: {
                    #if targetEnvironment(macCatalyst)
                    Text("Save QR-Code")
                    #else
                    Image(systemName: "square.and.arrow.up")
                    #endif
                }
                .sheet(isPresented: $viewModel.shareSheetPresented, content: {
                    ShareSheet(activityItems: [viewModel.qrImageUrl])
                })
                Spacer()
            }
            
            Image(uiImage: viewModel.qrImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.white)
                .padding()
        })
        .onAppear {
            viewModel.generateQrCode()
        }
        .onTapGesture {
            resignFirstResponder()
        }
    }
    
    fileprivate func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    fileprivate func presentDocumentPicker() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            let documentPicker = UIDocumentPickerViewController(forExporting: [viewModel.qrImageUrl])
            rootViewController.present(documentPicker, animated: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 200, height: 320))
    }
}
