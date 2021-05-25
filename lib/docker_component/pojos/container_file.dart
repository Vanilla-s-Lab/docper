import 'dart:io';

class ContainerFile {
  // https://www.gnu.org/software/coreutils/manual/html_node/What-information-is-listed.html#index-long-ls-format
  String fileType;
  String fileName;

  List<String> rawData;

  ContainerFile(this.fileType, this.fileName, this.rawData);

  FileSystemEntityType type() {
    switch (fileType) {
      case "-":
        return FileSystemEntityType.file;
      case "d":
        return FileSystemEntityType.directory;
    }

    return FileSystemEntityType.notFound;
  }
}
