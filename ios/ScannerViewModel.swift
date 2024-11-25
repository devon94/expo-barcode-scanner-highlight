//
//  ScannerViewModel.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import SwiftUI
import AVFoundation
import Vision

public class ScannerViewModel: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionReady = false
    @Published var scannedText = ""
    @Published var detectedBarcodes: [DetectedBarcode] = []
    @Published var isScanning = true

    public var captureSession: AVCaptureSession?
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated)
    private var clearTextTimer: Timer?
        
    private var detectedBarcodesDict: [String: DetectedBarcode] = [:]
    private var lastSeenTimestamps: [String: Date] = [:]
    private let staleThreshold: TimeInterval = 0.5
    
    private func cleanStaleBoxes(currentTime: Date) {
        lastSeenTimestamps.forEach { id, timestamp in
            if currentTime.timeIntervalSince(timestamp) > staleThreshold {
                lastSeenTimestamps.removeValue(forKey: id)
                detectedBarcodesDict.removeValue(forKey: id)
                detectedBarcodes = Array(detectedBarcodesDict.values)
            }
        }
    }
    
    
    override init() {
        super.init()
    }
    
    func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.setupCaptureSession()
                }
            }
        }
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
            return
        }
        
        session.addInput(videoDeviceInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        session.commitConfiguration()
        self.captureSession = session
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionReady = true
            }
        }
    }
    
    func handleBarcodeTap(_ barcode: DetectedBarcode) {
        DispatchQueue.main.async {
            self.scannedText = barcode.payload
            self.clearTextTimer?.invalidate()
            self.clearTextTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                self?.scannedText = ""
            }
        }
    }
}

// Extension to handle video frame processing
extension ScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let observations = request.results as? [VNBarcodeObservation] else { return }
            let currentTime = Date()
            
            DispatchQueue.main.async {
                for observation in observations {
                    if let payload = observation.payloadStringValue {
                        self?.lastSeenTimestamps[payload] = currentTime
                        if (self?.detectedBarcodesDict[payload] != nil) {
                            self?.detectedBarcodesDict[payload]?.boundingBox = observation.boundingBox
                        } else {
                            self?.detectedBarcodesDict[payload] = DetectedBarcode(
                                id: payload,
                                boundingBox: observation.boundingBox,
                                payload: payload
                            )
                        }

                        
                        if let strongSelf = self {
                            strongSelf.detectedBarcodes = Array(strongSelf.detectedBarcodesDict.values)
                        }
                    }
                }
                self?.cleanStaleBoxes(currentTime: currentTime)
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            .perform([request])
    }
}
