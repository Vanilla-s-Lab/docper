import 'dart:io';

import 'package:flutter/material.dart';
import 'package:untitled/docker_component/pojos/container_file.dart';

class FileWidget extends StatelessWidget {
  final ContainerFile fileInfo;

  const FileWidget(this.fileInfo, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData fileIcon = Icons.help;
    switch (fileInfo.type()) {
      case FileSystemEntityType.file:
        fileIcon = Icons.description;
        break;
      case FileSystemEntityType.directory:
        fileIcon = Icons.folder;
        break;
    }

    return Container(
      height: 100,
      width: 100,
      child: Column(children: []),
    );
  }
}
