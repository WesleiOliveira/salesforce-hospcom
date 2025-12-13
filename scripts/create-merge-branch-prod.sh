#!/bin/bash

# Script helper para criar branch de merge para produção (main)
# Uso: ./scripts/create-merge-branch-prod.sh [area] [numero] [branches-stepMaster...]
# Exemplo: ./scripts/create-merge-branch-prod.sh vendas 0001 merge-vendas-0001-stepMaster

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo -e "${RED}❌ Erro: Argumentos insuficientes${NC}"
    echo -e "${YELLOW}Uso: ./scripts/create-merge-branch-prod.sh [area] [numero] [branches-stepMaster...]${NC}"
    echo -e "${YELLOW}Exemplo: ./scripts/create-merge-branch-prod.sh vendas 0001 merge-vendas-0001-stepMaster${NC}"
    echo -e "${YELLOW}Exemplo: ./scripts/create-merge-branch-prod.sh vendas 0001 merge-vendas-0001-stepMaster merge-vendas-0002-stepMaster${NC}"
    exit 1
fi

AREA=$1
NUMERO=$2
shift 2
MERGE_BRANCHES=("$@")

# Construir nome da branch de merge
if [ -n "$AREA" ] && [ "$AREA" != "null" ]; then
    MERGE_BRANCH="merge-${AREA}-${NUMERO}-stepMaster"
else
    MERGE_BRANCH="merge-${NUMERO}-stepMaster"
fi

echo -e "${YELLOW}🔀 Criando branch de merge para produção: $MERGE_BRANCH${NC}"

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

# Ir para stepMaster
echo -e "${YELLOW}📥 Atualizando branch stepMaster...${NC}"
git checkout stepMaster 2>/dev/null || {
    echo -e "${YELLOW}Branch stepMaster não existe localmente, criando...${NC}"
    git checkout -b stepMaster origin/stepMaster 2>/dev/null || {
        echo -e "${RED}❌ Erro: Não foi possível criar/checkout branch stepMaster${NC}"
        exit 1
    }
}

git pull origin stepMaster

# Criar branch de merge
echo -e "${YELLOW}🌿 Criando branch de merge...${NC}"
git checkout -b $MERGE_BRANCH

# Fazer merge das branches de merge anteriores (se especificadas)
if [ ${#MERGE_BRANCHES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Nenhuma branch de merge especificada${NC}"
    echo -e "${YELLOW}Você pode fazer merge manualmente depois${NC}"
else
    for merge_branch in "${MERGE_BRANCHES[@]}"; do
        echo -e "${YELLOW}🔄 Fazendo merge de $merge_branch...${NC}"
        
        # Verificar se a branch existe
        if ! git show-ref --verify --quiet refs/heads/$merge_branch && ! git show-ref --verify --quiet refs/remotes/origin/$merge_branch; then
            echo -e "${RED}❌ Erro: Branch $merge_branch não encontrada${NC}"
            exit 1
        fi
        
        # Fazer merge
        git merge $merge_branch --no-edit || {
            echo -e "${RED}❌ Erro: Conflitos ao fazer merge de $merge_branch${NC}"
            echo -e "${YELLOW}Resolva os conflitos e continue manualmente${NC}"
            exit 1
        }
    done
fi

echo -e "${GREEN}✅ Branch de merge criada com sucesso!${NC}"
echo -e "${YELLOW}Próximos passos:${NC}"
echo -e "  1. ${GREEN}git push origin $MERGE_BRANCH${NC}"
echo -e "  2. Criar Pull Request no GitHub: $MERGE_BRANCH → main"
echo -e "  3. Aguardar aprovação e comentar 'validar' no PR"
