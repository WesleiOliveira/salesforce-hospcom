#!/bin/bash

# Script para validar que a branch de merge foi criada a partir de stepMaster

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
STEP_MASTER_BRANCH="stepMaster"

# Verificar se a branch stepMaster existe
if ! git show-ref --verify --quiet refs/heads/$STEP_MASTER_BRANCH && ! git show-ref --verify --quiet refs/remotes/origin/$STEP_MASTER_BRANCH; then
    echo -e "${YELLOW}⚠️  Aviso: Branch '$STEP_MASTER_BRANCH' não encontrada localmente ou remotamente${NC}"
    echo -e "${YELLOW}Certifique-se de que a branch '$STEP_MASTER_BRANCH' existe antes de criar branches de merge${NC}"
    exit 1
fi

# Se já estamos na stepMaster, não precisamos validar
if [ "$BRANCH_NAME" = "$STEP_MASTER_BRANCH" ]; then
    echo -e "${GREEN}✅ Branch atual é stepMaster, validação não necessária${NC}"
    exit 0
fi

# Verificar se a branch atual foi criada a partir de stepMaster
STEP_MASTER_REF=""
if git show-ref --verify --quiet refs/heads/$STEP_MASTER_BRANCH; then
    STEP_MASTER_REF="refs/heads/$STEP_MASTER_BRANCH"
elif git show-ref --verify --quiet refs/remotes/origin/$STEP_MASTER_BRANCH; then
    STEP_MASTER_REF="refs/remotes/origin/$STEP_MASTER_BRANCH"
fi

if [ -z "$STEP_MASTER_REF" ]; then
    echo -e "${RED}❌ Erro: Não foi possível encontrar a referência da branch stepMaster${NC}"
    exit 1
fi

# Obter o commit base comum
MERGE_BASE=$(git merge-base HEAD $STEP_MASTER_REF 2>/dev/null || echo "")

if [ -z "$MERGE_BASE" ]; then
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$STEP_MASTER_BRANCH'${NC}"
    echo -e "${YELLOW}Por favor, crie a branch a partir de stepMaster:${NC}"
    echo -e "  ${GREEN}git checkout stepMaster${NC}"
    echo -e "  ${GREEN}git pull origin stepMaster${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi

# Verificar se o merge-base é o mesmo commit do stepMaster (ou um commit mais recente)
STEP_MASTER_COMMIT=$(git rev-parse $STEP_MASTER_REF)
CURRENT_COMMIT=$(git rev-parse HEAD)

# Se o merge-base é o stepMaster ou um commit mais recente, está OK
if [ "$MERGE_BASE" = "$STEP_MASTER_COMMIT" ] || git merge-base --is-ancestor $STEP_MASTER_COMMIT $MERGE_BASE 2>/dev/null; then
    echo -e "${GREEN}✅ Branch '$BRANCH_NAME' foi criada a partir de '$STEP_MASTER_BRANCH'${NC}"
    exit 0
else
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$STEP_MASTER_BRANCH'${NC}"
    echo -e "${YELLOW}Por favor, recrie a branch a partir de stepMaster:${NC}"
    echo -e "  ${GREEN}git checkout stepMaster${NC}"
    echo -e "  ${GREEN}git pull origin stepMaster${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi
