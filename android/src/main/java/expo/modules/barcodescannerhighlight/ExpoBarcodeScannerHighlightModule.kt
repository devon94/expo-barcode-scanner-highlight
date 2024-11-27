package expo.modules.barcodescannerhighlight

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoBarcodeScannerHighlightModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ExpoBarcodeScannerHighlight")

    View(ExpoBarcodeScannerHighlightView::class) {
      Events("onBarcodesDetected", "onBarcodeTapped")

      // Prop("showHighlight") { view: ExpoBarcodeScannerHighlightView, showHighlight: Boolean ->
      //   view.showHighlight = showHighlight
      // }

      // Prop("lerpingSmoothingFactor") { view: ExpoBarcodeScannerHighlightView, factor: Double ->
      //   view.lerpingSmoothingFactor = factor.toFloat()
      // }
    }
  }
}