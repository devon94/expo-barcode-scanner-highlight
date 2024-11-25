import { ExpoBarcodeScannerHighlightView } from 'expo-barcode-scanner-highlight'
import { StyleSheet, View } from 'react-native'

export default function App() {
  const onBarcodeTapped = (event: { nativeEvent: { value: string } }) => {
    console.log('Barcode detected:', event.nativeEvent)
  }

  return (
    <View style={styles.container}>
      <ExpoBarcodeScannerHighlightView
        style={styles.scanner}
        onBarcodeTapped={onBarcodeTapped}
      />
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
})