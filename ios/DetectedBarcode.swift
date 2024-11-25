//
//  DetectedBarcode.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

public struct DetectedBarcode: Identifiable {
    public let id: String
    var boundingBox: CGRect
    let payload: String
}
