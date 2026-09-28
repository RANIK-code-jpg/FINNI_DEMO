import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String gameStateKey = 'game_state';

  Future<void> saveGameState(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = jsonEncode(data);

    await prefs.setString(
      gameStateKey,
      jsonString,
    );
  }

  Future<Map<String, dynamic>?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(gameStateKey);

    if (jsonString == null) {
      return null;
    }

    final data = jsonDecode(jsonString);

    return Map<String, dynamic>.from(data);
  }

  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(gameStateKey);
  }
}