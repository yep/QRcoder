//
//  ContentView.swift
//  QRcoder - QR-Code Generator
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

struct ContentView: View {
    @State var viewModel = ContentViewModel()
    @FocusState var textEditorFocused

    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            TextEditor(text: $viewModel.qrText)
                .border(.gray)
                .padding()
                .focused($textEditorFocused)
                .onChange(of: textEditorFocused) { _ in
                    viewModel.clearDefaultText()
                }
                .onChange(of: viewModel.qrText, perform: { newValue in
                    viewModel.generateQrCode()
                })
            
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
                    Image(systemName: "square.and.arrow.up").font(.system(size: 30))
                }
                .keyboardShortcut("s", modifiers: .command)
                .sheet(isPresented: $viewModel.shareSheetPresented, content: {
                    ShareSheet(activityItems: [viewModel.qrImageUrl])
                })
                
                Button {
                    resignFirstResponder()
                    viewModel.copyToClipboard()
                    viewModel.alertShown = true
                } label: {
                    Image(systemName: "document.on.document").font(.system(size: 30))
                }
                .keyboardShortcut("c", modifiers: .command)
                .padding(.leading, 30)
                
                Spacer()
            }
            
            Image(uiImage: viewModel.qrImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.white)
                .padding()
        })
        .alert("Copied QR code image to clipboard", isPresented: $viewModel.alertShown) {
            Button("OK", role: .cancel) {
                viewModel.alertShown = false
            }
        }
        .onAppear {
            viewModel.generateQrCode()
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
