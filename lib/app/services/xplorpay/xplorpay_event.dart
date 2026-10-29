/// Typed events surfaced by [XplorPayService]'s event stream.
///
/// These mirror the payloads emitted by the native side
/// (ios/Runner/XplorPayPlugin.m on iOS).
library;

/// Reader feedback categories, matching CLEARENT_FEEDBACK_MESSAGE_TYPE in
/// ClearentFeedback.h (UNKNOWN = 0, USER_ACTION = 1, INFO = 2, BLUETOOTH = 3,
/// ERROR = 4).
enum XplorPayFeedbackType { unknown, userAction, info, bluetooth, error }

XplorPayFeedbackType feedbackTypeFromCode(int? code) {
  switch (code) {
    case 1:
      return XplorPayFeedbackType.userAction;
    case 2:
      return XplorPayFeedbackType.info;
    case 3:
      return XplorPayFeedbackType.bluetooth;
    case 4:
      return XplorPayFeedbackType.error;
    default:
      return XplorPayFeedbackType.unknown;
  }
}

sealed class XplorPayEvent {
  const XplorPayEvent();
}

/// The VP3300 reader is connected over Bluetooth.
class XplorPayConnected extends XplorPayEvent {
  const XplorPayConnected();
}

/// The reader disconnected (out of range, powered off, mid-transaction too).
class XplorPayDisconnected extends XplorPayEvent {
  const XplorPayDisconnected();
}

/// Reader guidance for the customer ("INSERT CARD", "CARD READ OK...", ...).
class XplorPayFeedback extends XplorPayEvent {
  final String message;
  final XplorPayFeedbackType feedbackType;
  final int returnCode;

  const XplorPayFeedback({
    required this.message,
    required this.feedbackType,
    required this.returnCode,
  });
}

/// The reader produced an encrypted transaction token (JWT). Submit it to the
/// Xplor Pay mobile transactions endpoint to actually charge the card.
///
/// The JWT itself is never logged.
class XplorPayToken extends XplorPayEvent {
  final String jwt;
  final String cvm;
  final String lastFour;
  final String cardType;

  const XplorPayToken({
    required this.jwt,
    required this.cvm,
    required this.lastFour,
    required this.cardType,
  });
}

/// Bluetooth readers discovered during a scan (connectReader resolves them
/// automatically to the first one found; this is surfaced for diagnostics).
class XplorPayBluetoothDevices extends XplorPayEvent {
  final List<XplorPayBluetoothDevice> devices;

  const XplorPayBluetoothDevices(this.devices);
}

class XplorPayBluetoothDevice {
  final String friendlyName;
  final String deviceId;
  final bool connected;

  const XplorPayBluetoothDevice({
    required this.friendlyName,
    required this.deviceId,
    required this.connected,
  });

  factory XplorPayBluetoothDevice.fromMap(Map<Object?, Object?> map) {
    return XplorPayBluetoothDevice(
      friendlyName: map['friendlyName'] as String? ?? '',
      deviceId: map['deviceId'] as String? ?? '',
      connected: map['connected'] as bool? ?? false,
    );
  }
}

/// Reader/SDK level error (failed card read, timeout, manual entry error...).
class XplorPayError extends XplorPayEvent {
  final String message;

  const XplorPayError(this.message);
}

XplorPayEvent eventFromMap(Map<Object?, Object?> map) {
  switch (map['event']) {
    case 'connected':
      return const XplorPayConnected();
    case 'disconnected':
      return const XplorPayDisconnected();
    case 'feedback':
      return XplorPayFeedback(
        message: map['message'] as String? ?? '',
        feedbackType: feedbackTypeFromCode(map['feedbackType'] as int?),
        returnCode: map['returnCode'] as int? ?? 0,
      );
    case 'token':
      return XplorPayToken(
        jwt: map['jwt'] as String? ?? '',
        cvm: map['cvm'] as String? ?? '',
        lastFour: map['lastFour'] as String? ?? '',
        cardType: map['cardType'] as String? ?? '',
      );
    case 'bluetoothDevices':
      final raw = map['devices'];
      final devices = (raw is List)
          ? raw
              .whereType<Map<Object?, Object?>>()
              .map(XplorPayBluetoothDevice.fromMap)
              .toList()
          : <XplorPayBluetoothDevice>[];
      return XplorPayBluetoothDevices(devices);
    case 'error':
    default:
      return XplorPayError(map['message'] as String? ?? 'Unknown reader error');
  }
}
