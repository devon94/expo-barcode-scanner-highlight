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
    @ObservedObject var scannerViewModel: ScannerViewModel
    @State private var showHighlight: Bool = true

    public init(scannerViewModel: ScannerViewModel) {
        self.scannerViewModel = scannerViewModel
    }

    public var body: some View {
        ZStack {
            CameraView(scannerViewModel: scannerViewModel)
                .edgesIgnoringSafeArea(.all)
            
            if !scannerViewModel.detectedBarcodesDict.isEmpty && showHighlight {
                BarcodeOverlayView(
                    detectedBarcodesDict: scannerViewModel.detectedBarcodesDict,
                    onBarcodeTapped: { barcode in
                        scannerViewModel.onBarcodeTapped(barcode)
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
