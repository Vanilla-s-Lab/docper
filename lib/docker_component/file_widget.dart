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

    return Tooltip(
      message: fileInfo.rawData.toString(),
      verticalOffset: -65,
      child: InkWell(
        onTap: () {},
        child: Container(
          // https://stackoverflow.com/questions/50186555/how-to-set-margin-for-a-button-in-flutter
          margin: const EdgeInsets.all(7.0),
          height: 62,
          width: 71,
          child: Column(
            children: [
              Icon(fileIcon),
              Text(fileInfo.fileName,
                  textAlign: TextAlign.center,
                  maxLines: 2,

                  // https://api.flutter.dev/flutter/widgets/Text-class.html
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
