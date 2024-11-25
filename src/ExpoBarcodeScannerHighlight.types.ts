import type { StyleProp, ViewStyle } from "react-native";

export type OnBarcodeTappedPayload = {
  value: string;
};
export type ExpoBarcodeScannerHighlightModuleEvents = {};

export type ExpoBarcodeScannerHighlightViewProps = {
  onBarcodeTapped: (event: { nativeEvent: OnBarcodeTappedPayload }) => void;
  style?: StyleProp<ViewStyle>;
};
