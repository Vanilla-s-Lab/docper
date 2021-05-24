import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/bordered_container.dart';
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
    if (_tapedContainer == null) {
      return Scaffold(
          appBar: AppBar(title: Text("File List"), centerTitle: true),
          body: BorderedContainer(
            child: Center(child: Text("Tap a container to view files.")),
          ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Container ID: " + _tapedContainer.id),
        centerTitle: true,
      ),
      body: BorderedContainer(
        child: FutureBuilder(
          future: _containerFileListFuture,
          builder: (buildContext, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Future<List<ContainerFile>> _newContainerFilesFuture() async {
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
        .map((e) => ContainerFile(e.first[0], e.last))
        .toList();
  }
}
