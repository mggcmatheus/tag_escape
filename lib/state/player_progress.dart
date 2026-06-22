import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../services/storage_service.dart';
import 'shop_items.dart';

/// Resultado de uma tentativa de compra na loja.
enum PurchaseResult { success, alreadyOwned, notEnoughCoins, invalid }

/// Estado de progressão persistente do jogador.
///
/// Responsabilidades: moedas, recorde, ranking local, partidas jogadas e
/// skins (posse + seleção). Todo acesso ao storage é feito aqui; a UI apenas
/// observa via [ChangeNotifier].
class PlayerProgress extends ChangeNotifier {
  PlayerProgress(this._storage) {
    _coins = _storage.coins;
    _highScore = _storage.highScore;
    _gamesPlayed = _storage.gamesPlayed;
    _leaderboard = _storage.leaderboard;
    _ownedSkins = _storage.ownedSkins.toSet();
    _selectedSkin = _storage.selectedSkin;
    _interstitialCounter = _storage.interstitialCounter;
  }

  final StorageService _storage;

  late int _coins;
  late int _highScore;
  late int _gamesPlayed;
  late List<int> _leaderboard;
  late Set<String> _ownedSkins;
  late String _selectedSkin;
  late int _interstitialCounter;

  int get coins => _coins;
  int get highScore => _highScore;
  int get gamesPlayed => _gamesPlayed;
  List<int> get leaderboard => List.unmodifiable(_leaderboard);
  Set<String> get ownedSkins => Set.unmodifiable(_ownedSkins);
  String get selectedSkinId => _selectedSkin;
  SkinItem get selectedSkin => ShopCatalog.byId(_selectedSkin);

  // --- Economia --------------------------------------------------------------

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    _coins += amount;
    await _storage.setCoins(_coins);
    notifyListeners();
  }

  // --- Fim de partida --------------------------------------------------------

  /// Registra o resultado de uma partida: incrementa contadores, credita
  /// moedas, atualiza recorde e ranking. Retorna `true` se foi novo recorde.
  Future<bool> registerGameResult({
    required int score,
    required int coinsEarned,
  }) async {
    _gamesPlayed += 1;
    await _storage.setGamesPlayed(_gamesPlayed);

    if (coinsEarned > 0) {
      _coins += coinsEarned;
      await _storage.setCoins(_coins);
    }

    // Atualiza ranking (Top N).
    _leaderboard = [..._leaderboard, score]
      ..sort((a, b) => b.compareTo(a));
    if (_leaderboard.length > GameConfig.leaderboardSize) {
      _leaderboard = _leaderboard.sublist(0, GameConfig.leaderboardSize);
    }
    await _storage.setLeaderboard(_leaderboard);

    final isNewRecord = score > _highScore;
    if (isNewRecord) {
      _highScore = score;
      await _storage.setHighScore(_highScore);
    }

    notifyListeners();
    return isNewRecord;
  }

  // --- Loja ------------------------------------------------------------------

  bool ownsSkin(String id) => _ownedSkins.contains(id);

  Future<PurchaseResult> buySkin(String id) async {
    final skin = ShopCatalog.skins.where((s) => s.id == id);
    if (skin.isEmpty) return PurchaseResult.invalid;
    if (_ownedSkins.contains(id)) return PurchaseResult.alreadyOwned;

    final price = skin.first.price;
    if (_coins < price) return PurchaseResult.notEnoughCoins;

    _coins -= price;
    _ownedSkins.add(id);
    await _storage.setCoins(_coins);
    await _storage.setOwnedSkins(_ownedSkins.toList());
    notifyListeners();
    return PurchaseResult.success;
  }

  Future<void> selectSkin(String id) async {
    if (!_ownedSkins.contains(id)) return;
    _selectedSkin = id;
    await _storage.setSelectedSkin(id);
    notifyListeners();
  }

  // --- Monetização: controle de intersticial ---------------------------------

  /// Incrementa o contador de partidas e decide se deve exibir intersticial.
  /// Regra: a cada [GameConfig.interstitialEveryNGames] partidas.
  Future<bool> shouldShowInterstitialAndAdvance() async {
    _interstitialCounter += 1;
    final show = _interstitialCounter % GameConfig.interstitialEveryNGames == 0;
    await _storage.setInterstitialCounter(_interstitialCounter);
    return show;
  }
}
