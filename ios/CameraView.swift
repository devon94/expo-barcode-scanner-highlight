//
//  CameraView.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

public struct CameraView: UIViewRepresentable {
    @ObservedObject var scannerViewModel: ScannerViewModel
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .black
        
        if scannerViewModel.isSessionReady,
           let session = scannerViewModel.captureSession {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        if scannerViewModel.isSessionReady,
           let session = scannerViewModel.captureSession {
            if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = uiView.bounds
            } else {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = uiView.bounds
                uiView.layer.addSublayer(previewLayer)
            }
        }
    }
}
