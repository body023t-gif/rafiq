String readString(Map<String, dynamic> json, List<String> keys, [String fallback = '']) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

int readInt(Map<String, dynamic> json, List<String> keys, [int fallback = 0]) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toInt();
  }
  return fallback;
}

double readDouble(Map<String, dynamic> json, List<String> keys, [double fallback = 0]) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
  }
  return fallback;
}

bool readBool(Map<String, dynamic> json, List<String> keys, [bool fallback = false]) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
  }
  return fallback;
}

List<Map<String, dynamic>> readMapList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
  }
  return const [];
}
