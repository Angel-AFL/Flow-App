import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  const SupabaseConfig({required this.url, required this.anonKey});

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<SupabaseConfig> load({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      return const SupabaseConfig(url: '', anonKey: '');
    }

    return SupabaseConfig(
      url: _read('SUPABASE_URL'),
      anonKey: _read('SUPABASE_ANON_KEY'),
    );
  }

  static String _read(String key) {
    try {
      return dotenv.env[key]?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
