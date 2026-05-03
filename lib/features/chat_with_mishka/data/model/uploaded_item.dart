enum UploadType { file, pdf, image, video, article }

class UploadedItem {
  final String name;
  final UploadType type;

  UploadedItem({
    required this.name,
    required this.type,
  });
}
