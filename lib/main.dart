import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/bordered_container.dart';
import 'package:untitled/docker_component/expanded_file.dart';

import 'docker_component/container_list.dart';
import 'docker_component/pojos/events.dart';
import 'docker_component/status_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<ProcessResult> test() async {
    return await Process.run("docker version --format json", [],
        runInShell: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Docker - File Transfer Helper'),
          centerTitle: true,
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const padding = EdgeInsets.all(16.0);
  EventBus _drawerBus = EventBus();
  EventBus _expandedBus = EventBus();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Drawer(
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              DockerHeader(_drawerBus),
              Divider(),
              Expanded(
                child: Scaffold(
                  appBar: AppBar(
                    elevation: 0,
                    title: Text("Container List"),
                    centerTitle: true,
                  ),
                  body: BorderedContainer(
                    child: DockerContainerList(_drawerBus, _expandedBus),
                  ),

                  // https://api.flutter.dev/flutter/material/FloatingActionButton-class.html
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.refresh),
                    tooltip: "Refresh list",
                    onPressed: () {
                      _drawerBus.fire(RefreshAllEvent());
                      _expandedBus.fire(RefreshAllEvent());
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: padding,
          child: FileExplorer(_expandedBus),
        ),
      ),
    ]);
  }
}
