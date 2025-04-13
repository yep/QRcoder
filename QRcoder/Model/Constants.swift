//
//  ContentView.swift
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
import NotificationCenter

struct Constants {
    static var iconSize: CGFloat {
        get {
            #if targetEnvironment(macCatalyst)
            return 30
            #else
            return 20
            #endif
        }
    }
}

extension NSNotification.Name {
    static let didChangeCamera = NSNotification.Name("didChangeCamera")
    static let didDetectQRCode = NSNotification.Name("didDetectQRCode")
}


