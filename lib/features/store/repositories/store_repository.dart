import '../models/store_models.dart';

class StoreFailure implements Exception {
  const StoreFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'StoreFailure(${code ?? 'unknown'}): $message';
}

abstract interface class StoreRepository {
  Future<StoreSnapshot> loadStore(String userId);

  Future<StorePurchaseResult> purchaseItem({
    required String userId,
    required String itemCode,
  });

  Future<void> equipItem({required String userId, required String itemCode});

  Future<StoreRewardResult> claimDailyReward(String userId);

  Future<StoreRewardResult> claimLessonReward({
    required String userId,
    required String lessonId,
  });

  Future<String> useDiagramTemplate({
    required String userId,
    required String itemCode,
  });

  Future<StoreConsumableResult> useConsumable({
    required String userId,
    required String itemCode,
  });
}
