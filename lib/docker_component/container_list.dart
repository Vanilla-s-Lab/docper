import 'dart:convert';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';
import 'package:untitled/docker_component/pojos/events.dart';

class DockerContainerList extends StatefulWidget {
  final EventBus _eventBus;

  const DockerContainerList(this._eventBus, {Key key}) : super(key: key);

  @override
  _DockerContainerListState createState() => _DockerContainerListState();
}

class _DockerContainerListState extends State<DockerContainerList> {
  bool _dockerIsRunning = false;

  @override
  void initState() {
    super.initState();
    widget._eventBus.on<DockerIsRunningEvent>().listen((_) {
      setState(() => _dockerIsRunning = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // https://fluttercentral.com/Articles/Post/1272/How_to_show_an_empty_widget_in_flutter
    if (!_dockerIsRunning) {
      return SizedBox.shrink();
    } else {
      final _containerListFuture = _newContainerListFuture();

      return ListView(
        // https://stackoverflow.com/questions/50252569/vertical-viewport-was-given-unbounded-height
        shrinkWrap: true,
        children: [
          FutureBuilder(
            future: _containerListFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text("Fatal error: ${snapshot.data}. ");
                } else {
                  final containerData = snapshot.data as List<ContainerInfo>;
                  if (containerData.isEmpty) {
                    return Text("No container found. ",
                        textAlign: TextAlign.center);
                  }

                  final containerInfoTiles = containerData.map((e) => ListTile(
                        leading: Icon(
                          Icons.layers,
                          color: e.isRunning() ? Colors.green : null,
                        ),
                        title: Text(e.names),
                        subtitle: Text(e.status),
                        onTap: () {},
                        trailing: Icon(Icons.arrow_right),
                      ));

                  return ListView(shrinkWrap: true, children: [
                    Text("Container list", textAlign: TextAlign.center),
                    ...ListTile.divideTiles(
                        context: context,
                        tiles: containerInfoTiles.toList().reversed)
                  ]);
                }
              }

              return Text("loading... ", textAlign: TextAlign.center);
            },
          ),
        ],
      );
    }
  }

  static const DOCKER_PS_CMD = "docker ps -a --format '{{json .}}'";

  Future<List<ContainerInfo>> _newContainerListFuture() async {
    final shell = Shell();

    final cmdResult = await shell.run(DOCKER_PS_CMD);
    final rawOutput = cmdResult[0].stdout;

    final containerStrings = (rawOutput as String).split("\n");
    containerStrings.removeLast();

    return containerStrings
        .map((e) => JsonDecoder().convert(e))
        .map((e) => ContainerInfo(e["Names"], e["Status"], e["State"]))
        .toList();
  }
}
