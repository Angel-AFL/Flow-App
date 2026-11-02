import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

typedef PickProfileImage = Future<Uint8List?> Function();

Future<Uint8List?> pickProfileImageFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
    requestFullMetadata: false,
  );

  if (pickedFile == null) {
    return null;
  }

  return pickedFile.readAsBytes();
}
