#!/bin/bash

# Script para validar que a branch de merge foi criada a partir de integration

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
INTEGRATION_BRANCH="integration"

# Verificar se a branch integration existe
if ! git show-ref --verify --quiet refs/heads/$INTEGRATION_BRANCH && ! git show-ref --verify --quiet refs/remotes/origin/$INTEGRATION_BRANCH; then
    echo -e "${YELLOW}⚠️  Aviso: Branch '$INTEGRATION_BRANCH' não encontrada localmente ou remotamente${NC}"
    echo -e "${YELLOW}Certifique-se de que a branch '$INTEGRATION_BRANCH' existe antes de criar branches de merge${NC}"
    exit 1
fi

# Se já estamos na integration, não precisamos validar
if [ "$BRANCH_NAME" = "$INTEGRATION_BRANCH" ]; then
    echo -e "${GREEN}✅ Branch atual é integration, validação não necessária${NC}"
    exit 0
fi

# Verificar se a branch atual foi criada a partir de integration
INTEGRATION_REF=""
if git show-ref --verify --quiet refs/heads/$INTEGRATION_BRANCH; then
    INTEGRATION_REF="refs/heads/$INTEGRATION_BRANCH"
elif git show-ref --verify --quiet refs/remotes/origin/$INTEGRATION_BRANCH; then
    INTEGRATION_REF="refs/remotes/origin/$INTEGRATION_BRANCH"
fi

if [ -z "$INTEGRATION_REF" ]; then
    echo -e "${RED}❌ Erro: Não foi possível encontrar a referência da branch integration${NC}"
    exit 1
fi

# Obter o commit base comum
MERGE_BASE=$(git merge-base HEAD $INTEGRATION_REF 2>/dev/null || echo "")

if [ -z "$MERGE_BASE" ]; then
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$INTEGRATION_BRANCH'${NC}"
    echo -e "${YELLOW}Por favor, crie a branch a partir de integration:${NC}"
    echo -e "  ${GREEN}git checkout integration${NC}"
    echo -e "  ${GREEN}git pull origin integration${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi

# Verificar se o merge-base é o mesmo commit do integration (ou um commit mais recente)
INTEGRATION_COMMIT=$(git rev-parse $INTEGRATION_REF)
CURRENT_COMMIT=$(git rev-parse HEAD)

# Se o merge-base é o integration ou um commit mais recente, está OK
if [ "$MERGE_BASE" = "$INTEGRATION_COMMIT" ] || git merge-base --is-ancestor $INTEGRATION_COMMIT $MERGE_BASE 2>/dev/null; then
    echo -e "${GREEN}✅ Branch '$BRANCH_NAME' foi criada a partir de '$INTEGRATION_BRANCH'${NC}"
    exit 0
else
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$INTEGRATION_BRANCH'${NC}"
    echo -e "${YELLOW}Por favor, recrie a branch a partir de integration:${NC}"
    echo -e "  ${GREEN}git checkout integration${NC}"
    echo -e "  ${GREEN}git pull origin integration${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi
