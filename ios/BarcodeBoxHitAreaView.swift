//
//  BarcodeBoxHitAreaView.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeBoxHitAreaView: View {
    let geometry: GeometryProxy
    let barcodes: [(key: String, value: DetectedBarcode)]
    let onTap: (DetectedBarcode) -> Void
    let enableDebugging: Bool
    
    func getRect(for barcode: DetectedBarcode) -> CGRect {
        let baseRect = CGRect(
            x: barcode.boundingBox.minX * geometry.size.width,
            y: (1 - barcode.boundingBox.maxY) * geometry.size.height,
            width: barcode.boundingBox.width * geometry.size.width,
            height: barcode.boundingBox.height * geometry.size.height
        )
        return baseRect.insetBy(dx: -24, dy: -24)
    }
    
    public var body: some View {
        ForEach(barcodes, id: \.key) { key, barcode in
            let rect = getRect(for: barcode)
            ZStack {
                // Visual box
                BarcodeBoxView(barcode: barcode, geometry: geometry)
                    .allowsHitTesting(false)
                
                // Hit test area
                Rectangle()
                    .fill(enableDebugging ? Color.yellow.opacity(0.1) : Color.clear)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .onTapGesture {
                        if enableDebugging {
                            print("Tapped barcode: \(barcode.payload)")
                            print("Rect: \(rect)")
                        }
                        onTap(barcode)
                    }
                    .overlay(
                        Group {
                            if enableDebugging {
                                Text(barcode.payload)
                                    .font(.system(size: 10))
                                    .foregroundColor(.red)
                                    .background(Color.black.opacity(0.5))
                                    .position(x: rect.width/2, y: 10)
                            }
                        }
                    )
            }
        }
    }
}