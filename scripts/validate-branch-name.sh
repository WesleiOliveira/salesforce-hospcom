#!/bin/bash

# Script para validar o padrão de nome da branch
# Padrão esperado: feat-{area *opcional}-{numero do card}
# Exemplo: feat-vendas-0001 ou feat-0001

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Obter o nome da branch atual
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Padrão regex para features: feat- seguido de área opcional (letras, números, hífens) e número do card
# Exemplos válidos: feat-0001, feat-vendas-0001, feat-area-teste-1234
FEAT_PATTERN="^feat(-[a-zA-Z0-9-]+)?-[0-9]+$"

# Padrão regex para branches de merge: merge- seguido de área opcional e número do card, terminando em -integration ou -production
# Exemplos válidos: merge-0001-integration, merge-teste-0001-integration, merge-0001-production
MERGE_PATTERN="^merge(-[a-zA-Z0-9-]+)?-[0-9]+-(integration|production)$"

if [[ ! $BRANCH_NAME =~ $FEAT_PATTERN ]] && [[ ! $BRANCH_NAME =~ $MERGE_PATTERN ]]; then
    echo -e "${RED}❌ Erro: Nome da branch não segue o padrão esperado!${NC}"
    echo -e "${YELLOW}Padrões esperados:${NC}"
    echo -e "${YELLOW}  Feature: feat-{area *opcional}-{numero do card}${NC}"
    echo -e "${YELLOW}  Merge: merge-{area *opcional}-{numero do card}-(integration|production)${NC}"
    echo -e "${YELLOW}Exemplos válidos:${NC}"
    echo -e "  - ${GREEN}feat-0001${NC}"
    echo -e "  - ${GREEN}feat-vendas-0001${NC}"
    echo -e "  - ${GREEN}feat-area-teste-1234${NC}"
    echo -e "  - ${GREEN}merge-0001-integration${NC}"
    echo -e "  - ${GREEN}merge-teste-0001-integration${NC}"
    echo -e "  - ${GREEN}merge-0001-production${NC}"
    echo -e "${YELLOW}Branch atual: ${RED}$BRANCH_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Nome da branch válido: $BRANCH_NAME${NC}"
exit 0
