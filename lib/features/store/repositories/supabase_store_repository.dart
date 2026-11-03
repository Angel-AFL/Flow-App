import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/store_models.dart';
import 'store_repository.dart';

class SupabaseStoreRepository implements StoreRepository {
  SupabaseStoreRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<StoreSnapshot> loadStore(String userId) async {
    try {
      final results = await Future.wait<dynamic>([
        _client
            .from('store_items')
            .select()
            .eq('is_active', true)
            .order('sort_order'),
        _client
            .from('user_inventory')
            .select('item_code, quantity')
            .eq('user_id', userId),
        _client
            .from('profiles')
            .select(
              'coins, equipped_skin_code, equipped_title_code, '
              'streak_freezes, xp_boost_until, last_daily_reward_at',
            )
            .eq('id', userId)
            .single(),
      ]);

      final itemRows = (results[0] as List).cast<Map<String, dynamic>>();
      final inventoryRows = (results[1] as List).cast<Map<String, dynamic>>();
      final profileRow = results[2] as Map<String, dynamic>;

      final inventory = <String, int>{
        for (final row in inventoryRows)
          row['item_code'] as String: (row['quantity'] as num? ?? 1).toInt(),
      };

      final equippedSkin = profileRow['equipped_skin_code'] as String?;
      final equippedTitle = profileRow['equipped_title_code'] as String?;

      final items = itemRows.map((row) {
        final code = row['code'] as String;
        final category = _categoryFrom(row['category'] as String?);

        return StoreItem(
          code: code,
          category: category,
          name: row['name'] as String? ?? 'Ítem Flow',
          description: row['description'] as String?,
          price: (row['price'] as num?)?.toInt() ?? 0,
          rarity: _rarityFrom(row['rarity'] as String?),
          payload: (row['payload'] as Map?)?.cast<String, dynamic>() ?? {},
          sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
          owned: inventory.containsKey(code),
          quantity: inventory[code] ?? 0,
          equipped:
              (category == StoreItemCategory.skin && code == equippedSkin) ||
              (category == StoreItemCategory.title && code == equippedTitle),
        );
      }).toList();

      return StoreSnapshot(
        coins: (profileRow['coins'] as num?)?.toInt() ?? 0,
        items: items,
        streakFreezes: (profileRow['streak_freezes'] as num?)?.toInt() ?? 0,
        xpBoostUntil: _dateFrom(profileRow['xp_boost_until']),
        lastDailyRewardAt: _dateFrom(profileRow['last_daily_reward_at']),
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos cargar la tienda. Inténtalo de nuevo.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<StorePurchaseResult> purchaseItem({
    required String userId,
    required String itemCode,
  }) async {
    try {
      final data = await _client.rpc(
        'purchase_store_item',
        params: {'p_item_code': itemCode},
      );
      final row = _firstRow(data);

      return StorePurchaseResult(
        coins: (row['coins'] as num?)?.toInt() ?? 0,
        itemCode: row['item_code'] as String? ?? itemCode,
        quantity: (row['quantity'] as num?)?.toInt() ?? 1,
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos completar la compra. Inténtalo de nuevo.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<void> equipItem({
    required String userId,
    required String itemCode,
  }) async {
    try {
      await _client.rpc('equip_store_item', params: {'p_item_code': itemCode});
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos equipar el ítem. Inténtalo de nuevo.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<StoreRewardResult> claimDailyReward(String userId) async {
    try {
      final data = await _client.rpc('claim_daily_reward');
      final row = _firstRow(data);

      return StoreRewardResult(
        coins: (row['coins'] as num?)?.toInt() ?? 0,
        coinsAwarded: (row['reward'] as num?)?.toInt() ?? 0,
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos reclamar el cofre. Inténtalo de nuevo.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<StoreRewardResult> claimLessonReward({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final data = await _client.rpc(
        'claim_lesson_reward',
        params: {'p_lesson_id': lessonId},
      );
      final row = _firstRow(data);

      return StoreRewardResult(
        coins: (row['coins'] as num?)?.toInt() ?? 0,
        xpAwarded: (row['xp_awarded'] as num?)?.toInt() ?? 0,
        coinsAwarded: (row['coins_awarded'] as num?)?.toInt() ?? 0,
        alreadyClaimed: row['already_claimed'] == true,
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos guardar la recompensa de la lección.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<String> useDiagramTemplate({
    required String userId,
    required String itemCode,
  }) async {
    try {
      final data = await _client.rpc(
        'use_diagram_template',
        params: {'p_item_code': itemCode},
      );

      return _scalarString(data);
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos añadir la plantilla a tus diagramas.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  @override
  Future<StoreConsumableResult> useConsumable({
    required String userId,
    required String itemCode,
  }) async {
    try {
      final data = await _client.rpc(
        'use_consumable',
        params: {'p_item_code': itemCode},
      );
      final row = _firstRow(data);

      return StoreConsumableResult(
        effect: row['effect'] == 'xp_boost'
            ? ConsumableEffect.xpBoost
            : ConsumableEffect.streakFreeze,
        remaining: (row['remaining'] as num?)?.toInt() ?? 0,
      );
    } on PostgrestException catch (error) {
      throw _failureFor(
        error,
        fallback: 'No pudimos usar el consumible. Inténtalo de nuevo.',
      );
    } on StoreFailure {
      rethrow;
    } on AuthException {
      throw const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    } catch (_) {
      throw const StoreFailure(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  static Map<String, dynamic> _firstRow(dynamic data) {
    if (data is List) {
      if (data.isEmpty) {
        throw const StoreFailure('El servidor no devolvió una respuesta.');
      }

      return (data.first as Map).cast<String, dynamic>();
    }

    if (data is Map) {
      return data.cast<String, dynamic>();
    }

    throw const StoreFailure('El servidor no devolvió una respuesta.');
  }

  static String _scalarString(dynamic data) {
    if (data is String) {
      return data;
    }

    if (data is List && data.isNotEmpty && data.first is String) {
      return data.first as String;
    }

    if (data is Map && data['use_diagram_template'] is String) {
      return data['use_diagram_template'] as String;
    }

    throw const StoreFailure('El servidor no devolvió el diagrama creado.');
  }

  static StoreItemCategory _categoryFrom(String? value) {
    return switch (value) {
      'title' => StoreItemCategory.title,
      'diagram' => StoreItemCategory.diagram,
      'consumable' => StoreItemCategory.consumable,
      _ => StoreItemCategory.skin,
    };
  }

  static StoreRarity _rarityFrom(String? value) {
    return switch (value) {
      'rare' => StoreRarity.rare,
      'epic' => StoreRarity.epic,
      'legendary' => StoreRarity.legendary,
      _ => StoreRarity.common,
    };
  }

  static DateTime? _dateFrom(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static StoreFailure _failureFor(
    PostgrestException error, {
    required String fallback,
  }) {
    final message = error.message;

    if (message.contains('insufficient_coins')) {
      return const StoreFailure('No tienes suficientes monedas Flow.');
    }

    if (message.contains('already_owned')) {
      return const StoreFailure('Ya tienes este ítem en tu inventario.');
    }

    if (message.contains('item_not_owned')) {
      return const StoreFailure('Primero debes comprar este ítem.');
    }

    if (message.contains('item_unavailable')) {
      return const StoreFailure('Este ítem ya no está disponible.');
    }

    if (message.contains('reward_not_ready')) {
      return const StoreFailure('El cofre diario todavía no está listo.');
    }

    if (message.contains('not_authenticated')) {
      return const StoreFailure('Tu sesión expiró. Vuelve a iniciar sesión.');
    }

    if (message.contains('profile_not_found')) {
      return const StoreFailure(
        'No encontramos tu perfil. Vuelve a iniciar sesión.',
      );
    }

    return StoreFailure(fallback);
  }
}
