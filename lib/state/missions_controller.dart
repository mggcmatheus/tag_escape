import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Tipos de objetivo de uma missão diária.
enum MissionType {
  /// Sobreviver X segundos em uma única partida.
  survivalSeconds,

  /// Atingir X pontos em uma única partida.
  scoreInRun,

  /// Jogar X partidas (acumulativo no dia).
  gamesPlayed,
}

/// Uma missão diária com alvo, progresso e recompensa.
class Mission {
  Mission({
    required this.id,
    required this.type,
    required this.description,
    required this.target,
    required this.reward,
    this.progress = 0,
    this.claimed = false,
  });

  final String id;
  final MissionType type;
  final String description;
  final int target;
  final int reward;

  int progress;
  bool claimed;

  bool get completed => progress >= target;

  /// Percentual de conclusão (0.0 a 1.0).
  double get fraction => (progress / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'description': description,
        'target': target,
        'reward': reward,
        'progress': progress,
        'claimed': claimed,
      };

  factory Mission.fromJson(Map<String, dynamic> j) => Mission(
        id: j['id'] as String,
        type: MissionType.values[j['type'] as int],
        description: j['description'] as String,
        target: j['target'] as int,
        reward: j['reward'] as int,
        progress: j['progress'] as int? ?? 0,
        claimed: j['claimed'] as bool? ?? false,
      );
}

/// Controla as missões diárias: geração, persistência, atualização de
/// progresso ao fim de cada partida e reset automático a cada novo dia.
class MissionsController extends ChangeNotifier {
  MissionsController(this._storage) {
    _loadOrReset();
  }

  final StorageService _storage;

  List<Mission> _missions = [];
  List<Mission> get missions => List.unmodifiable(_missions);

  /// Conjunto padrão de missões diárias. Em um jogo real poderiam ser
  /// sorteadas de um pool maior; aqui mantemos um conjunto fixo e claro.
  List<Mission> _defaultMissions() => [
        Mission(
          id: 'survive_30',
          type: MissionType.survivalSeconds,
          description: 'Sobreviva 30 segundos em uma partida',
          target: 30,
          reward: 50,
        ),
        Mission(
          id: 'score_100',
          type: MissionType.scoreInRun,
          description: 'Faça 100 pontos em uma partida',
          target: 100,
          reward: 40,
        ),
        Mission(
          id: 'play_5',
          type: MissionType.gamesPlayed,
          description: 'Jogue 5 partidas hoje',
          target: 5,
          reward: 60,
        ),
      ];

  String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Carrega missões salvas; se forem de outro dia (ou inexistentes), reseta.
  void _loadOrReset() {
    final savedDate = _storage.missionsDate;
    final savedData = _storage.missionsData;

    if (savedDate == _today && savedData != null) {
      try {
        final list = (jsonDecode(savedData) as List)
            .map((e) => Mission.fromJson(e as Map<String, dynamic>))
            .toList();
        _missions = list;
        return;
      } catch (_) {
        // Dados corrompidos: cai no reset.
      }
    }
    _resetForToday();
  }

  void _resetForToday() {
    _missions = _defaultMissions();
    _storage.setMissionsDate(_today);
    _persist();
  }

  void _persist() {
    final data = jsonEncode(_missions.map((m) => m.toJson()).toList());
    _storage.setMissionsData(data);
  }

  /// Garante que as missões pertencem ao dia atual (chamar ao abrir telas).
  void refreshDayIfNeeded() {
    if (_storage.missionsDate != _today) {
      _resetForToday();
      notifyListeners();
    }
  }

  /// Atualiza o progresso das missões com o resultado de uma partida.
  void registerGameResult({
    required int score,
    required int survivalSeconds,
  }) {
    refreshDayIfNeeded();
    for (final m in _missions) {
      switch (m.type) {
        case MissionType.survivalSeconds:
          // Melhor tempo de sobrevivência em uma única partida.
          if (survivalSeconds > m.progress) m.progress = survivalSeconds;
        case MissionType.scoreInRun:
          // Melhor pontuação em uma única partida.
          if (score > m.progress) m.progress = score;
        case MissionType.gamesPlayed:
          // Acumulativo.
          m.progress += 1;
      }
    }
    _persist();
    notifyListeners();
  }

  /// Resgata a recompensa de uma missão concluída. Retorna a quantidade de
  /// moedas a creditar (0 se não pôde resgatar). Quem credita é o chamador,
  /// mantendo este controller desacoplado do progresso financeiro.
  int claim(String missionId) {
    final m = _missions.firstWhere(
      (m) => m.id == missionId,
      orElse: () => Mission(
        id: '',
        type: MissionType.gamesPlayed,
        description: '',
        target: 1,
        reward: 0,
      ),
    );
    if (m.id.isEmpty || !m.completed || m.claimed) return 0;
    m.claimed = true;
    _persist();
    notifyListeners();
    return m.reward;
  }
}
