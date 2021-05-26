import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:file_selector/file_selector.dart';
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

extension PathExtension on List<String> {
  String pathString() {
    if (this.isEmpty) return "/";
    return "/${this.join("/")}/";
  }
}

class _FileExplorerExpendedState extends State<FileExplorer> {
  ContainerInfo _tapedContainer;
  Future<List<ContainerFile>> _containerFileListFuture;

  List<String> _currentPath = [];
  EventBus _tapFileBus = EventBus();

  @override
  void initState() {
    super.initState();
    widget._expandedBus.on<TapContainerEvent>().listen((event) {
      setState(() {
        _tapedContainer = event.containerInfo;
        _currentPath = [];
        _containerFileListFuture = _newContainerFilesFuture();
      });
    });

    widget._expandedBus.on<RefreshAllEvent>().listen((_) {
      setState(() {
        _tapedContainer = null;
        _currentPath = [];
      });
    });

    _tapFileBus.on<TapFileEvent>().listen((event) {
      final tapedFile = event.containerFile;
      if (tapedFile.type() == FileSystemEntityType.directory) {
        setState(() {
          final tapedFileName = tapedFile.fileName;
          if (tapedFileName == ".") {
            // Refresh current path, so do nothing for _currentPath.
          } else if (tapedFileName == "..") {
            if (_currentPath.isNotEmpty) _currentPath.removeLast();
            // If _currentPath empty, means current path is "/".
          } else {
            _currentPath.add(tapedFile.fileName);
          }

          _containerFileListFuture = _newContainerFilesFuture();
        });
      }
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

    final blueDivider = Divider(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(
        title: Text("Container ID: " + _tapedContainer.id),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        // https://stackoverflow.com/questions/51125024/there-are-multiple-heroes-that-share-the-same-tag-within-a-subtree
        heroTag: null,

        onPressed: () => importFile(context),
        tooltip: "Import file",
        child: Icon(Icons.archive),
      ),
      body: BorderedContainer(
        child: Column(children: [
          blueDivider,
          Text(
            _currentPath.pathString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          blueDivider,
          Expanded(
            child: FutureBuilder(
              future: _containerFileListFuture,
              builder: (buildContext, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final files = snapshot.data as List<ContainerFile>;
                  final widgets = files.map((e) => FileWidget(e, _tapFileBus));
                  return ResponsiveGridList(
                    children: [...widgets],
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
      ["exec", tapedContainerId, "ls", _currentPath.pathString(), "-al"],
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
        .map((e) => ContainerFile(e.first[0], e.toList()[8], e.toList()))
        .toList();
  }

  void importFile(BuildContext context) async {
    List<XFile> chosenFiles = await openFiles();
    chosenFiles.map((e) => e.path).forEach((element) async {
      await Process.run(
        dockerCommand(),
        ["cp", element, "${_tapedContainer.id}:${_currentPath.pathString()}"],
        runInShell: true,
      );
    });
    setState(() => {_containerFileListFuture = _newContainerFilesFuture()});
  }
}
