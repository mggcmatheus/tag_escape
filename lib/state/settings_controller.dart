import 'package:flutter/foundation.dart';

import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Controla as configurações do usuário (atualmente: áudio on/off).
///
/// Mantém o [AudioService] sincronizado com a preferência persistida.
class SettingsController extends ChangeNotifier {
  SettingsController(this._storage) {
    _soundEnabled = _storage.soundEnabled;
    AudioService.instance.enabled = _soundEnabled;
  }

  final StorageService _storage;

  late bool _soundEnabled;
  bool get soundEnabled => _soundEnabled;

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    AudioService.instance.enabled = value;
    await _storage.setSoundEnabled(value);
    notifyListeners();
  }

  void toggleSound() => setSoundEnabled(!_soundEnabled);
}
