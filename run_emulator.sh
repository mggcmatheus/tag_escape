#!/usr/bin/env bash
#
# Inicia o emulador Android usado para desenvolver o Tap Escape.
#
# Uso:
#   ./run_emulator.sh            # inicia o AVD e aguarda o boot
#   ./run_emulator.sh --run      # inicia o AVD, aguarda o boot e roda `flutter run`
#
# É idempotente: se o emulador já estiver rodando, apenas reaproveita.
set -euo pipefail

# --- Configuração ------------------------------------------------------------
AVD_NAME="${AVD_NAME:-tap_escape_avd}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT
export ANDROID_HOME="$ANDROID_SDK_ROOT"

EMULATOR="$ANDROID_SDK_ROOT/emulator/emulator"
ADB="$ANDROID_SDK_ROOT/platform-tools/adb"

# --- Validações --------------------------------------------------------------
[ -x "$EMULATOR" ] || { echo "✕ emulator não encontrado em $EMULATOR"; exit 1; }
[ -x "$ADB" ] || { echo "✕ adb não encontrado em $ADB"; exit 1; }

if ! "$EMULATOR" -list-avds | grep -qx "$AVD_NAME"; then
    echo "✕ AVD '$AVD_NAME' não existe. Crie com:"
    echo "  avdmanager create avd -n $AVD_NAME -k 'system-images;android-34;google_apis;x86_64' -d pixel_6"
    exit 1
fi

# --- Inicia o emulador (se ainda não estiver rodando) ------------------------
if "$ADB" devices | grep -q "emulator-"; then
    echo "✓ Emulador já está rodando."
else
    echo "▶ Iniciando emulador '$AVD_NAME'..."
    nohup "$EMULATOR" -avd "$AVD_NAME" \
        -no-snapshot-load -gpu swiftshader_indirect -no-boot-anim \
        > /tmp/emulator.log 2>&1 &
    echo "  (log em /tmp/emulator.log, pid $!)"
fi

# --- Aguarda o boot completo -------------------------------------------------
echo "⏳ Aguardando o device..."
"$ADB" wait-for-device

echo "⏳ Aguardando boot completo..."
until [ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
    sleep 2
done
echo "✓ Emulador pronto:"
"$ADB" devices

# --- Opcional: roda o app ----------------------------------------------------
if [ "${1:-}" = "--run" ]; then
    if command -v flutter >/dev/null 2>&1; then
        echo "▶ flutter run..."
        flutter run
    else
        echo "✕ 'flutter' não está no PATH. Rode manualmente: flutter run"
        exit 1
    fi
fi
