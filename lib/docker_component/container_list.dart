import 'dart:convert';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';
import 'package:untitled/docker_component/pojos/events.dart';
import 'package:untitled/docker_finder.dart';

class DockerContainerList extends StatefulWidget {
  final EventBus _drawerBus;
  final EventBus _expandedBus;

  const DockerContainerList(this._drawerBus, this._expandedBus, {Key key})
      : super(key: key);

  @override
  _DockerContainerListState createState() => _DockerContainerListState();
}

class _DockerContainerListState extends State<DockerContainerList> {
  bool _dockerIsRunning = false;

  @override
  void initState() {
    super.initState();
    widget._drawerBus.on<DockerIsRunningEvent>().listen((event) {
      setState(() => _dockerIsRunning = true);
      widget._expandedBus.fire(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadingProgressBar = Center(child: CircularProgressIndicator());

    // https://fluttercentral.com/Articles/Post/1272/How_to_show_an_empty_widget_in_flutter
    if (_dockerIsRunning) {
      return FutureBuilder(
        future: _newContainerListFuture(),
        builder: (buildContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final containerData = snapshot.data as List<ContainerInfo>;
            if (containerData.isEmpty) {
              return Center(child: Text("No container found. "));
            }

            final containerInfoTiles = containerData.map((e) => ListTile(
                  leading: Icon(
                    Icons.layers,
                    color: e.isRunning() ? Colors.green : null,
                  ),
                  title: Text(e.names),
                  subtitle: Text(e.id),
                  onTap: () => widget._expandedBus.fire(TapContainerEvent(e)),
                  trailing: Icon(Icons.arrow_right),
                ));
            return Scrollbar(
              child: ListView(
                children: [
                  ...ListTile.divideTiles(
                    context: buildContext,
                    tiles: containerInfoTiles.toList().reversed,
                  ),
                  Divider(),
                ],
              ),
            );
          }

          return loadingProgressBar;
        },
      );
    }

    return loadingProgressBar;
  }

  final cmdDockerPs = "${dockerCommand()} ps -a --format '{{json .}}'";

  Future<List<ContainerInfo>> _newContainerListFuture() async {
    final shell = Shell();

    final cmdResult = await shell.run(cmdDockerPs);
    final rawOutput = cmdResult[0].stdout;

    final containerStrings = (rawOutput as String).split("\n");
    containerStrings.removeLast();

    return containerStrings
        .map((e) => JsonDecoder().convert(e))
        .map((e) => ContainerInfo(e["Names"], e["ID"], e["State"], e["Image"]))
        .toList();
  }
}
