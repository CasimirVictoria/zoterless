#!/usr/bin/env bash
# ==============================================================================
# zoterless - Desinstal·lador
# ==============================================================================
set -e

echo "🗑️ Desinstal·lant zoterless..."

systemctl --user stop zotero-receiver.service 2>/dev/null || true
systemctl --user stop zotero-receiver.socket 2>/dev/null || true
systemctl --user disable zotero-receiver.service 2>/dev/null || true
systemctl --user disable zotero-receiver.socket 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/zotero-receiver.service"
rm -f "$HOME/.config/systemd/user/zotero-receiver.socket"
systemctl --user daemon-reload

for script in zotero-receiver kate-citar kate-citar-actions add-paper kate-sync-project zoterless-capture-paper zoterless-capture-web; do
    rm -f "$HOME/.local/bin/$script"
done

echo "✓ zoterless s'ha eliminat correctament del sistema."
echo "Nota: Els teus fitxers de biblioteca (biblioteca.bib, pdfs i notes) NO s'han tocat."
