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
      // Animate in
      opacity.value = withSequence(
        withTiming(1, { duration: 300 }),
        withTiming(1, { duration: 2400 }),
        withTiming(0, { duration: 300 })
      )

      // Clear the barcode after 3 seconds
      const timer = setTimeout(() => {
        setScannedBarcode('')
      }, 3000)

      return () => clearTimeout(timer)
    }
  }, [scannedBarcode])

  const onBarcodeTapped = (event: { nativeEvent: { value: string } }) => {
    setScannedBarcode(event.nativeEvent.value)
    console.log('Barcode tapped:', event.nativeEvent)
  }

  const onBarcodesDetected = (event: { nativeEvent: { barcodes: any } }) => {
    console.log('Barcodes detected:', event.nativeEvent)
  }

  return (
    <View style={styles.container}>
      <ExpoBarcodeScannerHighlightView
        style={styles.scanner}
        onBarcodesDetected={onBarcodesDetected}
        onBarcodeTapped={onBarcodeTapped}
        showHighlight={true}
      />
      
      {scannedBarcode !== '' && (
        <Animated.View style={[styles.toastContainer, animatedStyle]}>
          <BlurView intensity={70} tint="dark" style={styles.blurView}>
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