// Xplor Pay (Clearent) Mobile EMV plugin for the IDTech VP3300 Bluetooth reader.
//
// Wraps ClearentIdtechIOSFrameworkPod behind two Flutter channels:
//   - MethodChannel "xplorpay/methods"
//   - EventChannel  "xplorpay/events"
//
// Implemented in Objective-C because the framework's initializers
// (initBluetoothSearch, initBluetoothWithFriendlyName:, ...) do not bridge
// cleanly to Swift.

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface XplorPayPlugin : NSObject <FlutterPlugin, FlutterStreamHandler>

@end

NS_ASSUME_NONNULL_END
