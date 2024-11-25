//
//  BarcodeOverlayView.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

public struct BarcodeOverlayView: View {
    let detectedBarcodes: [DetectedBarcode]
    let onBarcodeTap: (DetectedBarcode) -> Void
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(detectedBarcodes) { barcode in
                    Button(action: {
                        print("Button tapped for barcode: \(barcode.payload)")
                        onBarcodeTap(barcode)
                    }) {
                        BarcodeBoxView(barcode: barcode, geometry: geometry)
                            .contentShape(Rectangle()) // Forces hit testing on entire area
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        print("Tap gesture triggered for barcode: \(barcode.payload)")
                    }
                }
            }
            .onChange(of: geometry.size) { size in
                print("Overlay size changed to: \(size)")
            }
        }
    }
}
