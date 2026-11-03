import 'package:image_picker/image_picker.dart';

import '../models/profile_models.dart';

typedef PickProfileImage = Future<PickedProfileImage?> Function();

Future<PickedProfileImage?> pickProfileImageFromGallery() async {
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

  final bytes = await pickedFile.readAsBytes();

  return PickedProfileImage(
    bytes: bytes,
    extension: _extensionFor(pickedFile.name),
    mimeType: pickedFile.mimeType,
  );
}

String _extensionFor(String name) {
  final dotIndex = name.lastIndexOf('.');

  if (dotIndex == -1 || dotIndex == name.length - 1) {
    return 'jpg';
  }

  final extension = name.substring(dotIndex + 1).toLowerCase();
  const supported = {'jpg', 'jpeg', 'png', 'webp', 'gif'};

  return supported.contains(extension) ? extension : 'jpg';
}
