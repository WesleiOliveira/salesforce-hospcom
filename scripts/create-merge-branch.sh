#!/bin/bash

# Script helper para criar branch de merge para integration
# Uso: ./scripts/create-merge-branch.sh [area] [numero] [branches-feat...]
# Exemplo: ./scripts/create-merge-branch.sh vendas 0001 feat-vendas-0001 feat-vendas-0002

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ Erro: Argumentos insuficientes${NC}"
    echo -e "${YELLOW}Uso: ./scripts/create-merge-branch.sh [area] [numero] [branches-feat...]${NC}"
    echo -e "${YELLOW}Exemplo: ./scripts/create-merge-branch.sh vendas 0001 feat-vendas-0001${NC}"
    echo -e "${YELLOW}Exemplo: ./scripts/create-merge-branch.sh vendas 0001 feat-vendas-0001 feat-vendas-0002${NC}"
    exit 1
fi

AREA=$1
NUMERO=$2
shift 2
FEAT_BRANCHES=("$@")

# Construir nome da branch de merge
if [ -n "$AREA" ] && [ "$AREA" != "null" ]; then
    MERGE_BRANCH="merge-${AREA}-${NUMERO}-integration"
else
    MERGE_BRANCH="merge-${NUMERO}-integration"
fi

echo -e "${YELLOW}🔀 Criando branch de merge: $MERGE_BRANCH${NC}"

# Verificar se já existe
if git show-ref --verify --quiet refs/heads/$MERGE_BRANCH; then
    echo -e "${RED}❌ Erro: Branch $MERGE_BRANCH já existe localmente${NC}"
    exit 1
fi

if git show-ref --verify --quiet refs/remotes/origin/$MERGE_BRANCH; then
    echo -e "${RED}❌ Erro: Branch $MERGE_BRANCH já existe remotamente${NC}"
    exit 1
fi

# Verificar se está em uma branch limpa
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ Erro: Você tem alterações não commitadas${NC}"
    echo -e "${YELLOW}Por favor, faça commit ou stash das alterações antes de continuar${NC}"
    exit 1
fi

# Ir para integration
echo -e "${YELLOW}📥 Atualizando branch integration...${NC}"
git checkout integration 2>/dev/null || {
    echo -e "${YELLOW}Branch integration não existe localmente, criando...${NC}"
    git checkout -b integration origin/integration 2>/dev/null || {
        echo -e "${RED}❌ Erro: Não foi possível criar/checkout branch integration${NC}"
        exit 1
    }
}

git pull origin integration

# Criar branch de merge
echo -e "${YELLOW}🌿 Criando branch de merge...${NC}"
git checkout -b $MERGE_BRANCH

# Fazer merge das branches feat
if [ ${#FEAT_BRANCHES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Nenhuma branch feat especificada para merge${NC}"
    echo -e "${YELLOW}Você pode fazer merge manualmente depois${NC}"
else
    for feat_branch in "${FEAT_BRANCHES[@]}"; do
        echo -e "${YELLOW}🔄 Fazendo merge de $feat_branch...${NC}"
        
        # Verificar se a branch existe
        if ! git show-ref --verify --quiet refs/heads/$feat_branch && ! git show-ref --verify --quiet refs/remotes/origin/$feat_branch; then
            echo -e "${RED}❌ Erro: Branch $feat_branch não encontrada${NC}"
            exit 1
        fi
        
        # Fazer merge
        git merge $feat_branch --no-edit || {
            echo -e "${RED}❌ Erro: Conflitos ao fazer merge de $feat_branch${NC}"
            echo -e "${YELLOW}Resolva os conflitos e continue manualmente${NC}"
            exit 1
        }
    done
fi

echo -e "${GREEN}✅ Branch de merge criada com sucesso!${NC}"
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "  1. ${GREEN}git push origin $MERGE_BRANCH${NC}"
echo -e "  2. Criar Pull Request no GitHub: $MERGE_BRANCH → integration"
echo -e "  3. Aguardar aprovação e comentar 'validar' no PR"
