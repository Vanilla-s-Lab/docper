class ContainerInfo {
  String names;
  String status;

  String _state;

  String id;
  String images;

  ContainerInfo(this.names, this.status, this._state, this.id, this.images);

  bool isRunning() => this._state == "running";
}
