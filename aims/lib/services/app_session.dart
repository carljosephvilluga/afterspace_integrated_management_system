class AppSession {
  AppSession._();

  static String? _token;
  static Map<String, dynamic>? _user;

  static String? get token => _token;

  static Map<String, dynamic>? get user {
    final currentUser = _user;
    if (currentUser == null) {
      return null;
    }
    return Map<String, dynamic>.from(currentUser);
  }

  static bool get isAuthenticated => (_token ?? '').isNotEmpty;

  static void saveAuth({
    required String token,
    required Map<String, dynamic> user,
  }) {
    _token = token;
    _user = Map<String, dynamic>.from(user);
  }

  static void clear() {
    _token = null;
    _user = null;
  }
}
