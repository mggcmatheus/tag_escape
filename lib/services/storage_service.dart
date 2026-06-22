import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper fino e tipado sobre o SharedPreferences.
///
/// Mantém todas as chaves de persistência em um único lugar (evita strings
/// soltas e erros de digitação) e expõe getters/setters simples. Toda a
/// persistência do app passa por aqui — é a única classe que conhece o
/// SharedPreferences.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  /// Inicializa o SharedPreferences. Chame uma vez no boot do app.
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Chaves ----------------------------------------------------------------
  static const _kHighScore = 'high_score';
  static const _kCoins = 'coins';
  static const _kGamesPlayed = 'games_played';
  static const _kLeaderboard = 'leaderboard';
  static const _kOwnedSkins = 'owned_skins';
  static const _kSelectedSkin = 'selected_skin';
  static const _kSoundEnabled = 'sound_enabled';
  static const _kMissionsDate = 'missions_date';
  static const _kMissionsData = 'missions_data';
  static const _kInterstitialCounter = 'interstitial_counter';

  // --- Progresso -------------------------------------------------------------
  int get highScore => _prefs.getInt(_kHighScore) ?? 0;
  Future<void> setHighScore(int v) => _prefs.setInt(_kHighScore, v);

  int get coins => _prefs.getInt(_kCoins) ?? 0;
  Future<void> setCoins(int v) => _prefs.setInt(_kCoins, v);

  int get gamesPlayed => _prefs.getInt(_kGamesPlayed) ?? 0;
  Future<void> setGamesPlayed(int v) => _prefs.setInt(_kGamesPlayed, v);

  /// Ranking local salvo como lista de strings (pontuações).
  List<int> get leaderboard =>
      (_prefs.getStringList(_kLeaderboard) ?? const [])
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
  Future<void> setLeaderboard(List<int> scores) =>
      _prefs.setStringList(_kLeaderboard, scores.map((e) => '$e').toList());

  // --- Loja ------------------------------------------------------------------
  List<String> get ownedSkins =>
      _prefs.getStringList(_kOwnedSkins) ?? const ['default'];
  Future<void> setOwnedSkins(List<String> ids) =>
      _prefs.setStringList(_kOwnedSkins, ids);

  String get selectedSkin => _prefs.getString(_kSelectedSkin) ?? 'default';
  Future<void> setSelectedSkin(String id) =>
      _prefs.setString(_kSelectedSkin, id);

  // --- Configurações ---------------------------------------------------------
  bool get soundEnabled => _prefs.getBool(_kSoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool v) => _prefs.setBool(_kSoundEnabled, v);

  // --- Missões ---------------------------------------------------------------
  String? get missionsDate => _prefs.getString(_kMissionsDate);
  Future<void> setMissionsDate(String v) => _prefs.setString(_kMissionsDate, v);

  String? get missionsData => _prefs.getString(_kMissionsData);
  Future<void> setMissionsData(String json) =>
      _prefs.setString(_kMissionsData, json);

  // --- Monetização -----------------------------------------------------------
  int get interstitialCounter => _prefs.getInt(_kInterstitialCounter) ?? 0;
  Future<void> setInterstitialCounter(int v) =>
      _prefs.setInt(_kInterstitialCounter, v);
}
