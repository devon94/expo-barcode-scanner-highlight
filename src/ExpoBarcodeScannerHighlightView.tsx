import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoBarcodeScannerHighlightViewProps } from './ExpoBarcodeScannerHighlight.types';

const NativeView: React.ComponentType<ExpoBarcodeScannerHighlightViewProps> =
  requireNativeView('ExpoBarcodeScannerHighlight');

export default function ExpoBarcodeScannerHighlightView(props: ExpoBarcodeScannerHighlightViewProps) {
  return <NativeView {...props} />;
}
