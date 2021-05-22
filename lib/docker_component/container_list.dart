import 'dart:convert';
import 'dart:core';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';
import 'package:untitled/docker_component/pojos/events.dart';

class DockerContainerList extends StatefulWidget {
  final EventBus _eventBus;
  final EventBus _expandedBus;

  const DockerContainerList(this._eventBus, this._expandedBus, {Key key})
      : super(key: key);

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
    final loading = Expanded(child: Center(child: CircularProgressIndicator()));

    // https://fluttercentral.com/Articles/Post/1272/How_to_show_an_empty_widget_in_flutter
    if (_dockerIsRunning) {
      final _containerListFuture = _newContainerListFuture();

      return FutureBuilder(
        future: _containerListFuture,
        builder: (buildContext, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final containerData = snapshot.data as List<ContainerInfo>;
            if (containerData.isEmpty) {
              return Text("No container found. ", textAlign: TextAlign.center);
            }

            final containerInfoTiles = containerData.map((e) => ListTile(
                  leading: Icon(
                    Icons.layers,
                    color: e.isRunning() ? Colors.green : null,
                  ),
                  title: Text(e.names),
                  subtitle: Text(e.status),
                  onTap: () => widget._expandedBus.fire(TapContainerEvent(e)),
                  trailing: Icon(Icons.arrow_right),
                  dense: true,
                ));
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                child: Scrollbar(
                  child: ListView(
                    children: [
                      ...ListTile.divideTiles(
                        context: buildContext,
                        tiles: containerInfoTiles.toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return loading;
        },
      );
    }

    return loading;
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
        .map((e) => ContainerInfo(
            e["Names"], e["Status"], e["State"], e["ID"], e["Image"]))
        .toList();
  }
}
