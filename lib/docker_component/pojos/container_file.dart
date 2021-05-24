import 'dart:io';

class ContainerFile {
  // https://www.gnu.org/software/coreutils/manual/html_node/What-information-is-listed.html#index-long-ls-format
  String fileType;
  String fileName;

  ContainerFile(this.fileType, this.fileName);

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
