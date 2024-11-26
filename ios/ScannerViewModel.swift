//
//  ScannerViewModel.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import AVFoundation
import SwiftUI
import Vision

public class ScannerViewModel: NSObject, ObservableObject {
    private var enableDebugging = false
    public var captureSession: AVCaptureSession?
    private var lastSeenTimestamps: [String: Date] = [:]
    private let staleThreshold: TimeInterval = 0.5
    private var clearTextTimer: Timer?
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated)
    private var onBarcodesDetected: (([String: Any]) -> Void)?
    private var previousBoundingBoxes: [String: CGRect] = [:]

    @Published var isAuthorized = false
    @Published var isSessionReady = false
    @Published var scannedText = ""
    @Published var isScanning = true
    @Published var detectedBarcodesDict: [String: DetectedBarcode] = [:]
    @Published var smoothingFactor: CGFloat = 0.1 // Adjust this value between 0 and 1

    override init() {
        super.init()
    }

    public func setonBarcodesDetected(
        _ onBarcodesDetected: (([String: Any]) -> Void)?
    ) {
        self.onBarcodesDetected = onBarcodesDetected
    }

    private func cleanStaleBoxes(currentTime: Date) {
        lastSeenTimestamps.forEach { id, timestamp in
            if currentTime.timeIntervalSince(timestamp) > staleThreshold {
                lastSeenTimestamps.removeValue(forKey: id)
                detectedBarcodesDict.removeValue(forKey: id)
            }
        }
    }

    public func toggleScanning() {
        isScanning.toggle()
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

        guard
            let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back),
            let videoDeviceInput = try? AVCaptureDeviceInput(
                device: videoDevice),
            session.canAddInput(videoDeviceInput)
        else {
            return
        }

        session.addInput(videoDeviceInput)

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(
            self, queue: videoDataOutputQueue)

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

    func onBarcodeTappedInternal(_ barcode: DetectedBarcode) {
        if enableDebugging {
            DispatchQueue.main.async {
                self.scannedText = barcode.payload
                self.clearTextTimer?.invalidate()
                self.clearTextTimer = Timer.scheduledTimer(
                    withTimeInterval: 3.0, repeats: false
                ) { [weak self] _ in
                    self?.scannedText = ""
                }
            }
        }
    }

    private func smoothBoundingBox(_ newBox: CGRect, previousBox: CGRect?) -> CGRect {
        guard let previous = previousBox else { return newBox }
        
        return CGRect(
            x: previous.origin.x + (newBox.origin.x - previous.origin.x) * smoothingFactor,
            y: previous.origin.y + (newBox.origin.y - previous.origin.y) * smoothingFactor,
            width: previous.width + (newBox.width - previous.width) * smoothingFactor,
            height: previous.height + (newBox.height - previous.height) * smoothingFactor
        )
    }
}

// Extension to handle video frame processing
extension ScannerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(
        _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard isScanning,
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let observations = request.results as? [VNBarcodeObservation]
            else { return }
            let currentTime = Date()

            DispatchQueue.main.async {
                if !observations.isEmpty {
                    for observation in observations {
                        if let payload = observation.payloadStringValue {
                            self?.lastSeenTimestamps[payload] = currentTime
                            
                            // Get the smoothed bounding box
                            let newBox = observation.boundingBox
                            let smoothedBox = self?.smoothBoundingBox(
                                newBox,
                                previousBox: self?.previousBoundingBoxes[payload]
                            ) ?? newBox
                            
                            // Update the previous box for next frame
                            self?.previousBoundingBoxes[payload] = smoothedBox
                            
                            // Update or create the detected barcode
                            if self?.detectedBarcodesDict[payload] != nil {
                                self?.detectedBarcodesDict[payload]?.boundingBox = smoothedBox
                            } else {
                                self?.detectedBarcodesDict[payload] = DetectedBarcode(
                                    id: payload,
                                    boundingBox: smoothedBox,
                                    payload: payload
                                )
                            }
                        }
                    }
                      

                    if (self?.enableDebugging) != nil
                        && self?.enableDebugging == true
                    {
                        print(
                            "onBarcodesDetected exists: \(self?.onBarcodesDetected != nil)"
                        )
                        print(
                            self?.detectedBarcodesDict.values.map {
                                $0.dictionary
                            } ?? [])
                    }

                    self?.onBarcodesDetected?([
                        "barcodes":
                            (self?.detectedBarcodesDict.values.map {
                                $0.dictionary
                            }) ?? []
                    ])
                }

                self?.cleanStaleBoxes(currentTime: currentTime)
            }
        }

        try? VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]
        )
        .perform([request])
    }
}
