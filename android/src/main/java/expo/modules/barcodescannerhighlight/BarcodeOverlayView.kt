package expo.modules.barcodescannerhighlight

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.View
import android.view.GestureDetector
import android.view.MotionEvent
import android.util.Log

class BarcodeOverlayView(context: Context) : View(context) {
    var boundingBoxes: List<RectF> = listOf()  // This will hold all the bounding boxes to draw

    override fun onDraw(canvas: Canvas) {
        Log.d("BarcodeScannerHighlightViewBarcodeOverlayView", "onDraw")
        super.onDraw(canvas)

        val paint = Paint().apply {
            color = Color.YELLOW
            strokeWidth = 5f
            style = Paint.Style.STROKE
        }

        canvas.drawRect(RectF(0.0f, 0.0f, 100.0f, 100.0f), paint)

    }
    
    fun updateBoundingBoxes(boxes: List<RectF>) {
        Log.d("BarcodeScannerHighlightViewBarcodeOverlayView", "updateBoundingBoxes")
        boundingBoxes = boxes
        invalidate()  // Request a re-draw
    }
}