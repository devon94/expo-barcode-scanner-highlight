// Reexport the native module. On web, it will be resolved to ExpoBarcodeScannerHighlightModule.web.ts
// and on native platforms to ExpoBarcodeScannerHighlightModule.ts
export { default } from './ExpoBarcodeScannerHighlightModule';
export { default as ExpoBarcodeScannerHighlightView } from './ExpoBarcodeScannerHighlightView';
export * from  './ExpoBarcodeScannerHighlight.types';
