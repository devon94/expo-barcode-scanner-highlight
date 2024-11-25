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
    var onBarcodeDetected: ((DetectedBarcode) -> Void)?
    var onBarcodeTapped: ((DetectedBarcode) -> Void)?
    
    public init() { }
    
    public mutating func setOnBarcodeDetected(_ onBarcodeDetected: ((DetectedBarcode) -> Void)?) {
        self.onBarcodeDetected = onBarcodeDetected
    }
    
    public mutating func setOnBarcodeTapped(_ onBarcodeTapped: ((DetectedBarcode) -> Void)?) {
        self.onBarcodeTapped = onBarcodeTapped
    }

    public var body: some View {
        ZStack {
            CameraView(scannerViewModel: scannerViewModel)
                .edgesIgnoringSafeArea(.all)
            
            if !scannerViewModel.detectedBarcodes.isEmpty {
                BarcodeOverlayView(
                    detectedBarcodes: scannerViewModel.detectedBarcodes,
                    onBarcodeTap: { barcode in
                        scannerViewModel.handleBarcodeTap(barcode)
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
            scannerViewModel.requestCameraAccess()
        }

    }
}
