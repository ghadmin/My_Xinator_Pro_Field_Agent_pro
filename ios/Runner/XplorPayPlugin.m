//
//  XplorPayPlugin.m
//  Runner
//
//  Flutter bridge for ClearentIdtechIOSFramework (Xplor Pay mobile EMV) with
//  the IDTech VP3300 Bluetooth reader.
//
//  All method/property names come from the framework headers at tag 4.0.182 of
//  https://github.com/xplor-pay/ClearentIdtechIOSFrameworkPod — see
//  Clearent_VP3300.h, ClearentPublicVP3300Delegate.h, ClearentPayment.h,
//  ClearentConnection.h, ClearentVP3300Config.h, ClearentManualEntry.h.
//
//  Card data and the transaction JWT are never NSLogged.
//

#import "XplorPayPlugin.h"

#import <ClearentIdtechIOSFramework/ClearentIdtechIOSFramework.h>

@interface XplorPayPlugin () <Clearent_Public_IDTech_VP3300_Delegate, ClearentManualEntryDelegate>
@end

@implementation XplorPayPlugin {
  FlutterMethodChannel *_methodChannel;
  FlutterEventChannel *_eventChannel;
  FlutterEventSink _eventSink;

  Clearent_VP3300 *_clearentVP3300;
  ClearentManualEntry *_clearentManualEntry;
  ClearentConnection *_connection;

  NSString *_publicKey;
  NSString *_baseUrl;

  BOOL _transactionInProgress;
}

#pragma mark - FlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  XplorPayPlugin *instance = [[XplorPayPlugin alloc] init];
  instance->_methodChannel =
      [FlutterMethodChannel methodChannelWithName:@"xplorpay/methods"
                                  binaryMessenger:[registrar messenger]];
  instance->_eventChannel =
      [FlutterEventChannel eventChannelWithName:@"xplorpay/events"
                                binaryMessenger:[registrar messenger]];
  [instance->_eventChannel setStreamHandler:instance];
  [registrar addMethodCallDelegate:instance channel:instance->_methodChannel];
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  // The engine is going away; drop the sink so delegate callbacks after
  // teardown don't touch a dead channel.
  _eventSink = nil;
  _eventChannel = nil;
  _methodChannel = nil;
}

#pragma mark - FlutterStreamHandler

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  _eventSink = events;
  // The reader may already be paired/connected from a previous session; the
  // framework re-fires deviceConnected when the delegate is established, so
  // nothing extra to do here.
  return nil;
}

- (void)onCancelWithArguments:(id)arguments {
  _eventSink = nil;
}

#pragma mark - Helpers

/// Sends [payload] to Dart on the main thread; no-op when nobody is listening.
- (void)emit:(NSDictionary *)payload {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_eventSink) {
      self->_eventSink(payload);
    }
  });
}

- (void)emitError:(NSString *)message {
  [self emit:@{@"event": @"error", @"message": message ?: @""}];
}

- (BOOL)isConfigured:(FlutterResult)result {
  if (_clearentVP3300 == nil) {
    result([FlutterError errorWithCode:@"NOT_INITIALIZED"
                               message:@"Call initialize(publicKey, baseUrl) first"
                               details:nil]);
    return NO;
  }
  return YES;
}

#pragma mark - FlutterMethodChannel handler

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self handleMethodCallOnMainQueue:call result:result];
  });
}

