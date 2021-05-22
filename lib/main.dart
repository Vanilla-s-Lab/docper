import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/docker_component/container_list.dart';
import 'package:untitled/docker_component/status_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Docker file transfer helper')),
        body: MyHomePage(),
      ),
      // MyHomePage(title: 'Flutter Demo Home Page'),
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

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Drawer(
        child: ListView(
          padding: padding,
          children: [
            DockerHeader(_drawerBus),
            Divider(),
            DockerContainerList(_drawerBus)
          ],
        ),
      ),
      Expanded(child: Center(child: Text("Tap any container to view files. ")))
    ]);
  }
}
