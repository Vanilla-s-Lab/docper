import 'package:flutter/material.dart';
import 'package:untitled/docker_status_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Demo')),
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

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Drawer(
        child: ListView(
          children: [
            Padding(padding: padding, child: DockerHeader()),
          ],
        ),
      ),
      VerticalDivider(),
    ]);
  }
}
