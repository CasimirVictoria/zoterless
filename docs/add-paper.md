# 📄 `add-paper` — Manual de Referència i Capacitats

> **L'eina CLI i d'escriptori definitiva per a la ingesta acadèmica sobirana.**  
> *Resol DOIs, arXiv, PubMed, Dialnet, pàgines web i PDFs locals en 1 clic; descàrrega en accés obert legal, generació de claus Better BibTeX canòniques, i creació instantània de notes Markdown estructurades.*

---

## 🧭 Què és `add-paper`?

`add-paper` és el motor d'ingesta de la suite **zoterless**. Funciona tant com a comanda de consola ràpida per a investigadors i estudiants, com a servei autònom que vigila el portapapers (Wayland/X11), com a cercador interactiu federat o com a llançador d'escriptori (`add-paper.desktop`).

Elimina completament la necessitat d'obrir interfícies pesades per afegir una referència: amb una sola instrucció, `add-paper` fa tot el cicle complet de gestió bibliogràfica en segon pla en menys de dos segons.

```text
Entrada (DOI / URL / Títol / PDF / Portapapers)
                    │
                    ▼
       ┌─────────────────────────┐
       │       `add-paper`       │
       └─────────────────────────┘
                    │
       ┌────────────┼────────────┐
       ▼            ▼            ▼
biblioteca.bib  pdfs/*.pdf   notes/@*.md
 (BibTeX pur)  (Fitxer PDF)  (Plantilla)
```

---

## ⚡ Flux de Treball i Capacitats Clau

Quan invoques `add-paper`, s'executa la següent cadena automatitzada:

1. **Identificació polimòrfica de la font:**
   Detecta automàticament si l'argument és un **DOI**, un identificador **arXiv**, un enllaç de **Dialnet**, un **PMID** de PubMed, una **URL d'article web**, una ruta a un **fitxer PDF local** o un **títol de recerca**.
2. **Cerca federada interactiva (`-s` / `--search`):**
   Si s'activa el mode cerca, consulta en paral·lel múltiples repositoris (OpenAlex, Crossref, ERIC, Dialnet) mitjançant el motor unificat de `mcp-server-academic-spain`. Si la consulta és en català, **Argos Translate** la tradueix localment a l'anglès i al castellà per maximitzar la precisió dels resultats.
3. **Resolució de metadades canòniques:**
   Consulta l'API de Crossref / OpenAlex / DataCite / Dialnet per obtenir les metadades acadèmiques oficials (títol, autors, any, revista, volum, número, pàgines, resum).
4. **Generació estricta de Citekeys (Better BibTeX):**
   Aplica la fórmula estàndard `autorTitolAny` (primer autor en minúscules normalitzat ASCII + paraules clau del títol en CamelCase + any de publicació). Gestiona desambiguacions afegint sufixos alfabètics (`2024a`, `2024b`) si ja existeix una clau prèvia.
5. **Cascada de Descàrrega Legal en Accés Obert (OA):**
   - **Unpaywall Multi-Location:** Cerca rèpliques lliures a través de totes les ubicacions registrades, prioritzant repositoris universitaris (RODERIC, RiuNet, Zenodo, HAL, PMC).
   - **OpenAlex OA:** Identifica versions d'accés obert (`best_oa_location`).
   - **Dialnet Directe:** Descàrrega directa d'articles i actes de congressos lliures.
   - **Playwright Fallback:** Si una editorial utilitza reptes antibot (Cloudflare, captchas lleugers), empra un navegador headless per superar la protecció i recuperar el document legítim.
   - **Detecció a `~/Downloads`:** Si l'usuari ha descarregat prèviament el PDF (per exemple sota subscripció universitària), `add-paper` escaneja les descàrregues recents, n'inspecciona el contingut amb `pdftotext` i l'associa automàticament.
6. **Compilació d'articles web a XeLaTeX (`-w` / `--web`):**
   Quan es captura un article divulgatiu, entrada de blog o premsa, descarrega el text net, en formata la tipografia i el compila com un **PDF elegant mitjançant XeLaTeX**, desant-lo a la biblioteca com un document de lectura de primera classe.
7. **Connexió institucional EduVPN (`--vpn`):**
   Si l'article requereix accés per subscripció de la Universitat de València (UV) o la UPV, l'opció `--vpn` activa automàticament el túnel NetworkManager/WireGuard abans de procedir a la descàrrega.
