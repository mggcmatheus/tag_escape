import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Gerencia o ciclo de vida dos anúncios (intersticial e rewarded).
///
/// O banner é tratado diretamente em um widget (`BannerAdWidget`) porque ele
/// precisa estar ligado à árvore de widgets. Aqui ficam os anúncios de tela
/// cheia, que são pré-carregados e exibidos sob demanda.
///
/// Princípio adotado: anúncios que falham nunca devem travar o jogo. Todos os
/// callbacks são opcionais e o app segue funcionando offline.
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  bool _initialized = false;

  /// Inicializa o SDK do Google Mobile Ads. Idempotente.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    // Pré-carrega para que o primeiro anúncio apareça sem atraso.
    _loadInterstitial();
    _loadRewarded();
  }

  // --- Intersticial ----------------------------------------------------------

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdsConfig.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
            // Recarrega para a próxima exibição assim que este for fechado.
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitial = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitial = null;
          debugPrint('Intersticial falhou ao carregar: $error');
        },
      ),
    );
  }

  /// Exibe o intersticial se estiver pronto. Retorna `true` se mostrou.
  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial(); // Tenta deixar pronto para a próxima vez.
      return false;
    }
    _interstitial = null;
    ad.show();
    return true;
  }

  // --- Rewarded (reviver) ----------------------------------------------------

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdsConfig.rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _rewarded!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewarded = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewarded = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewarded = null;
          debugPrint('Rewarded falhou ao carregar: $error');
        },
      ),
    );
  }

  /// Indica se há um rewarded pronto para exibir (para mostrar/esconder o botão).
  bool get isRewardedReady => _rewarded != null;

  /// Exibe o rewarded. Chama [onReward] somente se o usuário ganhou a recompensa.
  /// Retorna `true` se o anúncio chegou a ser exibido.
  Future<bool> showRewarded({required VoidCallback onReward}) async {
    final ad = _rewarded;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewarded = null;
    bool earned = false;
    ad.show(
      onUserEarnedReward: (_, __) {
        earned = true;
      },
    );
    // O callback de recompensa é síncrono dentro do show; aplicamos depois.
    // Usamos o fullScreenContentCallback já configurado para o dispose.
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
        if (earned) onReward();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewarded = null;
        _loadRewarded();
      },
    );
    return true;
  }

  void dispose() {
    _interstitial?.dispose();
    _rewarded?.dispose();
    _interstitial = null;
    _rewarded = null;
  }
}
