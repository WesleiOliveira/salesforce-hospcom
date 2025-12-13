#!/bin/bash

# Script para executar análise PMD no código Apex
# Uso: ./scripts/run-pmd.sh

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APEX_DIR="force-app/main/default/classes"
TRIGGER_DIR="force-app/main/default/triggers"
RULESET="config/pmd-ruleset.xml"
REPORT_FORMAT="text"

# Verificar se PMD está instalado
if ! command -v pmd &> /dev/null; then
    echo -e "${YELLOW}⚠️  PMD não está instalado.${NC}"
    echo -e "${YELLOW}Para instalar PMD:${NC}"
    echo -e "  ${GREEN}brew install pmd${NC} (macOS)"
    echo -e "  ${GREEN}ou baixe de: https://pmd.github.io/${NC}"
    echo -e "${YELLOW}O pre-commit continuará sem validação PMD.${NC}"
    exit 0
fi

# Verificar se o ruleset existe
if [ ! -f "$RULESET" ]; then
    echo -e "${RED}❌ Erro: Arquivo de ruleset não encontrado: $RULESET${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Executando análise PMD no código Apex...${NC}"

# Executar PMD apenas nos arquivos modificados (staged)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(cls|trigger)$' || true)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}✅ Nenhum arquivo Apex modificado para analisar${NC}"
    exit 0
fi

# Criar diretório temporário para arquivos staged
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copiar arquivos staged para diretório temporário mantendo estrutura
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        # Criar estrutura de diretórios
        mkdir -p "$TEMP_DIR/$(dirname "$file")"
        # Copiar arquivo
        cp "$file" "$TEMP_DIR/$file"
    fi
done

# Executar PMD
pmd check --dir "$TEMP_DIR" --rulesets "$RULESET" --format "$REPORT_FORMAT" 2>&1
PMD_EXIT_CODE=$?

if [ $PMD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Análise PMD concluída sem problemas${NC}"
    exit 0
else
    echo -e "${RED}❌ Análise PMD encontrou problemas no código${NC}"
    echo -e "${YELLOW}Por favor, corrija os problemas antes de fazer commit${NC}"
    exit 1
fi
