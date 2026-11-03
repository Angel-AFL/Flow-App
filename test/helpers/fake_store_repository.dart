import 'dart:async';

import 'package:flow_app/features/store/models/store_models.dart';
import 'package:flow_app/features/store/repositories/store_repository.dart';

const demoStoreItems = <StoreItem>[
  StoreItem(
    code: 'skin_classic',
    category: StoreItemCategory.skin,
    name: 'Clásico',
    description: 'El estilo original de Flow.',
    price: 0,
    rarity: StoreRarity.common,
    payload: {},
    sortOrder: 1,
    owned: true,
    quantity: 1,
    equipped: true,
  ),
  StoreItem(
    code: 'skin_pixel',
    category: StoreItemCategory.skin,
    name: 'Pixel Art',
    description: 'Nodos cuadrados y paleta retro.',
    price: 120,
    rarity: StoreRarity.rare,
    payload: {},
    sortOrder: 2,
  ),
  StoreItem(
    code: 'skin_cyber',
    category: StoreItemCategory.skin,
    name: 'Cyber',
    description: 'Bordes neón y brillo futurista.',
    price: 200,
    rarity: StoreRarity.epic,
    payload: {},
    sortOrder: 3,
  ),
  StoreItem(
    code: 'title_novice',
    category: StoreItemCategory.title,
    name: 'Novato',
    description: 'El primer título de todo estudiante Flow.',
    price: 0,
    rarity: StoreRarity.common,
    payload: {'label': 'Novato', 'color': '#B6C8D9', 'icon': 'military_tech'},
    sortOrder: 10,
    owned: true,
    quantity: 1,
    equipped: true,
  ),
  StoreItem(
    code: 'title_explorer',
    category: StoreItemCategory.title,
    name: 'Explorador',
    description: 'Para quienes recorren la ruta.',
    price: 80,
    rarity: StoreRarity.rare,
    payload: {'label': 'Explorador', 'color': '#38BDF8', 'icon': 'explore'},
    sortOrder: 11,
  ),
  StoreItem(
    code: 'template_age',
    category: StoreItemCategory.diagram,
    name: 'Validar edad',
    description: 'Plantilla con decisión.',
    price: 90,
    rarity: StoreRarity.common,
    payload: {
      'title': 'Validar edad',
      'kind': 'decision',
      'decision_label': '¿Es mayor de edad?',
    },
    sortOrder: 20,
  ),
  StoreItem(
    code: 'consumable_streak_freeze',
    category: StoreItemCategory.consumable,
    name: 'Congelar racha',
    description: 'Protege tu racha durante un día.',
    price: 60,
    rarity: StoreRarity.rare,
    payload: {'effect': 'streak_freeze', 'amount': 1},
    sortOrder: 30,
  ),
  StoreItem(
    code: 'consumable_xp_boost',
    category: StoreItemCategory.consumable,
    name: 'XP x2 durante 24 h',
    description: 'Duplica el XP de tus lecciones.',
    price: 100,
    rarity: StoreRarity.epic,
    payload: {'effect': 'xp_boost', 'multiplier': 2, 'hours': 24},
    sortOrder: 31,
  ),
];

StoreSnapshot demoStoreSnapshot({
  int coins = 240,
  List<StoreItem> items = demoStoreItems,
  int streakFreezes = 0,
  DateTime? xpBoostUntil,
  DateTime? lastDailyRewardAt,
}) {
  return StoreSnapshot(
    coins: coins,
    items: items,
    streakFreezes: streakFreezes,
    xpBoostUntil: xpBoostUntil,
    lastDailyRewardAt: lastDailyRewardAt,
  );
}

