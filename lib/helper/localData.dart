import 'package:shared_preferences/shared_preferences.dart';

class LocalData {

  LocalData._privateConstructor();
  static final LocalData instance = LocalData._privateConstructor();

  SharedPreferences _sp;

  final String login   = 'isLogin';
  final String google  = 'isFB';
  final String fb      = 'isGoogle';





  Future<void> initSP() async {
    if(_sp == null) _sp = await SharedPreferences.getInstance();
  }

  String getString(String key){
    return _sp == null ? null : _sp.getString(key) ?? null;
  }

  Future<bool> setString(String key, String data) async {
    return await _sp.setString(key, data);
  }

  bool getBool(String key) {
    return _sp == null ? false : _sp.getBool(key) ?? false;
  }

  Future<bool> setBool(String key, bool data) async {
    return await _sp.setBool(key, data);
  }

  Future<bool> clearAll() async {
    return await _sp.clear();
  }
}