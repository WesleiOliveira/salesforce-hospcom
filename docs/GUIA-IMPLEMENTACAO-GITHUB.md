# Guia de Implementação no GitHub

Este guia fornece os passos necessários para implementar todo o fluxo de CI/CD no GitHub.

## 📋 Checklist de Implementação

### 1. Fazer Push das Alterações

```bash
# Verificar status
git status

# Adicionar todos os arquivos novos e modificados
git add .

# Fazer commit
git commit -m "feat: implementar fluxo completo de CI/CD com validações e sincronização automática"

# Fazer push
git push origin <sua-branch>
```

**Importante**: Se você estiver em uma branch de desenvolvimento, faça merge para a branch principal primeiro.

### 2. Verificar Branches Necessárias

Certifique-se de que as seguintes branches existem no repositório:

- ✅ `stepMaster` - Branch base para desenvolvimento
- ✅ `integration` - Branch de integração
- ✅ `homolog` - Branch de homologação (será criada automaticamente se não existir)
- ✅ `main` - Branch de produção

**Criar branches se necessário:**
```bash
# Criar stepMaster se não existir
git checkout -b stepMaster
git push origin stepMaster

# Criar integration se não existir
git checkout -b integration
git push origin integration

# Criar homolog se não existir (ou será criada automaticamente pelo workflow)
git checkout -b homolog
git push origin homolog
```

### 3. Configurar Secrets no GitHub

Acesse: **Repository Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### Secrets de Homologação (HOMOLOG)

| Nome do Secret | Valor |
|---------------|-------|
| `SF_USERNAME_HOMOLOG` | Usuário da org de homologação |
| `SF_PASSWORD_HOMOLOG` | Senha do usuário |
| `SF_SECURITY_TOKEN_HOMOLOG` | Token de segurança |
| `SF_LOGIN_URL_HOMOLOG` | URL de login (ex: `https://test.salesforce.com`) |

#### Secrets de Produção (PROD)

| Nome do Secret | Valor |
|---------------|-------|
| `SF_USERNAME_PROD` | Usuário da org de produção |
| `SF_PASSWORD_PROD` | Senha do usuário |
| `SF_SECURITY_TOKEN_PROD` | Token de segurança |
| `SF_LOGIN_URL_PROD` | URL de login (ex: `https://login.salesforce.com`) |

#### Secrets de Staging (se necessário)

| Nome do Secret | Valor |
|---------------|-------|
| `SF_USERNAME_STAGING` | Usuário da org de staging |
| `SF_PASSWORD_STAGING` | Senha do usuário |
| `SF_SECURITY_TOKEN_STAGING` | Token de segurança |
| `SF_LOGIN_URL_STAGING` | URL de login |

**Como obter o Security Token:**
1. Acesse o Salesforce como o usuário configurado
2. Navegue até: **Setup** → **My Personal Information** → **Reset My Security Token**
3. Clique em **Reset Security Token**
4. Verifique seu email para receber o novo token

### 4. Configurar Branch Protection Rules

#### Branch: `integration`

Acesse: **Repository Settings** → **Branches** → **Add rule** (ou edite regra existente)

**Configurações:**
- ✅ **Require pull request reviews before merging**
  - Número de revisores: **1** (ou conforme necessário)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - Status check: `validate-pr / validate-pr`
- ✅ **Require branches to be up to date before merging**
- ✅ **Do not allow bypassing the above settings** (recomendado)

#### Branch: `main` (Produção)

**Configurações:**
- ✅ **Require pull request reviews before merging**
  - Número de revisores: **2** (recomendado para produção)
  - ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - Status check: `validate-pr / validate-pr`
- ✅ **Require branches to be up to date before merging**
- ✅ **Do not allow bypassing the above settings** (obrigatório para produção)

#### Branch: `stepMaster`

**Configurações:**
- ✅ **Require pull request reviews before merging** (opcional, mas recomendado)
- ✅ **Do not allow force pushes**
- ✅ **Do not allow deletions**

### 5. Configurar Revisores (Opcional mas Recomendado)

#### Opção 1: CODEOWNERS

Crie o arquivo `.github/CODEOWNERS`:

```
# Revisores padrão para PRs na branch integration
/integration @usuario1 @usuario2 @team-desenvolvimento

# Revisores para PRs na branch main (produção)
/main @usuario1 @usuario2 @usuario3 @team-lead

# Revisores específicos por área
/force-app/main/default/classes/**/*.cls @apex-reviewers
/force-app/main/default/lwc/**/*.js @lwc-reviewers
```

#### Opção 2: Branch Protection Rules

Nas regras de proteção de branch, configure:
- **Restrict who can push to matching branches**
- Adicione os usuários/teams que podem fazer push direto

### 6. Criar Labels (Opcional)

Acesse: **Repository** → **Issues** → **Labels** → **New label**

Crie os seguintes labels:
- `validated` - PR validado com sucesso
- `ready-to-merge` - PR pronto para merge
- `production-ready` - PR pronto para produção
- `validation-failed` - Validação falhou