class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({
    StoreSnapshot? snapshot,
    this.loadFailure,
    this.purchaseFailure,
    this.equipFailure,
    this.rewardFailure,
    this.templateFailure,
    this.consumableFailure,
  }) : snapshot = snapshot ?? demoStoreSnapshot();

  StoreSnapshot snapshot;
  StoreFailure? loadFailure;
  StoreFailure? purchaseFailure;
  StoreFailure? equipFailure;
  StoreFailure? rewardFailure;
  StoreFailure? templateFailure;
  StoreFailure? consumableFailure;

  Completer<StoreSnapshot>? pendingLoad;
  int loadCalls = 0;
  String? lastPurchasedCode;
  String? lastEquippedCode;
  String? lastTemplateCode;
  String? lastConsumableCode;
  String? lastLessonId;
  bool lessonAlreadyClaimed = false;

  @override
  Future<StoreSnapshot> loadStore(String userId) {
    loadCalls++;

    final failure = loadFailure;
    if (failure != null) {
      return Future.error(failure);
    }

    final pending = pendingLoad;
    if (pending != null) {
      return pending.future;
    }

    return Future.value(snapshot);
  }

  @override
  Future<StorePurchaseResult> purchaseItem({
    required String userId,
    required String itemCode,
  }) async {
    final failure = purchaseFailure;
    if (failure != null) {
      throw failure;
    }

    final item = snapshot.itemByCode(itemCode);
    if (item == null) {
      throw const StoreFailure('Este ítem ya no está disponible.');
    }

    if (item.price > snapshot.coins) {
      throw const StoreFailure('No tienes suficientes monedas Flow.');
    }

    if (item.owned && item.category != StoreItemCategory.consumable) {
      throw const StoreFailure('Ya tienes este ítem en tu inventario.');
    }

    lastPurchasedCode = itemCode;

    final quantity = item.owned ? item.quantity + 1 : 1;
    final items = snapshot.items
        .map(
          (entry) => entry.code == itemCode
              ? entry.copyWith(owned: true, quantity: quantity)
              : entry,
        )
        .toList();

    snapshot = snapshot.copyWith(
      coins: snapshot.coins - item.price,
      items: items,
    );

    return StorePurchaseResult(
      coins: snapshot.coins,
      itemCode: itemCode,
      quantity: quantity,
    );
  }

  @override
  Future<void> equipItem({
    required String userId,
    required String itemCode,
  }) async {
    final failure = equipFailure;
    if (failure != null) {
      throw failure;
    }

    final item = snapshot.itemByCode(itemCode);
    if (item == null || !item.owned) {
      throw const StoreFailure('Primero debes comprar este ítem.');
    }

    lastEquippedCode = itemCode;

    final items = snapshot.items
        .map(
          (entry) => entry.category == item.category
              ? entry.copyWith(equipped: entry.code == itemCode)
              : entry,
        )
        .toList();

    snapshot = snapshot.copyWith(items: items);
  }

  @override
  Future<StoreRewardResult> claimDailyReward(String userId) async {
    final failure = rewardFailure;
    if (failure != null) {
      throw failure;
    }

    if (!snapshot.canClaimDailyReward) {
      throw const StoreFailure('El cofre diario todavía no está listo.');
    }

    snapshot = snapshot.copyWith(
      coins: snapshot.coins + 25,
      lastDailyRewardAt: DateTime.now(),
    );

    return StoreRewardResult(coins: snapshot.coins, coinsAwarded: 25);
  }

  @override
  Future<StoreRewardResult> claimLessonReward({
    required String userId,
    required String lessonId,
  }) async {
    final failure = rewardFailure;
    if (failure != null) {
      throw failure;
    }

    lastLessonId = lessonId;

    if (lessonAlreadyClaimed) {
      return StoreRewardResult(coins: snapshot.coins, alreadyClaimed: true);
    }

    lessonAlreadyClaimed = true;
    snapshot = snapshot.copyWith(coins: snapshot.coins + 25);

    return StoreRewardResult(
      coins: snapshot.coins,
      xpAwarded: 50,
      coinsAwarded: 25,
    );
  }

  @override
  Future<String> useDiagramTemplate({
    required String userId,
    required String itemCode,
  }) async {
    final failure = templateFailure;
    if (failure != null) {
      throw failure;
    }

    lastTemplateCode = itemCode;

    return 'template-diagram-id';
  }

  @override
  Future<StoreConsumableResult> useConsumable({
    required String userId,
    required String itemCode,
  }) async {
    final failure = consumableFailure;
    if (failure != null) {
      throw failure;
    }

    final item = snapshot.itemByCode(itemCode);
    if (item == null || !item.owned || item.quantity <= 0) {
      throw const StoreFailure('Primero debes comprar este ítem.');
    }

    lastConsumableCode = itemCode;
    final remaining = item.quantity - 1;
    final items = snapshot.items
        .map(
          (entry) => entry.code == itemCode
              ? entry.copyWith(owned: remaining > 0, quantity: remaining)
              : entry,
        )
        .toList();

    snapshot = snapshot.copyWith(items: items);

    return StoreConsumableResult(
      effect: item.consumable?.effect ?? ConsumableEffect.streakFreeze,
      remaining: remaining,
    );
  }
}