8. **Triple actualització transparent:**
   - **`biblioteca.bib`:** Afegeix l'entrada estructurada amb els camps `file = {...}`, `doi = {...}` i `url = {...}`.
   - **`pdfs/{citekey}.pdf`:** Desa i valida la integritat del PDF.
   - **`notes/@{citekey}.md`:** Genera la fitxa de lectura en Markdown/Denote amb metadades YAML, resum oficial i apartats per a cites i reflexions.
9. **Sincronització instantània amb Kate i Faristol:**
   Executa `kate-sync-project` en segon pla per actualitzar el fitxer `.kateproject` (permetent emprar `kate-citar` immediatament) i envia una **notificació d'escriptori nativa de KDE** (`notify-send`).

---

## 💻 Guia d'Ús i Ordres

### 1. Ingesta directa per identificador o URL

```bash
# Per DOI
add-paper 10.1016/j.compedu.2023.104845

# Per URL de DOI
add-paper https://doi.org/10.1145/3313831.3376722

# Per repositori arXiv (URL o identificador)
add-paper https://arxiv.org/abs/2301.00001
add-paper 2301.00001

# Per article de Dialnet
add-paper https://dialnet.unirioja.es/servlet/articulo?codigo=6327318
```

### 2. Amb connexió automàtica a EduVPN UV

```bash
# Activa EduVPN abans de descarregar un article d'editorial de pagament:
add-paper --vpn 10.1016/j.compedu.2023.104845
```

### 3. Cerca federada interactiva (`-s`)

```bash
# Cerca per paraules clau amb traducció automàtica local (català -> anglès / castellà):
add-paper -s "pensament computacional en educació primària"
```
*Es mostrarà un menú interactiu al terminal amb els resultats deduplicats; en prémer el número corresponent, l'article es descarregarà i s'incorporarà automàticament.*

### 4. Captura d'articles web maquetats a PDF (`-w` / `--web`)

```bash
# Converteix un article web, blog o notícia a PDF d'alta qualitat (XeLaTeX) i nota Markdown:
add-paper -w https://cacm.acm.org/magazines/2024/2/computational-thinking/fulltext
```

### 5. Ingesta d'un fitxer PDF local

```bash
# Extreu automàticament el DOI i metadades d'un PDF que ja tens al disc:
add-paper ~/Baixades/document_desconegut.pdf
```

### 6. Mode autònom des del Portapapers

```bash
# Si acabes de copiar un DOI o URL al navegador, només cal executar:
add-paper
```
*`add-paper` llegeix directament el contingut de `wl-paste` (Wayland) o `xclip` (X11), processa la font i et llança la notificació en segon pla.*

---

## ⌨️ Integració d'Escriptori

### Llançador gràfic (`add-paper.desktop`)

Pots invocar `add-paper` directament des de **KRunner** (`Alt + Espai`) o des del menú d'aplicacions de KDE Plasma escrivint «Afegir Article». S'obrirà un diàleg per enganxar el DOI o URL.

### Drecera global de teclat a KDE Plasma

Per afegir articles en 0.5 segons des de qualsevol finestra:
1. Obre **Preferències del sistema** → **Dreceres** → **Dreceres personalitzades**.
2. Afegeix una nova ordre: `add-paper`.
3. Assigna la combinació de tecles: `Meta + Shift + P` (o la que preferisques).
4. **Flux:** Selecciona/copia un DOI a qualsevol lloc, prem la drecera, i l'article s'incorporarà immediatament a la teua biblioteca sense interrupcions.

### Ingesta remota des d'Android (via Tailscale)

Quan comparteixes un document des d'Android (mitjançant el menú *«Compartir...»* a la PWA o des de la interfície mòbil a `http://<IP-Tailscale>:23119`), `zotero-receiver` delega el processament asíncron directament en el motor de **`add-paper`**, executant la mateixa cascada de resolució, descàrrega i maquetació XeLaTeX en segon pla.

---

## 🔧 Fitxers i Rutes d'Operació

| Element | Ubicació per defecte |
| :--- | :--- |
| **Base de dades BibTeX** | `~/Documents/Biblioteca/biblioteca.bib` |
| **Repositori de PDFs** | `~/Documents/Biblioteca/pdfs/{citekey}.pdf` |
| **Notes bibliogràfiques** | `~/Documents/notes/@{citekey}.md` |
| **Projecte Kate** | `~/Documents/notes/.kateproject` |
| **Binari executable** | `~/.local/bin/add-paper` |
