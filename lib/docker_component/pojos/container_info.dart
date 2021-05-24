class ContainerInfo {
  String names;
  String image;

  String id;
  String _state;

  ContainerInfo(this.names, this.image, this.id, this._state);

  bool isRunning() => this._state == "running";
}
