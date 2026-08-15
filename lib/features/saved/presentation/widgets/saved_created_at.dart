import 'package:intl/intl.dart';

(String, String)? splitSavedCreatedAt(DateTime? date, String locale) {
  if (date == null) return null;
  final local = date.toLocal();
  final datePart = DateFormat('d MMM yyyy', locale).format(local);
  final timePart = DateFormat("'at' hh:mm a", locale).format(local);
  return (datePart, timePart);
}
