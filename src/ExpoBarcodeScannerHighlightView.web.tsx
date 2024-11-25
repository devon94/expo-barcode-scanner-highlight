import * as React from 'react';

import { ExpoBarcodeScannerHighlightViewProps } from './ExpoBarcodeScannerHighlight.types';

export default function ExpoBarcodeScannerHighlightView(props: ExpoBarcodeScannerHighlightViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
