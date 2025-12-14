# Instruções para Agentes de IA - Salesforce Hospcom

## 🏗️ Arquitetura e Estrutura

Este é um projeto **Salesforce DX** com componentes Lightning (LWC e Aura) e uma pipeline CI/CD completa com GitHub Actions.

**Estrutura principal:**
- `force-app/main/default/` - Código Salesforce (classes Apex, LWC, Aura, triggers, etc.)
- `scripts/` - Scripts bash para validação, deploy e automações de branch
- `.github/workflows/` - Pipelines CI/CD para integração contínua e deploys automáticos
- `docs/` - Documentação completa do fluxo de desenvolvimento

## 🔄 Fluxo de Branches e CI/CD

**CRÍTICO:** Este projeto usa um fluxo de branches específico com validações automáticas.

### Estrutura de Branches
```
stepMaster (base) → feat-{area}-{numero} → merge-{area}-{numero}-integration → integration
                                                                                      ↓
                                                                          (sync a cada 3h)
                                                                                      ↓
                                                                                  homolog
                                                                                      ↓
stepMaster → merge-{area}-{numero}-stepMaster → main → (sync a cada 3h) → main (prod)
```

**Nomenclatura obrigatória:**
- Features: `feat-{area}-{numero}` (ex: `feat-cobranca-001`)
- Merge para integration: `merge-{area}-{numero}-integration`
- Merge para main: `merge-{area}-{numero}-stepMaster`

**Scripts de validação:** Os scripts em `scripts/` validam nomes de branches e origens antes de permitir merges.

## 💻 Comandos de Desenvolvimento

### Validação Local (SEMPRE execute antes de push)
```bash
npm run ci:validate  # Prettier + ESLint + validação Salesforce
npm run lint         # Apenas ESLint
npm run prettier:verify  # Verifica formatação
```

### Testes
```bash
npm run test                  # Testes unitários LWC (Jest)
npm run test:unit:coverage    # Com cobertura
npm run test:unit:watch       # Modo watch
```

### Deploy e Validação Salesforce
```bash
npm run validate              # Valida no org dev
npm run validate:staging      # Valida no staging
npm run deploy:dev:dry        # Valida sem fazer deploy
npm run deploy:dev            # Deploy para dev
```

**IMPORTANTE:** Os scripts usam o CLI `sf` (Salesforce CLI v2). Certifique-se de que os orgs estão autenticados com os aliases: `dev`, `staging`, `prod`.

## 🧩 Padrões de Código

### Lightning Web Components (LWC)
- Localizados em `force-app/main/default/lwc/`
- Cada componente tem: `.js`, `.html`, `.css`, `.js-meta.xml`
- Testes em `__tests__/*.test.js` (Jest + @salesforce/sfdx-lwc-jest)
- **Exemplo:** `force-app/main/default/lwc/cobranca/` ou `kanbanBacklog/`

### Componentes Aura
- Localizados em `force-app/main/default/aura/`
- Convenção: Controller, Helper, Design, SVG
- **Exemplo:** `AnaliseDeEditais/`, `AtivosComodato/`

### Classes Apex
- Localizadas em `force-app/main/default/classes/`
- Testes seguem padrão `*Test.cls`
- **Exemplo:** `QuoteSyncUtil.cls`, `SAPProductIntegrationTEST.cls`

### Formatação e Linting
- **Prettier** para formatação automática (`.prettierrc`)
  - Plugins: `prettier-plugin-apex`, `@prettier/plugin-xml`
  - Sem trailing commas
  - Parser especial para LWC HTML
- **ESLint** para validação JavaScript (`.eslintrc.json`)
  - Base: `@salesforce/eslint-config-lwc/recommended`
  - Regras customizadas: `no-async-operation: warn`, `no-inner-html: warn`
  - **Testes:** Usa `plugin:jest/recommended` com regras específicas
- **Husky + lint-staged:** Pre-commit hook formata automaticamente

## 🤖 GitHub Actions e Workflows

**Validações automáticas em PRs:**
- `ci.yml` - Lint, testes e validação básica
- `pr-check.yml` - Validações específicas de PR
- `pr-integration-validation.yml` - PRs para `integration`
- `pr-main-validation.yml` - PRs para `main` (produção)

**Validação Salesforce via comentário:**
- Comente `validar` em PRs para `integration` → valida em homolog
- Comente `validar` em PRs para `main` → valida em produção

**Sincronizações automáticas:**
- `sync-homolog-scheduled.yml` - `integration` → `homolog` (a cada 3h)
- `sync-main-scheduled.yml` - `stepMaster` → `main` (a cada 3h)

## 📝 Convenções de Commit

- Use mensagens descritivas em português
- Siga os padrões do projeto (não há conventional commits obrigatório)
- Commits são validados em PRs para garantir que vêm das branches corretas

## 🔐 Secrets e Configuração

Os workflows exigem secrets configurados no GitHub:
- `SFDX_AUTH_URL_HOMOLOG` - Autenticação org homolog
- `SFDX_AUTH_URL_PROD` - Autenticação org produção

Veja `.github/SECRETS_TEMPLATE.md` para detalhes.

## 📚 Documentação Adicional

- **Implementação completa:** `docs/GUIA-IMPLEMENTACAO-GITHUB.md`
- **Fluxo de desenvolvimento:** `docs/FLUXO-DESENVOLVIMENTO.md`
- **CI/CD detalhado:** `README-CICD.md`

## ⚠️ Pontos de Atenção

1. **NUNCA** faça push direto para `main`, `homolog` ou `integration` - use PRs
2. **SEMPRE** siga a nomenclatura de branches - há validações automáticas
3. **Execute** `npm run ci:validate` antes de abrir PRs
4. **Aguarde** aprovação de revisores antes de merge
5. **Use** os scripts `scripts/create-merge-branch.sh` para criar branches de merge corretas
6. **Instale** dependências com `npm install --legacy-peer-deps` (conflito conhecido de peer dependencies)
