import 'package:untitled/docker_component/pojos/container_file.dart';
import 'package:untitled/docker_component/pojos/container_info.dart';

class DockerIsRunningEvent {
  DockerIsRunningEvent();
}

class TapContainerEvent {
  ContainerInfo containerInfo;

  TapContainerEvent(this.containerInfo);
}

class RefreshAllEvent {
  RefreshAllEvent();
}

class TapFileEvent {
  ContainerFile containerFile;

  TapFileEvent(this.containerFile);
}
