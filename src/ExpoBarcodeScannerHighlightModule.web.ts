import { registerWebModule, NativeModule } from 'expo';

import { ExpoBarcodeScannerHighlightModuleEvents } from './ExpoBarcodeScannerHighlight.types';

class ExpoBarcodeScannerHighlightModule extends NativeModule<ExpoBarcodeScannerHighlightModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoBarcodeScannerHighlightModule);
