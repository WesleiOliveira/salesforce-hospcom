#!/bin/bash

# Script para validar que a branch foi criada a partir de StepMaster

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
STEP_MASTER="StepMaster"

# Verificar se a branch StepMaster existe
if ! git show-ref --verify --quiet refs/heads/$STEP_MASTER && ! git show-ref --verify --quiet refs/remotes/origin/$STEP_MASTER; then
    echo -e "${YELLOW}⚠️  Aviso: Branch '$STEP_MASTER' não encontrada localmente ou remotamente${NC}"
    echo -e "${YELLOW}Certifique-se de que a branch '$STEP_MASTER' existe antes de criar branches de desenvolvimento${NC}"
    exit 1
fi

# Se já estamos na StepMaster, não precisamos validar
if [ "$BRANCH_NAME" = "$STEP_MASTER" ]; then
    echo -e "${GREEN}✅ Branch atual é StepMaster, validação não necessária${NC}"
    exit 0
fi

# Verificar se a branch atual foi criada a partir de StepMaster
# Buscar o merge-base entre a branch atual e StepMaster
STEP_MASTER_REF=""
if git show-ref --verify --quiet refs/heads/$STEP_MASTER; then
    STEP_MASTER_REF="refs/heads/$STEP_MASTER"
elif git show-ref --verify --quiet refs/remotes/origin/$STEP_MASTER; then
    STEP_MASTER_REF="refs/remotes/origin/$STEP_MASTER"
fi

if [ -z "$STEP_MASTER_REF" ]; then
    echo -e "${RED}❌ Erro: Não foi possível encontrar a referência da branch StepMaster${NC}"
    exit 1
fi

# Obter o commit base comum
MERGE_BASE=$(git merge-base HEAD $STEP_MASTER_REF 2>/dev/null || echo "")

if [ -z "$MERGE_BASE" ]; then
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$STEP_MASTER'${NC}"
    echo -e "${YELLOW}Por favor, crie a branch a partir de StepMaster:${NC}"
    echo -e "  ${GREEN}git checkout StepMaster${NC}"
    echo -e "  ${GREEN}git pull origin StepMaster${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi

# Verificar se o merge-base é o mesmo commit do StepMaster (ou um commit mais recente)
STEP_MASTER_COMMIT=$(git rev-parse $STEP_MASTER_REF)
CURRENT_COMMIT=$(git rev-parse HEAD)

# Se o merge-base é o StepMaster ou um commit mais recente, está OK
if [ "$MERGE_BASE" = "$STEP_MASTER_COMMIT" ] || git merge-base --is-ancestor $STEP_MASTER_COMMIT $MERGE_BASE 2>/dev/null; then
    echo -e "${GREEN}✅ Branch '$BRANCH_NAME' foi criada a partir de '$STEP_MASTER'${NC}"
    exit 0
else
    echo -e "${RED}❌ Erro: A branch '$BRANCH_NAME' não foi criada a partir de '$STEP_MASTER'${NC}"
    echo -e "${YELLOW}Por favor, recrie a branch a partir de StepMaster:${NC}"
    echo -e "  ${GREEN}git checkout StepMaster${NC}"
    echo -e "  ${GREEN}git pull origin StepMaster${NC}"
    echo -e "  ${GREEN}git checkout -b $BRANCH_NAME${NC}"
    exit 1
fi
