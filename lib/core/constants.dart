/// Constantes globais de balanceamento e regras de negócio do jogo.
///
/// Centralizar aqui evita "números mágicos" espalhados pelo código e facilita
/// o tuning de dificuldade sem caçar valores em vários arquivos.
class GameConfig {
  GameConfig._();

  // --- Jogador ---------------------------------------------------------------
  /// Raio visual/colisão da esfera do jogador.
  static const double playerRadius = 18.0;

  /// Distância máxima de um dash (em pixels lógicos).
  static const double dashMaxDistance = 140.0;

  /// Velocidade do dash (px/s). Quanto maior, mais "instantâneo".
  static const double dashSpeed = 1400.0;

  /// Força com que a esfera é puxada de volta ao centro (px/s²).
  /// Mantém a ação concentrada no meio da tela.
  static const double recenterPull = 90.0;

  // --- Obstáculos ------------------------------------------------------------
  static const double obstacleMinRadius = 10.0;
  static const double obstacleMaxRadius = 26.0;

  /// Velocidade inicial dos obstáculos (px/s).
  static const double obstacleBaseSpeed = 130.0;

  /// Quanto a velocidade aumenta por segundo de jogo (px/s adicionais por s).
  static const double obstacleSpeedRampPerSecond = 6.0;

  /// Velocidade máxima para não ficar injogável.
  static const double obstacleMaxSpeed = 620.0;

  /// Intervalo inicial entre spawns (segundos).
  static const double spawnIntervalStart = 0.95;

  /// Intervalo mínimo entre spawns (segundos).
  static const double spawnIntervalMin = 0.28;

  /// Quanto o intervalo diminui por segundo de jogo.
  static const double spawnIntervalRampPerSecond = 0.02;

  // --- Pontuação e economia --------------------------------------------------
  /// Pontos ganhos por segundo sobrevivido.
  static const int pointsPerSecond = 10;

  /// Quantos pontos valem 1 moeda.
  static const int pointsPerCoin = 20;

  /// Tamanho do ranking local (Top N).
  static const int leaderboardSize = 10;

  // --- Monetização -----------------------------------------------------------
  /// Mostrar intersticial a cada N partidas.
  static const int interstitialEveryNGames = 3;
}

/// Marcos de feedback positivo exibidos durante a partida.
/// Lista ordenada por pontuação crescente.
class ScoreMilestones {
  ScoreMilestones._();

  /// Mapa de pontuação -> mensagem comemorativa.
  static const List<MapEntry<int, String>> milestones = [
    MapEntry(100, 'Bom começo!'),
    MapEntry(300, 'Mandou bem!'),
    MapEntry(600, 'Excelente!'),
    MapEntry(1000, 'Incrível!'),
    MapEntry(2000, 'Imparável!'),
    MapEntry(3500, 'Lendário!'),
  ];
}
