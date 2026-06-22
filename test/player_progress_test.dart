import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_escape/services/storage_service.dart';
import 'package:tap_escape/state/player_progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PlayerProgress> build() async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    return PlayerProgress(storage);
  }

  group('PlayerProgress', () {
    test('credita moedas e detecta novo recorde no fim de partida', () async {
      final p = await build();
      expect(p.highScore, 0);
      expect(p.coins, 0);

      final isRecord = await p.registerGameResult(score: 200, coinsEarned: 10);

      expect(isRecord, isTrue);
      expect(p.highScore, 200);
      expect(p.coins, 10);
      expect(p.gamesPlayed, 1);
      expect(p.leaderboard, contains(200));
    });

    test('ranking mantém ordem decrescente e tamanho máximo', () async {
      final p = await build();
      for (var i = 1; i <= 15; i++) {
        await p.registerGameResult(score: i * 10, coinsEarned: 0);
      }
      final board = p.leaderboard;
      expect(board.length, 10);
      expect(board.first, 150);
      // Ordenado de forma decrescente.
      for (var i = 0; i < board.length - 1; i++) {
        expect(board[i] >= board[i + 1], isTrue);
      }
    });

    test('compra de skin respeita saldo e posse', () async {
      final p = await build();
      // Sem moedas: não pode comprar a skin magenta (150).
      expect(await p.buySkin('magenta'), PurchaseResult.notEnoughCoins);

      await p.addCoins(200);
      expect(await p.buySkin('magenta'), PurchaseResult.success);
      expect(p.coins, 50);
      expect(p.ownsSkin('magenta'), isTrue);

      // Comprar de novo retorna alreadyOwned (não desconta).
      expect(await p.buySkin('magenta'), PurchaseResult.alreadyOwned);
      expect(p.coins, 50);
    });

    test('intersticial a cada 3 partidas', () async {
      final p = await build();
      expect(await p.shouldShowInterstitialAndAdvance(), isFalse); // 1
      expect(await p.shouldShowInterstitialAndAdvance(), isFalse); // 2
      expect(await p.shouldShowInterstitialAndAdvance(), isTrue); // 3
      expect(await p.shouldShowInterstitialAndAdvance(), isFalse); // 4
    });
  });
}
