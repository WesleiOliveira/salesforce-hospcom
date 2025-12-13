#!/bin/bash

# Script de validação de código Salesforce
# Uso: ./scripts/validate.sh [org-alias]

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ORG_ALIAS=${1:-"dev"}
SOURCE_DIR="force-app"

echo -e "${YELLOW}🔍 Validando código Salesforce...${NC}"

# Verificar autenticação
if ! sf org display --target-org $ORG_ALIAS &>/dev/null; then
    echo -e "${RED}Erro: Org '$ORG_ALIAS' não está autenticada${NC}"
    exit 1
fi

echo -e "${GREEN}Organização: $ORG_ALIAS${NC}"

# Validar código
echo -e "${YELLOW}Executando validação...${NC}"
sf project deploy validate \
    --source-dir $SOURCE_DIR \
    --target-org $ORG_ALIAS \
    --ignore-warnings \
    --wait 10

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Validação concluída com sucesso!${NC}"
else
    echo -e "${RED}❌ Validação falhou${NC}"
    exit 1
fi
