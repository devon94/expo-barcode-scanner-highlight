//
//  CameraView.swift
//  expo-barcode-scanner-highlight
//
//  Created by Devon Deonarine on 2024-11-25.
//

import AVFoundation
import SwiftUI
import Vision

public class CameraPreviewView: UIView {
    var session: AVCaptureSession?
    weak var focusDelegate: FocusDelegate?
}

protocol FocusDelegate: AnyObject {
    func handleFocus(at point: CGPoint)
}

public struct CameraView: UIViewRepresentable {
    @ObservedObject var scannerViewModel: ScannerViewModel

    public func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView(frame: CGRect.zero)
        view.backgroundColor = .black
        view.focusDelegate = context.coordinator

        if scannerViewModel.isSessionReady,
            let session = scannerViewModel.captureSession
        {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
            view.session = session

            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap(_:)))
            view.addGestureRecognizer(tapGesture)
        }

        return view
    }

    public func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if scannerViewModel.isSessionReady,
            let session = scannerViewModel.captureSession
        {
            if let previewLayer = uiView.layer.sublayers?.first
                as? AVCaptureVideoPreviewLayer
            {
                previewLayer.frame = uiView.bounds
            } else {
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = uiView.bounds
                uiView.layer.addSublayer(previewLayer)
            }
            uiView.session = session
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, FocusDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let view = gesture.view as? CameraPreviewView else { return }
            let point = gesture.location(in: view)
            handleFocus(at: point)
        }

        func handleFocus(at point: CGPoint) {
            guard
                let deviceInput = parent.scannerViewModel.captureSession?.inputs
                    .first as? AVCaptureDeviceInput
            else { return }

            let device = deviceInput.device

            do {
                try device.lockForConfiguration()

                if device.isFocusPointOfInterestSupported
                    && device.isFocusModeSupported(.autoFocus)
                {
                    let focusPoint = CGPoint(
                        x: point.x / UIScreen.main.bounds.width,
                        y: point.y / UIScreen.main.bounds.height)
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .autoFocus
                }

                if device.isExposurePointOfInterestSupported
                    && device.isExposureModeSupported(.autoExpose)
                {
                    let exposurePoint = CGPoint(
                        x: point.x / UIScreen.main.bounds.width,
                        y: point.y / UIScreen.main.bounds.height)
                    device.exposurePointOfInterest = exposurePoint
                    device.exposureMode = .autoExpose
                }

                device.unlockForConfiguration()

                // Show focus animation
                DispatchQueue.main.async {
                    self.showFocusAnimation(at: point)
                }
            } catch {
                print("Error setting focus: \(error.localizedDescription)")
            }
        }

        private func showFocusAnimation(at point: CGPoint) {
            guard let window = UIApplication.shared.windows.first else {
                return
            }

            let focusView = UIView(
                frame: CGRect(x: 0, y: 0, width: 70, height: 70))
            focusView.backgroundColor = .clear
            focusView.layer.borderColor = UIColor.yellow.cgColor
            focusView.layer.borderWidth = 1.5
            focusView.center = point
            window.addSubview(focusView)

            focusView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            focusView.alpha = 1

            UIView.animate(
                withDuration: 0.25,
                animations: {
                    focusView.transform = .identity
                },
                completion: { _ in
                    UIView.animate(
                        withDuration: 0.15, delay: 0.5, options: [],
                        animations: {
                            focusView.alpha = 0
                        },
                        completion: { _ in
                            focusView.removeFromSuperview()
                        })
                })
        }
    }
}
