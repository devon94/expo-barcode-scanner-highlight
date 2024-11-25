import { NativeModule, requireNativeModule } from 'expo';

import { ExpoBarcodeScannerHighlightModuleEvents } from './ExpoBarcodeScannerHighlight.types';

declare class ExpoBarcodeScannerHighlightModule extends NativeModule<ExpoBarcodeScannerHighlightModuleEvents> {
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoBarcodeScannerHighlightModule>('ExpoBarcodeScannerHighlight');
