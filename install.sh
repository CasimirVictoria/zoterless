#!/usr/bin/env bash
# ==============================================================================
# zoterless - Instal·lador per a Linux
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DEST="$HOME/.local/bin"
SYSTEMD_DEST="$HOME/.config/systemd/user"

echo "📦 Instal·lant zoterless..."

# 1. Comprovar dependències bàsiques
echo "🔍 Comprovant dependències..."
for cmd in python3 curl pdftotext notify-send; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "⚠️  Avís: L'ordre '$cmd' no s'ha trobat al sistema."
        echo "   Pots instal·lar-la a Debian/Ubuntu amb: sudo apt install python3 python3-pyqt6 curl poppler-utils libnotify-bin"
    fi
done

# 2. Instal·lar binaris (symlinks per desenvolupament o còpies)
mkdir -p "$BIN_DEST"
for script in zotero-receiver kate-citar kate-citar-actions add-paper kate-sync-project; do
    if [ -f "$DIR/bin/$script" ]; then
        ln -sf "$DIR/bin/$script" "$BIN_DEST/$script"
        chmod +x "$DIR/bin/$script"
        echo "  ✓ $BIN_DEST/$script enllaçat"
    fi
done

# 3. Instal·lar i activar Systemd Socket Activation (Zero RAM real)
mkdir -p "$SYSTEMD_DEST"
cp -f "$DIR/systemd/zotero-receiver.socket" "$SYSTEMD_DEST/zotero-receiver.socket"
cp -f "$DIR/systemd/zotero-receiver.service" "$SYSTEMD_DEST/zotero-receiver.service"

systemctl --user daemon-reload
systemctl --user stop zotero-receiver.service 2>/dev/null || true
systemctl --user enable --now zotero-receiver.socket

echo ""
echo "🎉 zoterless s'ha instal·lat correctament amb Socket Activation!"
echo "   (En repòs consumeix 0 MB de RAM; s'activa automàticament en rebre peticions de Firefox)"
echo ""
echo "Estat del socket:"
systemctl --user status zotero-receiver.socket --no-pager | head -n 8
echo ""
echo "Per configurar el Zotero Connector a Firefox:"
echo "1. Instal·la l'extensió oficial 'Zotero Connector' a Firefox."
echo "2. No cal obrir ni tindre instal·lat Zotero Desktop."
echo "3. Quan faces clic a la icona de Zotero Connector en qualsevol pàgina,"
echo "   zoterless interceptarà la petició i desarà directament el BibTeX,"
echo "   el PDF i la nota Markdown!"
