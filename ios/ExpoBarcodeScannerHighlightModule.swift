import ExpoModulesCore

public class ExpoBarcodeScannerHighlightModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoBarcodeScannerHighlight")

    View(ExpoBarcodeScannerHighlightView.self) {
        Events("onBarcodeDetected", "onBarcodeTapped")
    }
  }
}
