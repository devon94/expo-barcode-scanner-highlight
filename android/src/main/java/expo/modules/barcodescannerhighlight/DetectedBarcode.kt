package expo.modules.barcodescannerhighlight
import android.graphics.RectF

data class DetectedBarcode(
    val id: String,
    var boundingBox: RectF,
    val payload: String
)