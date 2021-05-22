import 'package:untitled/docker_component/pojos/container_info.dart';

class DockerIsRunningEvent {
  DockerIsRunningEvent();
}

class TapContainerEvent {
  ContainerInfo containerInfo;

  TapContainerEvent(this.containerInfo);
}
