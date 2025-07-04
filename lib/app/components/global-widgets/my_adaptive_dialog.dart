import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum AdaptiveDialogAction { yes, no, cancel }

class MyAdaptiveDialog {
  static Future<AdaptiveDialogAction?> show({
    required BuildContext context,
    required String title,
    required Widget content,
    bool showCancel = true,
    String? yesLabel,
    String? noLabel,
    Color? yesColor,
    Color? noColor,
    bool centerTitle = false,
    TextStyle? titleTextStyle,
    VoidCallback? yesAction, // New: Custom action for "Yes"
    VoidCallback? noAction, // New: Custom action for "No"
  }) async {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return _showCupertinoDialog(
        context: context,
        title: title,
        content: Material(color: Colors.transparent, child: content),
        showCancel: showCancel,
        yesLabel: yesLabel,
        noLabel: noLabel,
        yesColor: yesColor,
        noColor: noColor,
        centerTitle: centerTitle,
        titleTextStyle: titleTextStyle,
        yesAction: yesAction,
        noAction: noAction,
      );
    } else {
      return _showMaterialDialog(
        context: context,
        title: title,
        content: content,
        showCancel: showCancel,
        yesLabel: yesLabel,
        noLabel: noLabel,
        yesColor: yesColor,
        noColor: noColor,
        centerTitle: centerTitle,
        titleTextStyle: titleTextStyle,
        yesAction: yesAction,
        noAction: noAction,
      );
    }
  }

  static Future<AdaptiveDialogAction?> _showMaterialDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required bool showCancel,
    required String? yesLabel,
    required String? noLabel,
    Color? yesColor,
    Color? noColor,
    required bool centerTitle,
    TextStyle? titleTextStyle,
    VoidCallback? yesAction,
    VoidCallback? noAction,
  }) async {
    final actions = <Widget>[];

    if (noLabel != null && showCancel) {
      actions.add(
        TextButton(
          style: TextButton.styleFrom(foregroundColor: noColor),
          onPressed: () {
            noAction?.call(); // Call custom "No" action if provided
            Navigator.of(context).pop(AdaptiveDialogAction.no);
          },
          child: Text(noLabel),
        ),
      );
    }

    if (yesLabel != null) {
      actions.add(
        TextButton(
          style: TextButton.styleFrom(foregroundColor: yesColor),
          onPressed: () {
            yesAction?.call(); // Call custom "Yes" action if provided
            Navigator.of(context).pop(AdaptiveDialogAction.yes);
          },
          child: Text(yesLabel),
        ),
      );
    }

    return await showDialog<AdaptiveDialogAction>(
      context: context,

      builder: (context) => AlertDialog(
        title: Text(
          title,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: titleTextStyle,
        ),
        content: SingleChildScrollView(child: content),
        actions: actions,
      ),
    );
  }

  static Future<AdaptiveDialogAction?> _showCupertinoDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required bool showCancel,
    required String? yesLabel,
    required String? noLabel,
    Color? yesColor,
    Color? noColor,
    required bool centerTitle,
    TextStyle? titleTextStyle,
    VoidCallback? yesAction,
    VoidCallback? noAction,
  }) async {
    final actions = <CupertinoDialogAction>[];

    if (noLabel != null && showCancel) {
      actions.add(
        CupertinoDialogAction(
          onPressed: () {
            noAction?.call(); // Call custom "No" action if provided
            Navigator.of(context).pop(AdaptiveDialogAction.no);
          },
          textStyle: noColor != null ? TextStyle(color: noColor) : null,
          child: Text(noLabel),
        ),
      );
    }

    if (yesLabel != null) {
      actions.add(
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            yesAction?.call(); // Call custom "Yes" action if provided
            Navigator.of(context).pop(AdaptiveDialogAction.yes);
          },
          textStyle: yesColor != null ? TextStyle(color: yesColor) : null,
          child: Text(yesLabel),
        ),
      );
    }

    return await showCupertinoDialog<AdaptiveDialogAction>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          title,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: titleTextStyle,
        ),
        content: content,
        actions: actions,
      ),
    );
  }
}
