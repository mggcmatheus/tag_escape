import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ads/ad_manager.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'state/missions_controller.dart';
import 'state/player_progress.dart';
import 'state/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trava em retrato e mantém o jogo em tela cheia (melhor para hypercasual).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Flame.device.fullScreen();

  // Inicializa persistência antes de montar a árvore (providers dependem dela).
  final storage = await StorageService.create();

  // Inicializa os anúncios em paralelo; não bloqueia o boot do jogo.
  unawaited(AdManager.instance.init());

  runApp(TapEscapeApp(storage: storage));
}

class TapEscapeApp extends StatelessWidget {
  const TapEscapeApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // O storage é compartilhado por todos os controllers.
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => SettingsController(storage)),
        ChangeNotifierProvider(create: (_) => PlayerProgress(storage)),
        ChangeNotifierProvider(create: (_) => MissionsController(storage)),
      ],
      child: MaterialApp(
        title: 'Tap Escape',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
