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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // https://stackoverflow.com/questions/49015038/removing-the-drop-shadow-from-a-scaffold-appbar-in-flutter
      theme: ThemeData(appBarTheme: AppBarTheme(elevation: 0)),
      home: Scaffold(
        appBar: AppBar(title: Text('Docker file transfer helper')),
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
                  appBar: AppBar(title: Text("Container list")),
                  body: BorderedContainer(
                    child: DockerContainerList(_drawerBus, _expandedBus),
                  ),

                  // https://api.flutter.dev/flutter/material/FloatingActionButton-class.html
                  floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.refresh),
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
