import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager {
  static final SharedPrefManager _instance = SharedPrefManager._internal();

  factory SharedPrefManager() => _instance;

  SharedPrefManager._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String isLoggedInKey = 'is_logged_in';
  static const String userTokenKey = 'user_token';
  static const String userFullNameKey = 'user_full_name';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userPhoneKey = 'user_phone';
  static const String userProfileImageKey = 'user_profile_image';
  static const String userPasswordKey = 'user_password';
  static const String rememberMeKey = 'remember_me';
  static const String checkInTimeKey = 'check_in_time';
  static const String checkOutTimeKey = 'check_out_time';

  // Ensure prefs are available
  Future<SharedPreferences> get _instancePrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  // General Setters
  Future<void> setString(String key, String value) async {
    final prefs = await _instancePrefs;
    await prefs.setString(key, value);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await _instancePrefs;
    await prefs.setInt(key, value);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await _instancePrefs;
    await prefs.setBool(key, value);
  }

  Future<void> setDouble(String key, double value) async {
    final prefs = await _instancePrefs;
    await prefs.setDouble(key, value);
  }

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await _instancePrefs;
    await prefs.setStringList(key, value);
  }

  // General Getters
  Future<String?> getString(String key) async {
    final prefs = await _instancePrefs;
    return prefs.getString(key);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _instancePrefs;
    return prefs.getInt(key);
  }

  Future<bool> getBool(String key) async {
    final prefs = await _instancePrefs;
    return prefs.getBool(key) ?? false;
  }

  Future<double?> getDouble(String key) async {
    final prefs = await _instancePrefs;
    return prefs.getDouble(key);
  }

  Future<List<String>?> getStringList(String key) async {
    final prefs = await _instancePrefs;
    return prefs.getStringList(key);
  }

  // Specific
  Future<void> setLoggedIn(bool value) async =>
      await setBool(isLoggedInKey, value);

  Future<bool> isLoggedIn() async => await getBool(isLoggedInKey);

  Future<void> setUserToken(String token) async =>
      await setString(userTokenKey, token);

  Future<String?> getUserToken() async => await getString(userTokenKey);

  // Clear all
  Future<void> clearAll() async {
    final prefs = await _instancePrefs;
    await prefs.clear();
  }

  // Remove specific key
  Future<void> removeKey(String key) async {
    final prefs = await _instancePrefs;
    await prefs.remove(key);
  }
}
