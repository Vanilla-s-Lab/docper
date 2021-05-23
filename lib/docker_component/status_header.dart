import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell_run.dart';
import 'package:untitled/docker_component/pojos/events.dart';
import 'package:untitled/docker_finder.dart';

class DockerHeader extends StatefulWidget {
  final EventBus _drawerBus;

  const DockerHeader(this._drawerBus, {Key key}) : super(key: key);

  @override
  _DockerHeaderState createState() => _DockerHeaderState();
}

class _DockerHeaderState extends State<DockerHeader> {
  Future<String> _currentDockerVerFuture;

  @override
  void initState() {
    super.initState();
    _currentDockerVerFuture = _newDockerVerFuture();

    widget._drawerBus.on<RefreshAllEvent>().listen((event) {
      setState(() => {_currentDockerVerFuture = _newDockerVerFuture()});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: _currentDockerVerFuture,
          builder: (BuildContext buildContext, AsyncSnapshot<String> snapshot) {
            // https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                // https://stackoverflow.com/questions/10247073/urlencoding-in-dart
                final e = Uri.decodeFull(snapshot.error.toString());

                // https://stackoverflow.com/questions/52059024/show-dialog-on-widget
                Future.delayed(Duration.zero, () => _showErr(buildContext, e));
              } else {
                // Success connected to docker.
                widget._drawerBus.fire(new DockerIsRunningEvent());
                return Text("Docker connected, version: ${snapshot.data}. ",
                    textAlign: TextAlign.center);
              }
            }

            return Text("Connecting docker, please wait... ",
                textAlign: TextAlign.center);
          }),
    );
  }

  final cmdDockerVersion = "${dockerCommand()} version --format '{{json .}}'";

  Future<String> _newDockerVerFuture() async {
    final shell = Shell();

    try {
      final cmdResult = await shell.run(cmdDockerVersion);
      final resultJsonString = cmdResult[0].stdout;

      final cmdJson = JsonDecoder().convert(resultJsonString);
      return cmdJson["Client"]["Version"];
    } on ShellException catch (se) {
      final errMessage = se.result.stderr;
      return Future.error(Exception(errMessage));
    }
  }

  void _showErr(BuildContext context, String errMessage) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
                title: Text("Cannot connect to Docker"),
                content: Text(errMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      // https://stackoverflow.com/questions/50683524/how-to-dismiss-flutter-dialog
                      Navigator.pop(context);
                      this.setState(() {
                        this._currentDockerVerFuture = _newDockerVerFuture();
                      });
                    },
                    child: Text("Retry"),
                  ),
                  TextButton(onPressed: () => exit(0), child: Text("Exit"))
                ]));
  }
}
