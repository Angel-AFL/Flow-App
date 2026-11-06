import '../models/profile_models.dart';

class ProfileFailure implements Exception {
  const ProfileFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'ProfileFailure(${code ?? 'unknown'}): $message';
}

abstract interface class ProfileRepository {
  Future<ProfileSnapshot> loadProfile(String userId);

  Future<ProfileStats> loadStats(String userId);

  Future<UserProfile> updateProfile({
    required String userId,
    required ProfileEdit edit,
  });

  Future<AvatarUploadResult> uploadAvatar({
    required String userId,
    required PickedProfileImage image,
  });
}
