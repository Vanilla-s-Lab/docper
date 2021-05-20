import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:untitled/docker_component/docker_events.dart';

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
      return Text("Docker is running! I will loading container list here. ");
    }
  }
}
