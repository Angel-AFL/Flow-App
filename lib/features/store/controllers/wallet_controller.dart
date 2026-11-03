import 'package:flutter/foundation.dart';

import '../repositories/store_repository.dart';

class WalletController extends ChangeNotifier {
  WalletController({
    required this.repository,
    required this.userId,
    int initialCoins = 240,
  }) : _coins = initialCoins;

  final StoreRepository repository;
  final String userId;

  int _coins;
  bool _isLoading = false;

  int get coins => _coins;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await repository.loadStore(userId);
      _coins = snapshot.coins;
    } catch (_) {
      // El saldo inicial se mantiene visible si falla la red.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCoins(int coins) {
    if (_coins == coins) {
      return;
    }

    _coins = coins;
    notifyListeners();
  }
}
