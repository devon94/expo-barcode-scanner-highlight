import type { StyleProp, ViewStyle } from "react-native";

export type ExpoBarcodeScannerHighlightModuleEvents = {};

export type ExpoBarcodeScannerHighlightViewProps = {
  onBarcodeTapped: (event: { nativeEvent: { barcode: string } }) => void;
  onBarcodesDetected: (event: { nativeEvent: { barcodes: string[] } }) => void;
  style?: StyleProp<ViewStyle>;
  showHighlight?: boolean;
};
