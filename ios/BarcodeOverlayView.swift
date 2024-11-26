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
    private var enableDebugging: Bool = false
    let detectedBarcodesDict: Dictionary<String, DetectedBarcode>
    let onBarcodeTapped: (DetectedBarcode) -> Void
    
    public init(
        detectedBarcodesDict: Dictionary<String, DetectedBarcode>,
        onBarcodeTapped: @escaping (DetectedBarcode) -> Void
    ) {
        self.detectedBarcodesDict = detectedBarcodesDict
        self.onBarcodeTapped = onBarcodeTapped
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                BarcodeBoxesView(
                    geometry: geometry,
                    barcodes: Array(detectedBarcodesDict),
                    onTap: onBarcodeTapped
                )
                
                if enableDebugging {
                    VStack(alignment: .leading) {
                        Text("Barcodes in view:")
                            .foregroundColor(.yellow)
                        ForEach(Array(detectedBarcodesDict), id: \.key) { key, barcode in
                            Text("\(key): \(barcode.payload)")
                                .foregroundColor(.yellow)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding()
                }
            }
        }
    }
}