### 7. Verificar Permissões do GitHub Actions

Acesse: **Repository Settings** → **Actions** → **General** → **Workflow permissions**

**Configuração recomendada:**
- ✅ **Read and write permissions**
- ✅ **Allow GitHub Actions to create and approve pull requests**

Isso permite que os workflows:
- Comentem em PRs
- Revoguem aprovações
- Adicionem labels
- Façam merge automático

### 8. Testar os Workflows

#### Teste 1: Validação de Pre-Commit (Local)

```bash
# Criar uma branch de teste
git checkout stepMaster
git checkout -b feat-teste-0001

# Fazer uma alteração e tentar commitar
# O pre-commit deve executar as validações
git add .
git commit -m "feat: teste de validações"
```

#### Teste 2: Validação de PR para Integration

1. Criar branch de merge:
```bash
git checkout integration
git checkout -b merge-teste-0001-integration
git push origin merge-teste-0001-integration
```

2. Criar PR no GitHub: `merge-teste-0001-integration` → `integration`
3. Verificar se o workflow `pr-integration-validation.yml` é executado
4. Verificar se as validações estão funcionando

#### Teste 3: Validação no Salesforce (Homolog)

1. Criar PR para `integration` (ou usar o PR do teste 2)
2. Obter aprovação de um revisor
3. Comentar "validar" no PR
4. Verificar se o workflow `pr-validate-salesforce.yml` é executado
5. Verificar se o comentário com resultado é adicionado

#### Teste 4: Sincronização Automática Homolog

1. Acesse: **Actions** → **Sync Homolog - Deploy Automático Agendado**
2. Clique em **Run workflow**
3. Selecione a branch `main` ou `integration`
4. Clique em **Run workflow**
5. Verificar se o workflow executa corretamente

#### Teste 5: Validação de PR para Main (Produção)

1. Criar branch de merge:
```bash
git checkout stepMaster
git checkout -b merge-teste-0001-stepMaster
git push origin merge-teste-0001-stepMaster
```

2. Criar PR no GitHub: `merge-teste-0001-stepMaster` → `main`
3. Verificar se o workflow `pr-main-validation.yml` é executado

#### Teste 6: Validação no Salesforce (Produção)

1. Criar PR para `main` (ou usar o PR do teste 5)
2. Obter aprovação de revisores
3. Comentar "validar" no PR
4. Verificar se o workflow `pr-validate-salesforce-prod.yml` é executado

#### Teste 7: Sincronização Automática Produção

1. Acesse: **Actions** → **Sync Main - Deploy Automático Agendado (Produção)**
2. Clique em **Run workflow**
3. Selecione a branch `main` ou `stepMaster`
4. Clique em **Run workflow**
5. Verificar se o workflow executa corretamente

### 9. Monitorar Execuções

Após a implementação, monitore:

1. **Actions** → Verificar execuções dos workflows
2. **Branches** → Verificar se as branches estão sendo atualizadas corretamente
3. **Pull Requests** → Verificar se as validações estão funcionando
4. **Logs** → Verificar logs de erro em `logs/deploy-errors/` (se houver falhas)

### 10. Treinar a Equipe

Certifique-se de que a equipe está ciente:

- ✅ Padrão de nomenclatura de branches
- ✅ Processo de criação de branches
- ✅ Processo de criação de PRs
- ✅ Como comentar "validar" nos PRs
- ✅ Onde verificar logs de erro
- ✅ Como monitorar workflows

## ⚠️ Problemas Comuns

### Workflow não está sendo executado

- Verifique se os workflows estão no diretório `.github/workflows/`
- Verifique se os arquivos têm extensão `.yml` ou `.yaml`
- Verifique os logs em **Actions** → **Workflow runs**

### Validação do Salesforce falha

- Verifique se os secrets estão configurados corretamente
- Verifique se as credenciais estão válidas
- Verifique os logs do workflow para mais detalhes

### Aprovações não estão sendo revogadas

- Verifique se o workflow tem permissão `pull-requests: write`
- Verifique se o `GITHUB_TOKEN` tem as permissões necessárias
- Verifique os logs do workflow

### Botão de merge não está habilitado

- Verifique se todas as validações passaram
- Verifique se o PR tem aprovações suficientes
- Verifique se a branch está atualizada com a base
- Verifique as regras de proteção da branch

## ✅ Checklist Final

- [ ] Push das alterações realizado
- [ ] Branches necessárias criadas
- [ ] Secrets configurados (HOMOLOG e PROD)
- [ ] Branch protection rules configuradas
- [ ] Revisores designados
- [ ] Labels criados (opcional)
- [ ] Permissões do GitHub Actions configuradas
- [ ] Workflows testados
- [ ] Equipe treinada
- [ ] Monitoramento configurado

## 📞 Suporte

Em caso de dúvidas, consulte:
- `docs/FLUXO-DESENVOLVIMENTO.md` - Documentação detalhada do fluxo
- `docs/CONFIGURACAO-GITHUB.md` - Configurações do GitHub
- `.github/SECRETS_TEMPLATE.md` - Template de secrets
