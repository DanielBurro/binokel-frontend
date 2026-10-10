#!/usr/bin/env bash
set -e

# Farbdefinitionen für übersichtliche Terminalausgaben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setup für das Binokel Flutter Frontend ===${NC}\n"

# 1. Git-Repository überprüfen
if [ ! -d ".git" ]; then
  echo -e "${RED}Fehler: Kein Git-Repository gefunden.${NC}"
  echo "Bitte führe dieses Skript im Hauptverzeichnis des Frontend-Repositories aus."
  exit 1
fi

# 2. Flutter SDK Verfügbarkeit prüfen
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}Fehler: 'flutter' wurde im PATH nicht gefunden.${NC}"
  echo "Bitte installiere das Flutter SDK oder passe deine Umgebungsvariablen an."
  exit 1
fi

echo -e "${BLUE}▶ Flutter-Version:${NC}"
flutter --version | head -n 1

# 3. Flutter-Abhängigkeiten installieren
echo -e "\n${BLUE}▶ Installiere pub-Abhängigkeiten...${NC}"
flutter pub get

# 4. Git-Hooks aktivieren und Rechte sicherstellen
echo -e "\n${BLUE}▶ Konfiguriere Git-Hooks...${NC}"
if [ -d ".githooks" ]; then
  git config core.hooksPath .githooks
  chmod +x .githooks/*
  echo -e "${GREEN}✓ Git-Hooks erfolgreich auf '.githooks' gesetzt und Ausführungsrechte vergeben.${NC}"
else
  echo -e "${YELLOW}Warnung: Verzeichnis '.githooks' nicht gefunden. Hook-Pfad konnte nicht gesetzt werden.${NC}"
fi

# 5. Schnelle Validierung der Codequalität
echo -e "\n${BLUE}▶ Validiere Umgebung mit Dart Format & Flutter Analyze...${NC}"

if dart format --output=none --set-exit-if-changed lib test &> /dev/null; then
  echo -e "${GREEN}✓ Code-Formatierung ist sauber.${NC}"
else
  echo -e "${YELLOW}Einige Dateien weichen von der Dart-Formatierung ab. Führe bei Bedarf 'dart format .' aus.${NC}"
fi

if flutter analyze --no-fatal-infos; then
  echo -e "${GREEN}✓ Statische Code-Analyse ohne Fehler abgeschlossen.${NC}"
else
  echo -e "${YELLOW}Es wurden Linter-Hinweise gefunden. Bitte vor dem Committen prüfen.${NC}"
fi

echo -e "\n${GREEN}Setup abgeschlossen! Das Repository ist einsatzbereit.${NC}"
exit 0