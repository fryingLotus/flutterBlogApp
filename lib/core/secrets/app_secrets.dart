import 'dart:io';

class AppSecrets {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const webClientId = String.fromEnvironment('WEB_CLIENT_ID');
  static const iosClientId = String.fromEnvironment('IOS_CLIENT_ID');
}
