//
//  CameraViewWithOverlay.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//


import SwiftUI
import AVFoundation
import Vision

public struct CameraViewWithOverlay: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    @State private var showHighlight: Bool = true
    var onBarcodeTapped: ((DetectedBarcode) -> Void)?
    var onBarcodesDetected: (([String: Any]) -> Void)?

    public init() { }
    
    public mutating func setonBarcodesDetected(_ onBarcodesDetected: (([String: Any]) -> Void)?) {
        self.onBarcodesDetected = onBarcodesDetected
    }
    
    public mutating func setOnBarcodeTapped(_ onBarcodeTapped: ((DetectedBarcode) -> Void)?) {
        self.onBarcodeTapped = onBarcodeTapped
    }

    public mutating func setShowHighlight(_ showHighlight: Bool) {
        self.showHighlight = showHighlight
    }



    public var body: some View {
        ZStack {
            CameraView(scannerViewModel: scannerViewModel)
                .edgesIgnoringSafeArea(.all)
            
            if !scannerViewModel.detectedBarcodesDict.isEmpty && showHighlight {
                BarcodeOverlayView(
                    detectedBarcodesDict: scannerViewModel.detectedBarcodesDict,
                    onBarcodeTapped: { barcode in
                        scannerViewModel.onBarcodeTappedInternal(barcode)
                        onBarcodeTapped?(barcode)
                    }
                )
                .edgesIgnoringSafeArea(.all)
            }
            
            if !scannerViewModel.scannedText.isEmpty {
                VStack {
                    Spacer()
                    Text(scannerViewModel.scannedText)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            scannerViewModel.setonBarcodesDetected(onBarcodesDetected)
            scannerViewModel.requestCameraAccess()
        }

    }
}
