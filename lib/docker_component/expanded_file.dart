import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:docper/bordered_container.dart';
import 'package:docper/docker_component/file_widget.dart';
import 'package:docper/docker_component/pojos/container_file.dart';
import 'package:docper/docker_component/pojos/container_info.dart';
import 'package:docper/docker_component/pojos/events.dart';
import 'package:docper/docker_finder.dart';

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

  // https://flutter.dev/docs/cookbook/forms/retrieve-input
  final myController = TextEditingController();

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

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

    _tapFileBus.on<TapFileEvent>().listen((event) async {
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

      if (tapedFile.type() == FileSystemEntityType.file) {
        // https://pub.dev/documentation/file_selector/latest/
        final path = await getSavePath(suggestedName: tapedFile.fileName);
        if (path != null) {
          final filePath = _currentPath.pathString() + "/" + tapedFile.fileName;
          await Process.run(
            dockerCommand(),
            ["cp", "${_tapedContainer.id}:$filePath", path],
            runInShell: true,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final centerAppBar = AppBar(
      title: Text("File List"),
      elevation: 0,
      centerTitle: true,
    );
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
            child: Center(child: Text("Not support stopped container yet. ")),
          ));
    }

    final blueDivider = Divider(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(
        title: Text("Container ID: " + _tapedContainer.id),
        centerTitle: true,
        actions: [
          // https://stackoverflow.com/questions/64525713/how-to-make-a-squared-app-bar-button-in-flutter
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Container(
              width: 35,
              child: IconButton(
                onPressed: createFolder,
                icon: Icon(Icons.add),
                tooltip: "Create Folder",
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // https://stackoverflow.com/questions/51125024/there-are-multiple-heroes-that-share-the-same-tag-within-a-subtree
        heroTag: null,

        onPressed: () => importFile(), tooltip: "Import file",
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

  void importFile() async {
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

  void createFolder() {
    void _execMkdir(String text) async {
      final mkdirTarget = _currentPath.pathString() + "/" + text;
      await Process.run(
        dockerCommand(),
        ["exec", _tapedContainer.id, "mkdir", mkdirTarget],
        runInShell: true,
      );
      setState(() => {_containerFileListFuture = _newContainerFilesFuture()});
    }

    final inputTextField = TextField(
      // https://flutter.dev/docs/cookbook/forms/focus
      autofocus: true,
      controller: myController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Folder name',
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Create Folder"),
        // https://api.flutter.dev/flutter/material/TextField-class.html
        content: inputTextField,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _execMkdir(myController.text);
              myController.clear();
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
}
