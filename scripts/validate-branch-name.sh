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

# Padrão regex: feat- seguido de área opcional (letras, números, hífens) e número do card
# Exemplos válidos: feat-0001, feat-vendas-0001, feat-area-teste-1234
BRANCH_PATTERN="^feat(-[a-zA-Z0-9-]+)?-[0-9]+$"

if [[ ! $BRANCH_NAME =~ $BRANCH_PATTERN ]]; then
    echo -e "${RED}❌ Erro: Nome da branch não segue o padrão esperado!${NC}"
    echo -e "${YELLOW}Padrão esperado: feat-{area *opcional}-{numero do card}${NC}"
    echo -e "${YELLOW}Exemplos válidos:${NC}"
    echo -e "  - ${GREEN}feat-0001${NC}"
    echo -e "  - ${GREEN}feat-vendas-0001${NC}"
    echo -e "  - ${GREEN}feat-area-teste-1234${NC}"
    echo -e "${YELLOW}Branch atual: ${RED}$BRANCH_NAME${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Nome da branch válido: $BRANCH_NAME${NC}"
exit 0
