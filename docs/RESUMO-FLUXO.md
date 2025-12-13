# Resumo do Fluxo de Desenvolvimento

Este documento fornece uma visão geral rápida do fluxo completo de desenvolvimento.

## 📋 Visão Geral

```
StepMaster → feat-{area}-{numero} → merge-{area}-{numero}-integration → integration → (automático a cada 3h) → homolog
                                                                                                                      ↓
StepMaster → merge-{area}-{numero}-stepMaster → main → (automático a cada 3h) → main (produção)
```

## 🔄 Fluxo Completo

### 1. Desenvolvimento (Branch Feat)

```bash
# Criar branch a partir de StepMaster
git checkout StepMaster
git pull origin StepMaster
git checkout -b feat-vendas-0001

# Desenvolver e fazer commits
# Validações automáticas no pre-commit:
# - Nome da branch
# - Origem da branch (StepMaster)
# - Prettier
# - ESLint
# - PMD
```

### 2. Merge para Integration

```bash
# Criar branch de merge a partir de integration
git checkout integration
git pull origin integration
git checkout -b merge-vendas-0001-integration

# Fazer merge das branches feat
git merge feat-vendas-0001

# Push e criar PR
git push origin merge-vendas-0001-integration
```

**Ou use o script helper:**
```bash
./scripts/create-merge-branch.sh vendas 0001 feat-vendas-0001
```

### 3. Pull Request para Integration

1. Criar PR: `merge-vendas-0001-integration` → `integration`
2. Validações automáticas:
   - Nome da branch de merge
   - Origem da branch (integration)
   - Commits vêm de outras branches
   - Prettier e ESLint
3. Aguardar aprovação dos revisores

### 4. Validação no Salesforce

1. Após aprovação, comentar **"validar"** no PR
2. Workflow executa validação na org de homolog
3. **Se sucesso:**
   - ✅ Botão de merge habilitado
   - Labels adicionados: `validated`, `ready-to-merge`
4. **Se falha:**
   - ❌ Erros comentados no PR
   - Aprovações revogadas automaticamente
   - Corrigir erros e solicitar nova aprovação

### 5. Sincronização Automática Integration → Homolog

1. **Agendamento**: Executa automaticamente a cada 3 horas
2. **Delta**: Calcula diferenças entre `homolog` e `integration`
3. **Deploy**: Se houver mudanças, faz deploy na org de homolog
4. **Sucesso**: Faz merge automático para `homolog`
5. **Falha**: Salva log de erro em `logs/deploy-errors/`

### 6. Merge para Produção (Main)

```bash
# Criar branch de merge a partir de StepMaster
git checkout StepMaster
git pull origin StepMaster
git checkout -b merge-vendas-0001-stepMaster

# Push e criar PR
git push origin merge-vendas-0001-stepMaster
```

**Ou use o script helper:**
```bash
./scripts/create-merge-branch-prod.sh vendas 0001
```

### 7. Pull Request para Main (Produção)

1. Criar PR: `merge-vendas-0001-stepMaster` → `main`
2. Validações automáticas:
   - Nome da branch de merge
   - Origem da branch (StepMaster)
   - Commits vêm de outras branches
   - Prettier e ESLint
3. Aguardar aprovação dos revisores

### 8. Validação no Salesforce (Produção)

1. Após aprovação, comentar **"validar"** no PR
2. Workflow executa validação na org de produção
3. **Se sucesso:**
   - ✅ Botão de merge habilitado
   - Labels adicionados: `validated`, `ready-to-merge`, `production-ready`
4. **Se falha:**
   - ❌ Erros comentados no PR
   - Aprovações revogadas automaticamente
   - Corrigir erros e solicitar nova aprovação

### 9. Sincronização Automática StepMaster → Main (Produção)

1. **Agendamento**: Executa automaticamente a cada 3 horas
2. **Delta**: Calcula diferenças entre `main` e `StepMaster`
3. **Deploy**: Se houver mudanças, faz deploy na org de produção
4. **Sucesso**: Faz merge automático para `main`
5. **Falha**: Salva log de erro em `logs/deploy-errors/deploy-error-prod-*.log`

## 📁 Arquivos e Scripts Criados

### Scripts de Validação

- `scripts/validate-branch-name.sh` - Valida padrão de branch feat
- `scripts/validate-branch-origin.sh` - Valida origem da branch feat (StepMaster)
- `scripts/validate-merge-branch-name.sh` - Valida padrão de branch de merge (integration)
- `scripts/validate-merge-branch-origin.sh` - Valida origem da branch de merge (integration)
- `scripts/validate-merge-branch-name-prod.sh` - Valida padrão de branch de merge (produção)
- `scripts/validate-merge-branch-origin-prod.sh` - Valida origem da branch de merge (StepMaster)
- `scripts/validate-commits-from-branches.sh` - Valida que commits vêm de outras branches
- `scripts/run-pmd.sh` - Executa análise PMD
- `scripts/create-merge-branch.sh` - Helper para criar branch de merge (integration)
- `scripts/create-merge-branch-prod.sh` - Helper para criar branch de merge (produção)

### Workflows GitHub Actions

- `.github/workflows/pr-integration-validation.yml` - Valida PRs para integration
- `.github/workflows/pr-validate-salesforce.yml` - Valida no Salesforce quando comentar "validar" (homolog)
- `.github/workflows/sync-homolog-scheduled.yml` - Sincronização automática integration → homolog (a cada 3h)
- `.github/workflows/pr-main-validation.yml` - Valida PRs para main (produção)
- `.github/workflows/pr-validate-salesforce-prod.yml` - Valida no Salesforce quando comentar "validar" (produção)
- `.github/workflows/sync-main-scheduled.yml` - Sincronização automática StepMaster → main (a cada 3h)

### Configurações

- `.husky/pre-commit` - Hook de pre-commit com todas as validações
- `config/pmd-ruleset.xml` - Regras PMD para análise de código Apex
- `.eslintrc.json` - Configuração ESLint

### Documentação

- `docs/FLUXO-DESENVOLVIMENTO.md` - Documentação completa do fluxo
- `docs/CONFIGURACAO-GITHUB.md` - Configurações necessárias no GitHub
- `docs/RESUMO-FLUXO.md` - Este arquivo

## ✅ Checklist de Configuração

### Local

- [x] Scripts de validação criados
- [x] Pre-commit hook configurado
- [x] PMD configurado
- [x] ESLint configurado
- [x] Prettier configurado

### GitHub

- [ ] Secrets configurados (SF_USERNAME_HOMOLOG, etc.)
- [ ] Branch protection rules configuradas para `integration`
- [ ] Revisores designados para PRs na `integration`
- [ ] Labels criados (opcional)
- [ ] CODEOWNERS configurado (opcional)

### Testes

- [ ] Testar criação de branch feat
- [ ] Testar validações de pre-commit
- [ ] Testar criação de branch de merge
- [ ] Testar validações de PR
- [ ] Testar validação no Salesforce (homolog)
- [ ] Testar sincronização automática homolog (execução manual do workflow)
- [ ] Testar criação de branch de merge para produção
- [ ] Testar validações de PR para main
- [ ] Testar validação no Salesforce (produção)
- [ ] Testar sincronização automática produção (execução manual do workflow)

## 🚀 Próximos Passos

1. Configurar secrets no GitHub
2. Configurar branch protection rules
3. Designar revisores
4. Testar o fluxo completo
5. Treinar a equipe no novo processo

## 📞 Suporte

Em caso de dúvidas, consulte:
- `docs/FLUXO-DESENVOLVIMENTO.md` - Documentação detalhada
- `docs/CONFIGURACAO-GITHUB.md` - Configurações do GitHub
- `.github/SECRETS_TEMPLATE.md` - Template de secrets
