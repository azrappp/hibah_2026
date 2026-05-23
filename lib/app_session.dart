import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession extends ChangeNotifier {
  String? clientId;
  String? screeningId;

  bool isLoaded = false;

  bool get hasClient => clientId != null && clientId!.isNotEmpty;
  bool get hasScreening => screeningId != null && screeningId!.isNotEmpty;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    clientId = prefs.getString('clientId');
    screeningId = prefs.getString('screeningId');

    isLoaded = true;
    notifyListeners();
  }

  Future<void> setClient({required String clientId}) async {
    this.clientId = clientId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clientId', clientId);

    notifyListeners();
  }

  Future<void> setScreening({required String screeningId}) async {
    this.screeningId = screeningId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('screeningId', screeningId);

    notifyListeners();
  }

  Future<void> setFlowData({
    required String clientId,
    required String screeningId,
  }) async {
    this.clientId = clientId;
    this.screeningId = screeningId;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clientId', clientId);
    await prefs.setString('screeningId', screeningId);

    notifyListeners();
  }

  Future<void> clear() async {
    clientId = null;
    screeningId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('clientId');
    await prefs.remove('screeningId');

    notifyListeners();
  }
}
