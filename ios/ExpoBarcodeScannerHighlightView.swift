import ExpoModulesCore
import SwiftUI
import UIKit

class ExpoBarcodeScannerHighlightView: ExpoView {
    let onBarcodeDetected = EventDispatcher()
    let onBarcodeTapped = EventDispatcher()
    var cameraViewWithOverlay = CameraViewWithOverlay()
    
    required init(appContext: AppContext? = nil) {        
        // Call super.init
        super.init(appContext: appContext)
        
        // Now we can set up the real event handlers
        cameraViewWithOverlay.setOnBarcodeDetected({ [weak self] barcode in
            self?.onBarcodeDetected(["payload": barcode.payload])
        })
        
        cameraViewWithOverlay.setOnBarcodeTapped({ [weak self] barcode in
            print("Barcode tapped")
            print("self?.onBarcodeTapped exists: \(self?.onBarcodeTapped != nil)")
            self?.onBarcodeTapped(["payload": barcode.payload])
        })
        
        let hostingController = UIHostingController(rootView: cameraViewWithOverlay)
        hostingController.view.backgroundColor = UIColor.clear
        
        addSubview(hostingController.view)
        hostingController.view.frame = bounds
        
        hostingController.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        subviews.forEach { $0.frame = bounds }
    }
}
