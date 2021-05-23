import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/bordered_container.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';
import 'package:untitled/docker_component/pojos/events.dart';

class FileExplorer extends StatefulWidget {
  final EventBus _expandedBus;

  const FileExplorer(this._expandedBus, {Key key}) : super(key: key);

  @override
  _FileExplorerExpendedState createState() => _FileExplorerExpendedState();
}

class _FileExplorerExpendedState extends State<FileExplorer> {
  ContainerInfo _tapedContainer;

  @override
  void initState() {
    super.initState();
    widget._expandedBus.on<TapContainerEvent>().listen((event) {
      setState(() => _tapedContainer = event.containerInfo);
    });

    widget._expandedBus.on<RefreshAllEvent>().listen((_) {
      setState(() => _tapedContainer = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_tapedContainer == null) {
      return Scaffold(
          appBar: AppBar(title: Text("File List")),
          body: BorderedContainer(
            child: Center(child: Text("Tap a container to view files.")),
          ));
    }

    return Scaffold(
      appBar: AppBar(title: Text("\"${_tapedContainer.images}\"")),
      body: BorderedContainer(),
    );
  }
}
