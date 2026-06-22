# Tap Escape 🎯

Jogo hypercasual de sobrevivência feito em **Flutter + Flame**. A esfera fica no
centro; você toca na tela para dar um *dash* e desviar dos obstáculos que vêm de
todas as direções. Quanto mais tempo sobreviver, mais pontos e moedas.

> ⚠️ Este repositório contém o **código-fonte completo e configurações**, mas as
> pastas de plataforma (`android/`, `ios/`) e o `gradle wrapper` precisam ser
> completados com `flutter create .` (passo abaixo), pois dependem do SDK.

---

## 1. Pré-requisitos

- Flutter SDK 3.19+ (`flutter --version`)
- Android SDK + Android Studio (ou apenas o command-line tools)
- Java 17 (necessário para o Android Gradle Plugin 8.x)
- Uma conta no [AdMob](https://admob.google.com) e na
  [Google Play Console](https://play.google.com/console)

## 2. Setup do projeto

```bash
cd tap_escape

# 1) Gera/atualiza as pastas de plataforma SEM sobrescrever lib/ e configs.
#    Use o mesmo applicationId definido no android/app/build.gradle.
flutter create --org com.tapescape --project-name tap_escape --platforms=android .

# 2) Reaplique os arquivos Android customizados deste repositório, caso o
#    flutter create os tenha sobrescrito (AndroidManifest.xml, build.gradle,
#    MainActivity.kt em com/tapescape/game/, styles.xml, etc.).

# 3) Instala dependências.
flutter pub get

# 4) (Opcional) Ícone e splash – ver assets/icon/README.md
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 5) Roda em um device/emulador.
flutter run
```

## 3. Estrutura

```
lib/
├── core/         # tema, cores, constantes de balanceamento
├── ads/          # ads_config.dart (IDs) + ad_manager.dart
├── game/         # motor Flame: jogo, player, obstáculos, partículas
├── services/     # storage (SharedPreferences) e áudio
├── state/        # providers (progresso, missões, settings) + catálogo da loja
├── screens/      # home, game, loja, missões, ranking, ajustes
└── widgets/      # botão neon, banner, fundo animado, etc.
```

### Decisões técnicas

- **Flame** para o gameplay (loop, colisões via `HasCollisionDetection`,
  componentes) e **Flutter puro** para menus/HUD/overlays.
- **Provider** (`ChangeNotifier`) para estado de UI persistente. Toda a
  persistência passa por um único `StorageService` (sem strings de chave
  espalhadas).
- O jogo (`TapEscapeGame`) **não conhece widgets**: comunica-se com a UI por
  callbacks (`onScore`, `onMilestone`, `onGameOver`), mantendo baixo acoplamento.
- Anúncios **nunca quebram o jogo**: falhas de carregamento são engolidas e o
  app funciona 100% offline.

## 4. Configurar anúncios (AdMob)

Tudo fica em **`lib/ads/ads_config.dart`**:

1. Mantenha `useTestAds = true` durante o desenvolvimento (usa os IDs de teste
   oficiais do Google — clicar neles é seguro).
2. Para produção, preencha `androidAppIdProd`, `androidBannerProd`,
   `androidInterstitialProd`, `androidRewardedProd` e mude `useTestAds = false`.
3. Atualize o **App ID** no `android/app/src/main/AndroidManifest.xml`
   (meta-data `com.google.android.gms.ads.APPLICATION_ID`).

> 🚫 **Nunca clique nos seus próprios anúncios de produção** — isso pode banir
> sua conta AdMob.

**Onde os anúncios aparecem:**
- **Banner**: tela inicial (`HomeScreen`).
- **Intersticial**: a cada **3 partidas** (não em todas), antes de reiniciar.
- **Rewarded**: no Game Over, botão "Assistir e reviver" (revive **uma vez**).

## 5. Rodar testes

```bash
flutter test
```

---

## 6. Gerar APK (testes/distribuição direta)

```bash
# APK único (mais simples, bom para testar em devices):
flutter build apk --release

# APKs por arquitetura (menores):
flutter build apk --release --split-per-abi
```
Saída em `build/app/outputs/flutter-apk/`.

## 7. Gerar AAB (obrigatório para a Play Store)

### 7.1. Criar o keystore de upload (uma única vez)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 7.2. Configurar a assinatura

Crie `android/key.properties` (use `key.properties.example` como base):

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/caminho/absoluto/upload-keystore.jks
```

### 7.3. Gerar o bundle

```bash
flutter build appbundle --release
```
Saída: `build/app/outputs/bundle/release/app-release.aab`.

---

## 8. Publicar na Google Play

1. **Play Console → Criar app** (nome, idioma, gratuito/pago, declarações).
2. **Configuração do app**: política de privacidade (obrigatória por usar ads),
   classificação de conteúdo, público-alvo, segurança de dados (declare a coleta
   do Advertising ID feita pelo AdMob).
3. **Produção → Criar versão** → faça upload do `.aab`.
4. Preencha a **ficha da loja** (ver ASO abaixo): título, descrições, ícone (512px),
   feature graphic (1024x500), screenshots (mín. 2).
5. Conclua o **questionário de anúncios** (o app contém anúncios) e o de
   conteúdo. Vincule a conta AdMob ao app.
6. Envie para revisão. Comece por um **teste fechado/aberto** antes da produção
   ampla para validar crashes e métricas.

> A primeira publicação de uma conta nova exige verificação de identidade e
> (para contas pessoais novas) teste com no mínimo 12 testadores por 14 dias.

---

## 9. ASO — App Store Optimization

**Título (≤30 chars):** inclua a keyword principal. Ex.: `Tap Escape: Dodge & Dash`.

**Descrição curta (≤80 chars):** gancho + ação. Ex.:
`Toque para desviar. Sobreviva o máximo que puder. Bata seu recorde!`

**Descrição longa:** primeiras 2 linhas vendem; use keywords naturalmente
(jogo casual, desviar, reflexo, arcade, offline, grátis). Liste features em
bullets e termine com CTA.

**Keywords-alvo:** `jogo casual`, `desviar obstáculos`, `jogo de reflexo`,
`arcade neon`, `one tap`, `hypercasual`, `jogo offline grátis`.

**Visual (o que mais converte):**
- Ícone limpo e contrastante (a esfera neon em fundo escuro).
- 2 primeiras screenshots com texto sobreposto destacando o benefício.
- Vídeo curto (15–30s) de gameplay com a tensão de quase-colisões.

**Iteração:** rode testes A/B de ícone e screenshots na Play Console; otimize
para a taxa de conversão de visita → instalação.

---

## 10. Maximizar receita de ads SEM prejudicar retenção

Princípio: **proteger as primeiras sessões**. Usuário que desinstala não gera
receita de longo prazo (LTV).

- **Onboarding sem fricção**: as primeiras 2–3 partidas idealmente sem
  intersticial. (Ajuste em `GameConfig.interstitialEveryNGames` ou adicione uma
  trava por número de partidas totais.)
- **Frequência equilibrada**: intersticial a cada 3 partidas é um bom ponto de
  partida; meça `ad_impressions/DAU` vs. retenção D1/D7 e ajuste.
- **Rewarded é o ouro**: alto eCPM e percebido como benefício. Amplie os pontos
  de oferta: dobrar moedas no fim da partida, reviver, desbloquear skin por
  vídeo. Rewarded raramente prejudica retenção.
- **Respeite o estado de jogo**: nunca mostre intersticial no meio da partida —
  só em transições naturais (Game Over → reiniciar), como já implementado.
- **eCPM por mediação**: integre mediação (AdMob Mediation / mais tarde
  considere outras redes) para concorrência de lances e maior preenchimento.
- **Frequency capping** no painel do AdMob para evitar fadiga.
- **Banner discreto**: só no menu (já feito), nunca cobrindo área de jogo.
- **Métricas a acompanhar**: ARPDAU, retenção D1/D7/D30, sessões/usuário,
  taxa de conclusão de rewarded.

---

## 11. Próximos passos para engajamento

- **Sequência de login diário** (recompensa crescente).
- **Power-ups** (escudo, câmera lenta, ímã de moedas) compráveis/por rewarded.
- **Eventos semanais** e desafios temáticos.
- **Conquistas** + **Google Play Games Services** (ranking online e cloud save).
- **Notificações push** para missões diárias e "sua sequência acaba hoje".
- **Novos modos** (tempo, zen, hardcore) e obstáculos variados.
- **Compartilhar recorde** (screenshot) para crescimento viral.
- **Compras in-app** opcionais: remover ads, pacotes de moedas, skins premium.
- **Live-ops**: ajustar dificuldade/economia remotamente (Firebase Remote Config).
```
# tag_escape
