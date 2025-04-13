//
//  GenerateView.swift
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

struct GenerateView: View {
    @State var viewModel = GenerateViewModel()
    @FocusState var textEditorFocused
    
    fileprivate var textEditor: some View {
        TextEditor(text: $viewModel.qrText)
            .border(.gray)
            .padding()
            .focused($textEditorFocused)
            .submitLabel(.done)
            .onChange(of: textEditorFocused) {
                viewModel.clearDefaultText()
            }
            .onChange(of: viewModel.qrText) { oldValue, newValue in
                if let last = newValue.last,
                   last == "\n"
                {
                    viewModel.qrText.removeLast()
                    resignFirstResponder()
                } else if let qrImage = viewModel.generateQrCode() {
                    viewModel.qrImage = qrImage
                }
            }
    }
    
    fileprivate var saveButton: some View {
        Button {
            resignFirstResponder()
            viewModel.saveQrCode()
            
            #if targetEnvironment(macCatalyst)
            presentDocumentPicker()
            #else
            viewModel.shareSheetPresented = true
            #endif
        } label: {
            Image(systemName: "square.and.arrow.up").font(.system(size: Constants.iconSize))
        }
        .keyboardShortcut("s", modifiers: .command)
        .sheet(isPresented: $viewModel.shareSheetPresented, content: {
            ShareSheet(activityItems: [viewModel.qrImageUrl])
        })
    }
    
    fileprivate var shareButton: some View {
        Button {
            resignFirstResponder()
            viewModel.copyToClipboard()
            viewModel.alertShown = true
        } label: {
            Image(systemName: "document.on.document").font(.system(size: Constants.iconSize))
        }
        .keyboardShortcut("c", modifiers: .command)
        .padding(.leading, Constants.iconSize)
    }

    fileprivate var qrCodeImage: some View {
        Image(uiImage: viewModel.qrImage)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .background(Color.white)
        .padding()
        .onTapGesture {
            viewModel.fullScreenCover = !viewModel.fullScreenCover
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            textEditor
            
            HStack {
                Spacer()
                saveButton
                shareButton
                Spacer()
            }
            
            qrCodeImage
        })
        .alert(isPresented: $viewModel.alertShown) {
            Alert(title: Text("Copied"), message: Text("QR code image copied to clipboard."))
        }
        .fullScreenCover(isPresented: $viewModel.fullScreenCover, content: {
            qrCodeImage
        })
        .onAppear {
            if let qrImage = viewModel.generateQrCode() {
                viewModel.qrImage = qrImage
            }
        }
        .onDisappear {
            viewModel.fullScreenCover = false
        }
    }
    
    fileprivate func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    fileprivate func presentDocumentPicker() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController
        {
            let documentPicker = UIDocumentPickerViewController(forExporting: [viewModel.qrImageUrl])
            rootViewController.present(documentPicker, animated: true)
        }
    }
}

#Preview(traits: .fixedLayout(width: 200, height: 400)) {
    GenerateView(viewModel: GenerateViewModel())
}

