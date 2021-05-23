class ContainerInfo {
  String names;
  String id;

  String _state;
  String images;

  ContainerInfo(this.names, this.id, this._state, this.images);

  bool isRunning() => this._state == "running";
}
