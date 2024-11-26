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


extension DetectedBarcode {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "boundingBox": [
                "x": boundingBox.origin.x,
                "y": boundingBox.origin.y,
                "width": boundingBox.size.width,
                "height": boundingBox.size.height
            ],
            "payload": payload
        ]
    }
}