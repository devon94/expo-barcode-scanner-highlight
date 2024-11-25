//
//  BarcodeBoxView.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

public struct BarcodeBoxView: View {
    let barcode: DetectedBarcode
    let geometry: GeometryProxy

    public var body: some View {
        let baseRect = CGRect(
            x: barcode.boundingBox.minX * geometry.size.width,
            y: (1 - barcode.boundingBox.maxY) * geometry.size.height,
            width: barcode.boundingBox.width * geometry.size.width,
            height: barcode.boundingBox.height * geometry.size.height
        )
        
        let paddedRect = baseRect.insetBy(dx: -16, dy: -16)
        
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.yellow, lineWidth: 2)
                .frame(
                    width: paddedRect.width,
                    height: paddedRect.height
                )
                .position(
                    x: paddedRect.midX,
                    y: paddedRect.midY
                )
                .background(Color.clear)
            
            // Debug overlay
            Color.yellow.opacity(0.2)
                .frame(
                    width: paddedRect.width,
                    height: paddedRect.height
                )
                .position(
                    x: paddedRect.midX,
                    y: paddedRect.midY
                )
        }
    }
}
