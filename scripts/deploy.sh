#!/bin/bash

# Script de deploy para Salesforce
# Uso: ./scripts/deploy.sh <ambiente> [opções]
# Ambientes: dev, staging, prod
# Opções:
#   --skip-tests: Pula a execução de testes
#   --dry-run: Apenas valida sem fazer deploy
#   --test-level <level>: Nível de testes (NoTestRun, RunLocalTests, RunAllTestsInOrg)

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função de ajuda
show_help() {
    echo "Uso: $0 <ambiente> [opções]"
    echo ""
    echo "Ambientes:"
    echo "  dev      - Ambiente de desenvolvimento"
    echo "  staging  - Ambiente de staging"
    echo "  prod     - Ambiente de produção"
    echo ""
    echo "Opções:"
    echo "  --skip-tests           Pula a execução de testes"
    echo "  --dry-run              Apenas valida sem fazer deploy"
    echo "  --test-level <level>   Nível de testes (NoTestRun, RunLocalTests, RunAllTestsInOrg)"
    echo "  --wait <minutes>       Tempo de espera para o deploy (padrão: 10)"
    echo "  --help                 Mostra esta ajuda"
    echo ""
}

# Validação de argumentos
if [ $# -lt 1 ]; then
    echo -e "${RED}Erro: Ambiente não especificado${NC}"
    show_help
    exit 1
fi

ENVIRONMENT=$1
shift

# Variáveis padrão
SKIP_TESTS=false
DRY_RUN=false
TEST_LEVEL="RunLocalTests"
WAIT_TIME=10
SOURCE_DIR="force-app"

# Parse de opções
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            TEST_LEVEL="NoTestRun"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --test-level)
            TEST_LEVEL="$2"
            shift 2
            ;;
        --wait)
            WAIT_TIME="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Opção desconhecida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Configuração por ambiente
case $ENVIRONMENT in
    dev)
        echo -e "${GREEN}🚀 Deploy para Desenvolvimento${NC}"
        ORG_ALIAS="dev"
        ;;
    staging)
        echo -e "${GREEN}🚀 Deploy para Staging${NC}"
        ORG_ALIAS="staging"
        ;;
    prod)
        echo -e "${YELLOW}⚠️  Deploy para PRODUÇÃO${NC}"
        read -p "Tem certeza que deseja fazer deploy em produção? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            echo -e "${RED}Deploy cancelado${NC}"
            exit 1
        fi
        ORG_ALIAS="prod"
        TEST_LEVEL="RunAllTestsInOrg"
        ;;
    *)
        echo -e "${RED}Erro: Ambiente inválido: $ENVIRONMENT${NC}"
        echo "Ambientes válidos: dev, staging, prod"
        exit 1
        ;;
esac

# Verificar se o org está autenticado
echo -e "${YELLOW}Verificando autenticação...${NC}"
if ! sf org display --target-org $ORG_ALIAS &>/dev/null; then
    echo -e "${RED}Erro: Org '$ORG_ALIAS' não está autenticada${NC}"
    echo "Execute: sf org login web --alias $ORG_ALIAS"
    exit 1
fi

# Mostrar informações do org
echo -e "${GREEN}Organização conectada:${NC}"
sf org display --target-org $ORG_ALIAS

# Validar código
echo -e "${YELLOW}Validando código...${NC}"
sf project deploy validate \
    --source-dir $SOURCE_DIR \
    --target-org $ORG_ALIAS \
    --ignore-warnings \
    --wait $WAIT_TIME

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Validação falhou${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Validação concluída com sucesso${NC}"

# Se for dry-run, apenas validar e sair
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}✅ Dry-run concluído com sucesso${NC}"
    exit 0
fi

# Deploy
echo -e "${YELLOW}Iniciando deploy...${NC}"
if [ "$SKIP_TESTS" = true ]; then
    echo -e "${YELLOW}⚠️  Executando deploy sem testes${NC}"
    sf project deploy start \
        --source-dir $SOURCE_DIR \
        --target-org $ORG_ALIAS \
        --ignore-warnings \
        --wait $WAIT_TIME \
        --test-level NoTestRun
else
    echo -e "${GREEN}Executando testes: $TEST_LEVEL${NC}"
    sf project deploy start \
        --source-dir $SOURCE_DIR \
        --target-org $ORG_ALIAS \
        --ignore-warnings \
        --wait $WAIT_TIME \
        --test-level $TEST_LEVEL
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
    
    # Mostrar resumo
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Deploy Summary${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "Ambiente: $ENVIRONMENT"
    echo "Org: $ORG_ALIAS"
    echo "Test Level: $TEST_LEVEL"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${RED}❌ Deploy falhou${NC}"
    exit 1
fi
