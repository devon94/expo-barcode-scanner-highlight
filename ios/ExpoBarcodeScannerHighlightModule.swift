import ExpoModulesCore

public class ExpoBarcodeScannerHighlightModule: Module {
    public func definition() -> ModuleDefinition {
        Name("ExpoBarcodeScannerHighlight")

        View(ExpoBarcodeScannerHighlightView.self) {
            Events("onBarcodesDetected", "onBarcodeTapped")

        }

        Prop("showHighlight") {
            (view: ExpoBarcodeScannerHighlightView, showHighlight: Bool?) in
            view.showHighlight = showHighlight ?? true
        }

        Prop("lerpingSmoothingFactor") {
            (
                view: ExpoBarcodeScannerHighlightView,
                lerpingSmoothingFactor: CGFloat?
            ) in
            view.lerpingSmoothingFactor = lerpingSmoothingFactor ?? 0.3
        }
    }
}
