import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/docker_component/pojos/container_file.dart';
import 'package:untitled/docker_component/pojos/events.dart';

class FileWidget extends StatelessWidget {
  final ContainerFile fileInfo;
  final EventBus _tapFileBus;

  const FileWidget(this.fileInfo, this._tapFileBus, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: fileInfo.rawData.toString(),
      verticalOffset: -65,
      child: InkWell(
        onTap: () => _tapFileBus.fire(TapFileEvent(fileInfo)),
        child: Container(
          // https://stackoverflow.com/questions/50186555/how-to-set-margin-for-a-button-in-flutter
          margin: const EdgeInsets.all(7.0),
          height: 62,
          width: 71,
          child: Column(
            children: [
              Icon(fileInfo.icon()),
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
