import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuração central de IDs de anúncios do Google Mobile Ads (AdMob).
///
/// >>> SUBSTITUA OS IDs DE PRODUÇÃO PELOS SEUS ANTES DE PUBLICAR. <<<
///
/// Enquanto [useTestAds] for `true`, o app usa os IDs de TESTE oficiais do
/// Google (seguros para desenvolvimento). NUNCA clique nos seus próprios
/// anúncios reais — isso pode banir sua conta AdMob.
///
/// O App ID também precisa ser configurado no AndroidManifest.xml
/// (meta-data com name="com.google.android.gms.ads.APPLICATION_ID").
class AdsConfig {
  AdsConfig._();

  /// Troque para `false` ao gerar o build de produção.
  static const bool useTestAds = true;

  // --- App ID (vai no AndroidManifest.xml) -----------------------------------
  // Teste:        ca-app-pub-3940256099942544~3347511713
  static const String androidAppIdProd = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';

  // --- IDs de produção (preencha aqui) ---------------------------------------
  static const String androidBannerProd = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidInterstitialProd = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String androidRewardedProd = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // --- IDs de teste oficiais do Google (não alterar) -------------------------
  static const String _androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTest = 'ca-app-pub-3940256099942544/1033173712';
  static const String _androidRewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  // iOS test ids (caso futuramente publique para iOS).
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTest = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosRewardedTest = 'ca-app-pub-3940256099942544/1712485313';

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static String get bannerId {
    if (useTestAds) return _isAndroid ? _androidBannerTest : _iosBannerTest;
    return androidBannerProd;
  }

  static String get interstitialId {
    if (useTestAds) {
      return _isAndroid ? _androidInterstitialTest : _iosInterstitialTest;
    }
    return androidInterstitialProd;
  }

  static String get rewardedId {
    if (useTestAds) return _isAndroid ? _androidRewardedTest : _iosRewardedTest;
    return androidRewardedProd;
  }
}
