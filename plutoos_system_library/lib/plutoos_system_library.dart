import 'dart:io';

bool systemInDevelopmentMode() {
  final devFile = File("/chainloader/DEV");

  return devFile.existsSync();
}

String getAPIUrl() {
  return systemInDevelopmentMode()
    ? "http://192.168.1.32:8787/api/v1"
    : "https://pluto-freeze.77z.dev/api/v1";
}

// Also include:
// - get latest version from api
// - compare versions
// - get system version