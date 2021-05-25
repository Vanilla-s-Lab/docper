import 'dart:io';

import 'package:flutter/material.dart';

class ContainerFile {
  // https://www.gnu.org/software/coreutils/manual/html_node/What-information-is-listed.html#index-long-ls-format
  String fileType;
  String fileName;

  List<String> rawData;

  ContainerFile(this.fileType, this.fileName, this.rawData);

  FileSystemEntityType type() {
    switch (fileType) {
      case "-":
        return FileSystemEntityType.file;
      case "d":
        return FileSystemEntityType.directory;
      case "l":
        return FileSystemEntityType.link;
    }

    return FileSystemEntityType.notFound;
  }

  IconData icon() {
    switch (this.type()) {
      case FileSystemEntityType.file:
        return Icons.description;
      case FileSystemEntityType.directory:
        return Icons.folder;
      case FileSystemEntityType.link:
        return Icons.link;
    }

    return Icons.help;
  }
}
