# Efeitos sonoros

Coloque aqui os arquivos de áudio (formato `.wav` recomendado para baixa
latência). O código (`lib/services/audio_service.dart`) espera exatamente:

| Arquivo          | Quando toca                         |
|------------------|-------------------------------------|
| `tap.wav`        | a cada toque/dash                   |
| `collect.wav`    | ao atingir um marco de pontuação    |
| `hit.wav`        | ao colidir                          |
| `game_over.wav`  | no fim de partida                   |

> O jogo é tolerante a falhas: se um arquivo não existir, o som é apenas
> ignorado (não quebra o gameplay). Mas para a build final, inclua os 4.

Fontes gratuitas de SFX: freesound.org, mixkit.co, kenney.nl/assets (libre).
