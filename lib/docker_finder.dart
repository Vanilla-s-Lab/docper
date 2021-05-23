import 'dart:io';

String dockerCommand() {
  if (Platform.isMacOS) return "/usr/local/bin/docker";
  return "docker";
}
