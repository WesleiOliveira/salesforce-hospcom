#!/bin/bash

# Script para validar o padrão de nome da branch de merge
# Padrão esperado: merge-{area *opcional}-{numero do card}-integration
# Exemplo: merge-vendas-0001-integration ou merge-0001-integration

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Obter o nome da branch atual
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Padrão regex: merge- seguido de área opcional, número do card e -integration
# Exemplos válidos: merge-0001-integration, merge-vendas-0001-integration, merge-area-teste-1234-integration
BRANCH_PATTERN="^merge(-[a-zA-Z0-9-]+)?-[0-9]+-integration$"

if [[ ! $BRANCH_NAME =~ $BRANCH_PATTERN ]]; then
    echo -e "${RED}❌ Erro: Nome da branch de merge não segue o padrão esperado!${NC}"
    echo -e "${YELLOW}Padrão esperado: merge-{area *opcional}-{numero do card}-integration${NC}"
    echo -e "${YELLOW}Exemplos válidos:${NC}"
    echo -e "  - ${GREEN}merge-0001-integration${NC}"
    echo -e "  - ${GREEN}merge-vendas-0001-integration${NC}"
    echo -e "  - ${GREEN}merge-area-teste-1234-integration${NC}"
    echo -e "${YELLOW}Branch atual: ${RED}$BRANCH_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Nome da branch de merge válido: $BRANCH_NAME${NC}"
exit 0
