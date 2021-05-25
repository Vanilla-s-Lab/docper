import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:untitled/bordered_container.dart';
import 'package:untitled/docker_component/file_widget.dart';
import 'package:untitled/docker_component/pojos/container_file.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';
import 'package:untitled/docker_component/pojos/events.dart';
import 'package:untitled/docker_finder.dart';

class FileExplorer extends StatefulWidget {
  final EventBus _expandedBus;

  const FileExplorer(this._expandedBus, {Key key}) : super(key: key);

  @override
  _FileExplorerExpendedState createState() => _FileExplorerExpendedState();
}

class _FileExplorerExpendedState extends State<FileExplorer> {
  ContainerInfo _tapedContainer;
  Future<List<ContainerFile>> _containerFileListFuture;
  String _currentPath = "/";

  @override
  void initState() {
    super.initState();
    widget._expandedBus.on<TapContainerEvent>().listen((event) {
      setState(() {
        _tapedContainer = event.containerInfo;
        _containerFileListFuture = _newContainerFilesFuture();
      });
    });

    widget._expandedBus.on<RefreshAllEvent>().listen((_) {
      setState(() {
        _tapedContainer = null;
        _currentPath = "/";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final centerAppBar = AppBar(title: Text("File List"), centerTitle: true);
    if (_tapedContainer == null) {
      return Scaffold(
          appBar: centerAppBar,
          body: BorderedContainer(
            child: Center(child: Text("Tap a container to view files.")),
          ));
    }

    if (!_tapedContainer.isRunning()) {
      return Scaffold(
          appBar: centerAppBar,
          body: BorderedContainer(
            child:
                Center(child: Text("Not support stopped container yet : ( ")),
          ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Container ID: " + _tapedContainer.id),
        centerTitle: true,
      ),
      body: BorderedContainer(
        child: Column(children: [
          Text(_currentPath, maxLines: 1),
          Expanded(
            child: FutureBuilder(
              future: _containerFileListFuture,
              builder: (buildContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final containerFiles = snapshot.data as List<ContainerFile>;
                  final fileWidgets = containerFiles.map((e) => FileWidget(e));
                  return ResponsiveGridList(
                    children: [...fileWidgets],
                    desiredItemWidth: 71,
                  );
                }

                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ]),
      ),
    );
  }

  Future<List<ContainerFile>> _newContainerFilesFuture() async {
    if (!_tapedContainer.isRunning()) return [];

    final tapedContainerId = _tapedContainer.id;
    final cmdResult = await Process.run(
      dockerCommand(),
      ["exec", tapedContainerId, "ls", _currentPath, "-al"],
      runInShell: true,
    );

    if (cmdResult.exitCode != 0) return Future.error(cmdResult.stderr);
    final rawLsCmdString = cmdResult.stdout as String;

    // First is string like "total 80", last is just empty string.
    final lsResultList = rawLsCmdString.split("\n");
    lsResultList.removeAt(0);
    lsResultList.removeLast();

    return lsResultList
        .map((e) => e.split(" "))
        .map((e) => e.where((element) => element.isNotEmpty))
        // https://stackoverflow.com/questions/57730318/how-to-get-first-letter-of-string-in-flutter-dart
        .map((e) => ContainerFile(e.first[0], e.last, e.toList()))
        .toList();
  }
}
