import ExpoModulesCore
import SwiftUI
import UIKit

class ExpoBarcodeScannerHighlightView: ExpoView {
    let onBarcodesDetected = EventDispatcher()
    let onBarcodeTapped = EventDispatcher()
    private var hostingController: UIHostingController<CameraViewWithOverlay>?
    private var scannerViewModel = ScannerViewModel()
    
    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        
        let cameraViewWithOverlay = CameraViewWithOverlay(scannerViewModel: scannerViewModel)
        scannerViewModel.setonBarcodesDetected({ [weak self] barcodes in
            self?.onBarcodesDetected(barcodes)
        })
        
        scannerViewModel.setOnBarcodeTapped({ [weak self] barcode in
            self?.onBarcodeTapped(["barcode": barcode.payload])
        })
        
        hostingController = UIHostingController(rootView: cameraViewWithOverlay)
        hostingController?.view.backgroundColor = UIColor.clear
        
        if let hostingView = hostingController?.view {
            addSubview(hostingView)
            hostingView.frame = bounds
            hostingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    var showHighlight: Bool = true {
        didSet {
            print("ExpoView - showHighlight changed to: \(showHighlight)")
            scannerViewModel.showHighlight = showHighlight
        }
    }
    
    var lerpingSmoothingFactor: CGFloat = 0.3 {
        didSet {
            print("ExpoView - lerpingSmoothingFactor changed to: \(lerpingSmoothingFactor)")
            scannerViewModel.lerpingSmoothingFactor = lerpingSmoothingFactor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { $0.frame = bounds }
    }
}
