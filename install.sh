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
        echo "   Pots instal·lar-la a Debian/Ubuntu amb: sudo apt install python3 python3-pyqt5 curl poppler-utils libnotify-bin"
    fi
done

# 2. Instal·lar binaris
mkdir -p "$BIN_DEST"
for script in zotero-receiver kate-citar kate-citar-actions add-paper; do
    if [ -f "$DIR/bin/$script" ]; then
        cp -f "$DIR/bin/$script" "$BIN_DEST/$script"
        chmod +x "$BIN_DEST/$script"
        echo "  ✓ $BIN_DEST/$script instal·lat"
    fi
done

# 3. Instal·lar i activar servei systemd per a l'usuari
mkdir -p "$SYSTEMD_DEST"
cat > "$SYSTEMD_DEST/zotero-receiver.service" << EOF
[Unit]
Description=Zoterless Connector Daemon (Emulador de Zotero per a Firefox)
After=network.target

[Service]
ExecStart=%h/.local/bin/zotero-receiver
Restart=always
RestartSec=3
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now zotero-receiver.service

echo ""
echo "🎉 zoterless s'ha instal·lat correctament!"
echo ""
echo "Estat del servei:"
systemctl --user status zotero-receiver.service --no-pager | head -n 8
echo ""
echo "Per configurar el Zotero Connector a Firefox:"
echo "1. Instal·la l'extensió oficial 'Zotero Connector' a Firefox."
echo "2. No cal obrir ni tindre instal·lat Zotero Desktop."
echo "3. Quan faces clic a la icona de Zotero Connector en qualsevol pàgina,"
echo "   zoterless interceptarà la petició i desarà directament el BibTeX,"
echo "   el PDF i la nota Markdown!"
