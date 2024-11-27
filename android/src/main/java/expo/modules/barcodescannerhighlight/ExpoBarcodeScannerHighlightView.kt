package expo.modules.barcodescannerhighlight

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.view.ViewGroup
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import android.graphics.RectF
import android.graphics.Color
import android.widget.LinearLayout
import android.view.*

private const val TAG = "BarcodeScannerHighlightView"

class ExpoBarcodeScannerHighlightView(
  context: Context,
  appContext: AppContext
) : ExpoView(context, appContext) {

  private val lifecycleOwner: LifecycleOwner
    get() = appContext.currentActivity as LifecycleOwner

  private val onBarcodesDetected by EventDispatcher()
  private val onBarcodeTapped by EventDispatcher()
  private var cameraExecutor: ExecutorService
  private val detectedBarcodes: MutableMap<String, DetectedBarcode> = mutableMapOf()

  private var previewView = PreviewView(context)
  private val overlayView = BarcodeOverlayView(context).apply {
    // does nothing right now lol
    elevation = 1000f
  }
  private val providerFuture = ProcessCameraProvider.getInstance(context)

  init {
    previewView.setOnHierarchyChangeListener(object : OnHierarchyChangeListener {
      override fun onChildViewRemoved(parent: View?, child: View?) = Unit
      override fun onChildViewAdded(parent: View?, child: View?) {
        parent?.measure(
          MeasureSpec.makeMeasureSpec(measuredWidth, MeasureSpec.EXACTLY),
          MeasureSpec.makeMeasureSpec(measuredHeight, MeasureSpec.EXACTLY)
        )
        parent?.layout(0, 0, parent.measuredWidth, parent.measuredHeight)
      }
    })

    addView(
      previewView,
      ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT
      )
    )

    // TODO: WTF why doesnt this work lol. Might be new arch
    addView(
      overlayView,
      ViewGroup.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT,
        ViewGroup.LayoutParams.MATCH_PARENT
      )
    )
    cameraExecutor = Executors.newSingleThreadExecutor()
    checkAndRequestPermissions()
  }

  private fun checkAndRequestPermissions() {
    if (hasCameraPermission()) {
      createCamera()
    } else {
      requestCameraPermission()
    }
  }

  private fun hasCameraPermission(): Boolean {
    return ContextCompat.checkSelfPermission(
      context,
      Manifest.permission.CAMERA
    ) == PackageManager.PERMISSION_GRANTED
  }

  private fun requestCameraPermission() {
    ActivityCompat.requestPermissions(
      appContext.currentActivity!!,
      arrayOf(Manifest.permission.CAMERA),
      CAMERA_PERMISSION_REQUEST_CODE
    )
  }

  private fun createCamera() {
    providerFuture.addListener(
        {
            val cameraProvider: ProcessCameraProvider = providerFuture.get()

            val preview = Preview.Builder()
                .build()
                .also {
                    it.setSurfaceProvider(previewView.surfaceProvider)
                }

            val imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
                .also { imageAnalysis ->
                  imageAnalysis.setAnalyzer(cameraExecutor) { imageProxy ->
                      val mediaImage = imageProxy.image
                      if (mediaImage != null) {
                          val image = InputImage.fromMediaImage(
                              mediaImage,
                              imageProxy.imageInfo.rotationDegrees
                          )

                          val scanner = BarcodeScanning.getClient()
                          scanner.process(image)
                              .addOnSuccessListener { barcodes ->
                                  Log.d(TAG, "Found ${barcodes.size} barcodes")
                                  detectedBarcodes.clear()
                                  val boundingBoxes = mutableListOf<RectF>()
                                  // This works great but the overlay view does not show up
                                  // Can send Event TO RN to draw? But defeats the purpose of this view
                                  barcodes.forEach { barcode ->
                                      val id = barcode.displayValue ?: barcode.rawValue ?: ""
                                      val boundingBox = RectF(
                                          barcode.boundingBox?.left?.toFloat() ?: 0f,
                                          barcode.boundingBox?.top?.toFloat() ?: 0f,
                                          barcode.boundingBox?.right?.toFloat() ?: 0f,
                                          barcode.boundingBox?.bottom?.toFloat() ?: 0f
                                      )
                                      val detectedBarcode = DetectedBarcode(id, boundingBox, barcode.rawValue ?: "")
                                      detectedBarcodes[id] = detectedBarcode
                                      boundingBoxes.add(boundingBox)
                                  }
                                  // Update the overlay view with the new bounding boxes
                                  overlayView.updateBoundingBoxes(boundingBoxes)
                              }
                              .addOnFailureListener { e ->
                                  Log.e(TAG, "Barcode scanning failed", e)
                              }
                              .addOnCompleteListener {
                                  imageProxy.close()
                              }
                      } else {
                          imageProxy.close()
                      }
                  }
                }

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            try {
                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
            } catch (e: Exception) {
                Log.e(TAG, "Use case binding failed", e)
            }
        },
        ContextCompat.getMainExecutor(context)
    )
  }

  fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
    if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
      if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
        createCamera()
      }
    }
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    // also does not work
    overlayView.bringToFront()
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    cameraExecutor.shutdown()
  }

  companion object {
    private const val CAMERA_PERMISSION_REQUEST_CODE = 1001
  }
}
