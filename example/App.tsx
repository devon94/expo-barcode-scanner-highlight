import { ExpoBarcodeScannerHighlightView } from 'expo-barcode-scanner-highlight'
import { StyleSheet, View, Text, Platform } from 'react-native'
import { BlurView } from 'expo-blur'
import { useState, useEffect } from 'react'
import Animated, {
  withTiming,
  useAnimatedStyle,
  useSharedValue,
  withSequence
} from 'react-native-reanimated'

export default function App() {
  const [scannedBarcode, setScannedBarcode] = useState('')
  const opacity = useSharedValue(0)

  const animatedStyle = useAnimatedStyle(() => {
    return {
      opacity: opacity.value,
    }
  })

  useEffect(() => {
    if (scannedBarcode) {
      opacity.value = withSequence(
        withTiming(1, { duration: 300 }),
        withTiming(1, { duration: 2400 }),
        withTiming(0, { duration: 300 })
      )

      const timer = setTimeout(() => {
        setScannedBarcode('')
      }, 3000)

      return () => clearTimeout(timer)
    }
  }, [scannedBarcode])

  const onBarcodeTapped = (event: { nativeEvent: { barcode: string } }) => {
    setScannedBarcode(event.nativeEvent.barcode)
    console.log('Barcode tapped:', event.nativeEvent)
  }

  // unused but can be used to get all detected barcodes
  const onBarcodesDetected = (_event: { nativeEvent: { barcodes: any } }) => {
    // console.log('Barcodes detected:', event.nativeEvent)
  }

  return (
    <View style={styles.container}>
      <ExpoBarcodeScannerHighlightView
        style={styles.scanner}
        onBarcodesDetected={onBarcodesDetected}
        onBarcodeTapped={onBarcodeTapped}
        // TODO: Test if this works
        showHighlight={true}
        // TODO: Test if this works. Also idk if android can implement this
        lerpingSmoothingFactor={0.25}
      />

      {scannedBarcode !== '' && (
        <Animated.View style={[styles.toastContainer, animatedStyle]}>
          <BlurView intensity={50} tint="light" style={styles.blurView}>
            <Text style={styles.toastText}>{scannedBarcode}</Text>
          </BlurView>
        </Animated.View>
      )}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    width: '100%',
  },
  scanner: {
    flex: 1,
    width: '100%',
  },
  toastContainer: {
    position: 'absolute',
    bottom: 40,
    left: 20,
    right: 20,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 9999,
  },
  blurView: {
    padding: 16,
    borderRadius: 12,
    width: '100%',
    alignItems: 'center',
    overflow: 'hidden',
  },
  toastText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '500',
    textAlign: 'center',
  },
})