# CI/CD - Entrega Contínua para Salesforce

Este documento descreve a configuração e utilização do pipeline de CI/CD para o projeto Salesforce.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Estrutura do Pipeline](#estrutura-do-pipeline)
- [Configuração Inicial](#configuração-inicial)
- [Workflows Disponíveis](#workflows-disponíveis)
- [Deploy Manual](#deploy-manual)
- [Secrets e Variáveis](#secrets-e-variáveis)
- [Boas Práticas](#boas-práticas)

## 🎯 Visão Geral

O pipeline de CI/CD está configurado para automatizar:
- ✅ Validação de código (lint, prettier, validação Salesforce)
- ✅ Execução de testes unitários (LWC e Apex)
- ✅ Deploy automatizado para diferentes ambientes
- ✅ Verificação de cobertura de código
- ✅ Geração de artefatos e changelogs

## 🏗️ Estrutura do Pipeline

### Branching Strategy

```
main (produção)
  └── develop (desenvolvimento/staging)
      └── feature/* (branches de features)
```

### Fluxo de Trabalho

1. **Feature Branch** → Pull Request para `develop`
   - Executa CI: validação e testes
   
2. **Merge em `develop`**
   - Deploy automático para ambiente de Desenvolvimento
   
3. **Merge em `main`**
   - Deploy automático para ambiente de Staging
   
4. **Deploy para Produção**
   - Manual via GitHub Actions (workflow_dispatch)
   - Requer aprovação e tag de versão

## ⚙️ Configuração Inicial

### 1. Configurar Secrets no GitHub

Acesse: `Settings > Secrets and variables > Actions` e adicione:

#### Para Ambiente de Desenvolvimento:
- `SF_USERNAME_DEV`: Usuário do org de desenvolvimento
- `SF_PASSWORD_DEV`: Senha do usuário
- `SF_SECURITY_TOKEN_DEV`: Token de segurança
- `SF_LOGIN_URL_DEV`: URL de login (https://test.salesforce.com ou https://login.salesforce.com)

#### Para Ambiente de Staging:
- `SF_USERNAME_STAGING`
- `SF_PASSWORD_STAGING`
- `SF_SECURITY_TOKEN_STAGING`
- `SF_LOGIN_URL_STAGING`

#### Para Ambiente de Produção:
- `SF_USERNAME_PROD`
- `SF_PASSWORD_PROD`
- `SF_SECURITY_TOKEN_PROD`
- `SF_LOGIN_URL_PROD`

#### Opcionais:
- `APEX_TEST_CLASSES`: Classes de teste separadas por vírgula (ex: "TestClass1,TestClass2")

### 2. Configurar Environments no GitHub

Para adicionar proteções de ambiente (approvals, etc):

1. Vá em `Settings > Environments`
2. Crie os ambientes: `staging` e `production`
3. Configure required reviewers para `production`

### 3. Autenticação Local (para scripts manuais)

```bash
# Desenvolvimento
sf org login web --alias dev --instance-url https://test.salesforce.com

# Staging
sf org login web --alias staging --instance-url https://test.salesforce.com

# Produção
sf org login web --alias prod --instance-url https://login.salesforce.com
```

## 🔄 Workflows Disponíveis

### 1. CI - Validação e Testes (`ci.yml`)

**Trigger:**
- Pull Requests para `main` ou `develop`
- Push para `main` ou `develop`

**Executa:**
- Lint e Prettier check
- ESLint
- Validação de código Salesforce (dry-run)
- Testes unitários LWC
- Testes Apex

### 2. CD - Deploy Dev (`deploy-dev.yml`)

**Trigger:**
- Push para `develop`
- Manual (workflow_dispatch)

**Executa:**
- Validação
- Deploy para ambiente de Desenvolvimento
- Execução de testes locais

### 3. CD - Deploy Staging (`deploy-staging.yml`)

**Trigger:**
- Push para `main`
- Manual (workflow_dispatch)

**Executa:**
- Validação
- Execução de testes Apex
- Deploy para ambiente de Staging
- Geração de package.xml das mudanças

### 4. CD - Deploy Production (`deploy-production.yml`)

**Trigger:**
- Manual apenas (workflow_dispatch)

**Requisitos:**
- Branch: `main`
- Versão: deve ser fornecida manualmente
- Notas da release: opcional

**Executa:**
- Validação completa
- Execução de TODOS os testes (RunAllTestsInOrg)
- Verificação de cobertura mínima (75%)
- Deploy para Produção
- Criação de tag Git
- Geração de release notes

## 🚀 Deploy Manual

### Via GitHub Actions

1. Acesse a aba **Actions** no repositório
2. Selecione o workflow desejado
3. Clique em **Run workflow**
4. Preencha os parâmetros (se houver)
5. Execute

### Via Scripts Locais

```bash
# Validar código
./scripts/validate.sh dev

# Deploy para desenvolvimento
./scripts/deploy.sh dev

# Deploy para staging
./scripts/deploy.sh staging

# Deploy para produção (com confirmação)
./scripts/deploy.sh prod

# Deploy sem testes (usar com cautela)
./scripts/deploy.sh dev --skip-tests

# Deploy apenas validação (dry-run)
./scripts/deploy.sh staging --dry-run

# Deploy com nível de teste específico
./scripts/deploy.sh dev --test-level RunAllTestsInOrg
```

### Via NPM Scripts

```bash
# Validar código
npm run validate

# Deploy para dev
npm run deploy:dev

# Deploy para staging
npm run deploy:staging

# Deploy para prod (com confirmação)
npm run deploy:prod
```

## 🔐 Secrets e Variáveis

### Como obter o Security Token

1. Acesse o Salesforce
2. Vá em: **Setup > My Personal Information > Reset My Security Token**
3. Clique em **Reset Security Token**
4. O token será enviado por email

### Boas Práticas de Segurança

- ✅ Nunca commite secrets no código
- ✅ Use GitHub Secrets para todas as credenciais
- ✅ Rotacione tokens regularmente
- ✅ Use contas de serviço específicas para CI/CD
- ✅ Configure MFA nos orgs

## 📊 Monitoramento

### Verificar Status dos Deploys

```bash
# Listar deploys recentes
sf project deploy report

# Ver detalhes de um deploy específico
sf project deploy report --job-id <job-id>
```

### Logs e Debug

```bash
# Ativar logs detalhados
export SF_LOG_LEVEL=DEBUG

# Ver logs do SFDX CLI
sfdx force:auth:list
```

## ✅ Boas Práticas

### Antes de fazer Merge

- [ ] Código foi revisado
- [ ] Testes passaram localmente
- [ ] Validação local passou (`npm run validate`)
- [ ] Conflitos resolvidos
- [ ] Commits seguem o padrão (conventional commits)

### Antes de Deploy em Produção

- [ ] Todos os testes passando
- [ ] Cobertura de código ≥ 75%
- [ ] Code review aprovado
- [ ] Documentação atualizada
- [ ] Rollback plan definido
- [ ] Release notes preparadas
- [ ] Comunicação com stakeholders

### Estrutura de Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona novo componente LWC
fix: corrige bug na validação
docs: atualiza documentação
refactor: reorganiza estrutura de classes
test: adiciona testes unitários
chore: atualiza dependências
```

## 🐛 Troubleshooting

### Pipeline falha na validação

```bash
# Executar validação local
npm run validate

# Ver detalhes do erro
sf project deploy report --job-id <job-id>
```

### Erro de autenticação

```bash
# Reautenticar
sf org login web --alias <alias>

# Verificar orgs autenticadas
sf org list
```

### Testes falhando

```bash
# Executar testes localmente
npm run test:unit

# Executar testes Apex
sf apex run test --class-names TestClass --result-format human
```

## 📚 Recursos Adicionais

- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Salesforce CI/CD Best Practices](https://trailhead.salesforce.com/content/learn/modules/sfdx_dev_model)

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique os logs do workflow no GitHub Actions
2. Execute validações locais
3. Consulte a documentação acima
4. Entre em contato com o time de DevOps
