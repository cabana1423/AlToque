import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorages {
  static final _storage = new FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyId = 'id';
  static const _keyTokenFB = 'tokenFB';

  //  ESCRIBIR

  static Future<void> setEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  static Future<void> setId(String pass) async {
    await _storage.write(key: _keyId, value: pass);
  }

  static Future<void> setTokenFB(String tokenFB) async {
    await _storage.write(key: _keyTokenFB, value: tokenFB);
  }

  //LEER

  static Future<String> getEmail() async {
    return await _storage.read(key: _keyEmail) ?? '';
  }

  static Future<String> getId() async {
    return await _storage.read(key: _keyId) ?? '';
  }

  static Future<String> getTokenFB() async {
    return await _storage.read(key: _keyTokenFB) ?? '';
  }

  //eliminar
  static Future<void> delEmail() async {
    await _storage.delete(key: _keyEmail);
  }

  static Future<void> delId() async {
    await _storage.delete(key: _keyId);
  }

  static Future<void> delTokenFB() async {
    await _storage.delete(key: _keyTokenFB);
    print('eliminado');
  }

  // GUARDAR BRILLO crear/ eliminar /leer
  static const theme = 'themeG';
  static Future<void> setTheme(bool _theme) async {
    await _storage.write(key: theme, value: _theme.toString());
  }

  static Future<String> GetTheme() async {
    return await _storage.read(key: theme) ?? '';
  }

  static Future<void> delTheme() async {
    await _storage.delete(key: theme);
  }
}
