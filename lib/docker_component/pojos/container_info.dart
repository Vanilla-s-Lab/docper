class ContainerInfo {
  String names;
  String status;

  String _state;

  ContainerInfo(this.names, this.status, this._state);

  bool isRunning() => this._state == "running";
}
