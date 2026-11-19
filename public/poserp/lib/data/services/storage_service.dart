import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  static const String tokenKey = 'pos-token';
  static const String userKey = 'pos-user';

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  String? getToken() {
    return _box.read<String>(tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _box.write(tokenKey, token);
  }

  Future<void> removeToken() async {
    await _box.remove(tokenKey);
  }

  User? getUser() {
    final rawUser = _box.read<Map<String, dynamic>>(userKey);
    if (rawUser != null) {
      try {
        return User.fromJson(rawUser);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    await _box.write(userKey, user.toJson());
  }

  Future<void> removeUser() async {
    await _box.remove(userKey);
  }

  Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}
