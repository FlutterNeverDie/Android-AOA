import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MenuRepository {
  static const String fileName = 'menu_config.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<bool> saveMenuData(String jsonString) async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> loadMenuData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteMenuData() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
