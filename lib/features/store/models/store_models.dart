import '../../../shared/models/diagram_skin.dart';
import '../../../shared/models/diagram_spec.dart';
import '../../../shared/models/profile_title.dart';

enum StoreItemCategory { skin, title, diagram, consumable }

enum StoreRarity { common, rare, epic, legendary }

enum ConsumableEffect { streakFreeze, xpBoost }

class ConsumableInfo {
  const ConsumableInfo({
    required this.effect,
    this.amount = 1,
    this.multiplier = 2,
    this.hours = 24,
  });

  final ConsumableEffect effect;
  final int amount;
  final int multiplier;
  final int hours;
}

class StoreItem {
  const StoreItem({
    required this.code,
    required this.category,
    required this.name,
    required this.price,
    required this.rarity,
    required this.payload,
    required this.sortOrder,
    this.description,
    this.owned = false,
    this.quantity = 0,
    this.equipped = false,
  });

  final String code;
  final StoreItemCategory category;
  final String name;
  final String? description;
  final int price;
  final StoreRarity rarity;
  final Map<String, dynamic> payload;
  final int sortOrder;
  final bool owned;
  final int quantity;
  final bool equipped;

  DiagramSkin? get skin {
    if (category != StoreItemCategory.skin) {
      return null;
    }

    return DiagramSkin.fromPayload(code: code, name: name, payload: payload);
  }

  ProfileTitle? get title {
    if (category != StoreItemCategory.title) {
      return null;
    }

    return ProfileTitle.fromPayload(code: code, name: name, payload: payload);
  }

  DiagramSpec? get template {
    if (category != StoreItemCategory.diagram) {
      return null;
    }

    return DiagramSpec(
      type: payload['kind'] == 'decision'
          ? DiagramPreviewType.decision
          : DiagramPreviewType.linear,
      startLabel: _string('start_label', 'Inicio'),
      processLabel: _string('process_label', 'Mostrar mensaje'),
      decisionLabel: _string('decision_label', 'Es > 0'),
      yesLabel: _string('yes_label', 'Sí'),
      noLabel: _string('no_label', 'No'),
      endLabel: _string('end_label', 'Fin'),
    );
  }

  String get templateTitle => _string('title', name);

  ConsumableInfo? get consumable {
    if (category != StoreItemCategory.consumable) {
      return null;
    }

    final effect = payload['effect'] == 'xp_boost'
        ? ConsumableEffect.xpBoost
        : ConsumableEffect.streakFreeze;

    return ConsumableInfo(
      effect: effect,
      amount: _int('amount', 1),
      multiplier: _int('multiplier', 2),
      hours: _int('hours', 24),
    );
  }

  StoreItem copyWith({bool? owned, int? quantity, bool? equipped}) {
    return StoreItem(
      code: code,
      category: category,
      name: name,
      description: description,
      price: price,
      rarity: rarity,
      payload: payload,
      sortOrder: sortOrder,
      owned: owned ?? this.owned,
      quantity: quantity ?? this.quantity,
      equipped: equipped ?? this.equipped,
    );
  }

  String _string(String key, String fallback) {
    final value = payload[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return fallback;
  }

  int _int(String key, int fallback) {
    final value = payload[key];

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }

    return fallback;
  }
}

class StoreSnapshot {
  const StoreSnapshot({
    required this.coins,
    required this.items,
    this.streakFreezes = 0,
    this.xpBoostUntil,
    this.lastDailyRewardAt,
  });

  final int coins;
  final List<StoreItem> items;
  final int streakFreezes;
  final DateTime? xpBoostUntil;
  final DateTime? lastDailyRewardAt;

  List<StoreItem> itemsFor(StoreItemCategory category) {
    return items.where((item) => item.category == category).toList();
  }

  StoreItem? itemByCode(String code) {
    for (final item in items) {
      if (item.code == code) {
        return item;
      }
    }

    return null;
  }

  StoreItem? get equippedSkin {
    for (final item in items) {
      if (item.category == StoreItemCategory.skin && item.equipped) {
        return item;
      }
    }

    return null;
  }

  StoreItem? get equippedTitle {
    for (final item in items) {
      if (item.category == StoreItemCategory.title && item.equipped) {
        return item;
      }
    }

    return null;
  }

  bool get xpBoostActive {
    final until = xpBoostUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  bool get canClaimDailyReward {
    final last = lastDailyRewardAt;

    if (last == null) {
      return true;
    }

    return DateTime.now().difference(last) >= const Duration(hours: 24);
  }

  StoreSnapshot copyWith({
    int? coins,
    List<StoreItem>? items,
    int? streakFreezes,
    DateTime? xpBoostUntil,
    DateTime? lastDailyRewardAt,
    bool clearXpBoost = false,
    bool clearLastDailyReward = false,
  }) {
    return StoreSnapshot(
      coins: coins ?? this.coins,
      items: items ?? this.items,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      xpBoostUntil: clearXpBoost ? null : xpBoostUntil ?? this.xpBoostUntil,
      lastDailyRewardAt: clearLastDailyReward
          ? null
          : lastDailyRewardAt ?? this.lastDailyRewardAt,
    );
  }
}

class StorePurchaseResult {
  const StorePurchaseResult({
    required this.coins,
    required this.itemCode,
    required this.quantity,
  });

  final int coins;
  final String itemCode;
  final int quantity;
}

class StoreRewardResult {
  const StoreRewardResult({
    required this.coins,
    this.xpAwarded = 0,
    this.coinsAwarded = 0,
    this.alreadyClaimed = false,
  });

  final int coins;
  final int xpAwarded;
  final int coinsAwarded;
  final bool alreadyClaimed;
}

class StoreConsumableResult {
  const StoreConsumableResult({required this.effect, required this.remaining});

  final ConsumableEffect effect;
  final int remaining;
}
