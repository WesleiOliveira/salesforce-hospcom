#!/bin/bash

# Script para validar que todos os commits que estão subindo estão em outra branch
# Isso garante que não há commits diretos na branch de merge

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
BASE_BRANCH=${1:-"integration"}

# Obter referência da branch base
BASE_REF=""
if git show-ref --verify --quiet refs/heads/$BASE_BRANCH; then
    BASE_REF="refs/heads/$BASE_BRANCH"
elif git show-ref --verify --quiet refs/remotes/origin/$BASE_BRANCH; then
    BASE_REF="refs/remotes/origin/$BASE_BRANCH"
else
    echo -e "${YELLOW}⚠️  Branch base '$BASE_BRANCH' não encontrada, pulando validação${NC}"
    exit 0
fi

# Obter commits que estão na branch atual mas não na base
COMMITS=$(git log $BASE_REF..HEAD --format="%H" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
    echo -e "${GREEN}✅ Nenhum commit novo para validar${NC}"
    exit 0
fi

echo -e "${YELLOW}🔍 Validando que commits vêm de outras branches...${NC}"

# Verificar cada commit
ALL_VALID=true
for commit in $COMMITS; do
    # Obter todas as branches que contêm este commit
    BRANCHES_WITH_COMMIT=$(git branch -a --contains $commit 2>/dev/null | grep -v "HEAD" | sed 's/^[* ] //' | sed 's/remotes\/origin\///' | sort -u)
    
    # Verificar se o commit existe em alguma branch feat ou merge (além da atual)
    FOUND_IN_OTHER_BRANCH=false
    for branch in $BRANCHES_WITH_COMMIT; do
        # Ignorar a branch atual e a branch base
        if [ "$branch" != "$BRANCH_NAME" ] && [ "$branch" != "$BASE_BRANCH" ] && [ "$branch" != "origin/$BASE_BRANCH" ]; then
            # Verificar se é uma branch feat ou merge
            if [[ "$branch" =~ ^(feat|merge)- ]] || [[ "$branch" =~ ^origin/(feat|merge)- ]]; then
                FOUND_IN_OTHER_BRANCH=true
                break
            fi
        fi
    done
    
    if [ "$FOUND_IN_OTHER_BRANCH" = false ]; then
        COMMIT_MSG=$(git log -1 --format="%s" $commit)
        echo -e "${RED}❌ Commit $commit não foi encontrado em outra branch:${NC}"
        echo -e "   ${YELLOW}$COMMIT_MSG${NC}"
        ALL_VALID=false
    fi
done

if [ "$ALL_VALID" = true ]; then
    echo -e "${GREEN}✅ Todos os commits foram validados e estão em outras branches${NC}"
    exit 0
else
    echo -e "${RED}❌ Erro: Alguns commits não foram encontrados em outras branches${NC}"
    echo -e "${YELLOW}A branch de merge deve conter apenas commits que foram mergeados de branches feat${NC}"
    exit 1
fi
