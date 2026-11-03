import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/supabase_auth_repository.dart';
import 'core/config/missing_supabase_config_app.dart';
import 'core/config/supabase_config.dart';
import 'features/profile/repositories/supabase_profile_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = await SupabaseConfig.load();

  if (!config.isConfigured) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  try {
    await Supabase.initialize(url: config.url, publishableKey: config.anonKey);
  } catch (_) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  runApp(
    FlowApp(
      authRepository: SupabaseAuthRepository(Supabase.instance.client),
      profileRepository: SupabaseProfileRepository(Supabase.instance.client),
    ),
  );
}
