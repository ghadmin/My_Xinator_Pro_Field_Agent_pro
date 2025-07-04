import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

String dateTimeConverter({
  required String inputTime,
  required String outputFormat,
  String? inputFormat,
  String? timezone,
}) {
  tz_data.initializeTimeZones();

  DateTime dateTime;

  if (inputFormat != null) {
    final customInputFormat = DateFormat(inputFormat);
    dateTime = customInputFormat.parse(inputTime);
  } else {
    dateTime = DateTime.parse(inputTime);
  }

  DateTime finalDateTime;
  if (timezone != null) {
    final location = tz.getLocation(timezone);
    final tzDateTime = tz.TZDateTime.from(dateTime, location);
    finalDateTime = tzDateTime;
  } else {
    finalDateTime = dateTime.toLocal();
  }

  // Format the DateTime object to the desired output format
  final format = DateFormat(outputFormat);
  return format.format(finalDateTime);
}
