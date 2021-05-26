import 'dart:io';

import 'package:process_run/shell.dart';

String dockerCommand() {
  if (Platform.isMacOS) {
    final macOSDocker = whichSync("docker");
    return macOSDocker != null ? macOSDocker : "/usr/local/bin/docker";
  }
  return "docker";
}