- (void)handleMethodCallOnMainQueue:(FlutterMethodCall *)call result:(FlutterResult)result {
  id rawArgs = call.arguments;
  NSDictionary *args = [rawArgs isKindOfClass:[NSDictionary class]] ? rawArgs : @{};

  if ([call.method isEqualToString:@"isSupported"]) {
    // iOS with this pod is the supported platform; Android answers false on its side.
    result(@YES);

  } else if ([call.method isEqualToString:@"initialize"]) {
    NSString *publicKey = args[@"publicKey"];
    NSString *baseUrl = args[@"baseUrl"];
    if (publicKey.length == 0 || baseUrl.length == 0) {
      result([FlutterError errorWithCode:@"INVALID_ARGUMENTS"
                                 message:@"initialize requires publicKey and baseUrl"
                                 details:nil]);
      return;
    }
    BOOL reinitNeeded =
        _clearentVP3300 == nil || ![baseUrl isEqualToString:_baseUrl] ||
        ![publicKey isEqualToString:_publicKey];
    if (reinitNeeded) {
      if (_clearentVP3300 != nil) {
        [_clearentVP3300 close];  // closes channels, disconnects, destroys shared controller
        _clearentVP3300 = nil;
        _clearentManualEntry = nil;
        _connection = nil;
      }
      _publicKey = publicKey;
      _baseUrl = baseUrl;

      ClearentVP3300Config *config = [[ClearentVP3300Config alloc] init];
      [config setPublicKey:publicKey];
      [config setClearentBaseUrl:baseUrl];
      config.contactAutoConfiguration = NO;
      config.contactlessAutoConfiguration = NO;
      config.contactless = YES;
      config.disableRemoteLogging = YES;

      _clearentVP3300 = [[Clearent_VP3300 alloc] initWithConnectionHandling:self
                                             clearentVP3300Configuration:config];
      _clearentManualEntry = [[ClearentManualEntry alloc] init:self
                                                 clearentBaseUrl:baseUrl
                                                      publicKey:publicKey];
    }
    result(@(YES));

  } else if ([call.method isEqualToString:@"connectReader"]) {
    if (![self isConfigured:result]) return;
    // Bluetooth search: connects to the first paired reader found within the
    // scan window (default per framework).
    _connection = [[ClearentConnection alloc] initBluetoothSearch];
    [_clearentVP3300 startConnection:_connection];
    result(@(YES));

  } else if ([call.method isEqualToString:@"startTransaction"]) {
    if (![self isConfigured:result]) return;
    if (_transactionInProgress) {
      result([FlutterError errorWithCode:@"TRANSACTION_IN_PROGRESS"
                                 message:@"A transaction is already running"
                                 details:nil]);
      return;
    }
    double amount = [args[@"amount"] doubleValue];
    if (amount <= 0) {
      result([FlutterError errorWithCode:@"INVALID_ARGUMENTS"
                                 message:@"amount must be greater than zero"
                                 details:nil]);
      return;
    }
    int timeout = args[@"timeout"] != nil ? [args[@"timeout"] intValue] : 10;

    ClearentPayment *payment = [[ClearentPayment alloc] init];
    [payment setAmount:amount];
    payment.amtOther = 0;
    payment.type = 0;  // Sale
    payment.timeout = timeout;
    payment.tags = nil;
    payment.fallback = YES;
    payment.forceOnline = NO;

    // Reuse the connection from connectReader when present; otherwise search.
    if (_connection == nil) {
      _connection = [[ClearentConnection alloc] initBluetoothSearch];
    }
    ClearentResponse *response = [_clearentVP3300 startTransaction:payment
                                                clearentConnection:_connection];
    if (response.responseType != RESPONSE_SUCCESS) {
      result([FlutterError errorWithCode:@"START_FAILED"
                                 message:response.response ?: @"Reader could not start the transaction"
                                 details:nil]);
      return;
    }
    _transactionInProgress = YES;
    result(@(YES));

  } else if ([call.method isEqualToString:@"cancelTransaction"]) {
    if (![self isConfigured:result]) return;
    // Cancels the pending swipe/CTLS request (see Clearent_VP3300.h).
    [_clearentVP3300 device_cancelTransaction];
    _transactionInProgress = NO;
    result(@(YES));

  } else if ([call.method isEqualToString:@"disconnectReader"]) {
    if (![self isConfigured:result]) return;
    [_clearentVP3300 device_disconnectBLE];
    _connection = nil;
    result(@(YES));

  } else if ([call.method isEqualToString:@"startManualEntry"]) {
    if (![self isConfigured:result]) return;
    ClearentCard *card = [[ClearentCard alloc] init];
    card.card = args[@"card"];
    card.csc = args[@"csc"];
    card.expirationDateMMYY = args[@"expirationDateMMYY"];
    card.softwareType = args[@"softwareType"] ?: @"FlutterFieldAgent";
    card.softwareTypeVersion = args[@"softwareTypeVersion"] ?: @"1.0";
    [_clearentManualEntry createTransactionToken:card];
    result(@(YES));

  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - Clearent_Public_IDTech_VP3300_Delegate

- (void)successTransactionToken:(ClearentTransactionToken *)clearentTransactionToken {
  _transactionInProgress = NO;
  [self emit:@{
    @"event": @"token",
    @"jwt": clearentTransactionToken.jwt ?: @"",
    @"cvm": clearentTransactionToken.cvm ?: @"",
    @"lastFour": clearentTransactionToken.lastFour ?: @"",
    @"cardType": clearentTransactionToken.cardType ?: @"",
  }];
}

// Required by the protocol; only fires in offline mode, which this integration
// does not enable.
- (void)successOfflineTransactionToken:(NSData *)clearentTokenRequestData
                 isTransactionEncrypted:(BOOL)isEncrypted {
  _transactionInProgress = NO;
  [self emitError:@"Reader produced an offline token; offline mode is not supported in this app"];
}

- (void)feedback:(ClearentFeedback *)clearentFeedback {
  [self emit:@{
    @"event": @"feedback",
    @"message": clearentFeedback.message ?: @"",
    @"feedbackType": @(clearentFeedback.feedBackMessageType),
    @"returnCode": @(clearentFeedback.returnCode),
  }];
}

- (void)deviceConnected {
  [self emit:@{@"event": @"connected"}];
}

- (void)deviceDisconnected {
  _transactionInProgress = NO;
  [self emit:@{@"event": @"disconnected"}];
}

- (void)bluetoothDevices:(NSArray<ClearentBluetoothDevice *> *)bluetoothDevices {
  NSMutableArray *devices = [NSMutableArray array];
  for (ClearentBluetoothDevice *device in bluetoothDevices) {
    [devices addObject:@{
      @"friendlyName": device.friendlyName ?: @"",
      @"deviceId": device.deviceId ?: @"",
      @"connected": @(device.connected),
    }];
  }
  [self emit:@{@"event": @"bluetoothDevices", @"devices": devices}];
}

#pragma mark - ClearentManualEntryDelegate

- (void)handleManualEntryError:(NSString *)message {
  [self emitError:message ?: @"Manual entry failed"];
}

@end
