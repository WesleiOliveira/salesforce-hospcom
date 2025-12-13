# 🚀 CI/CD - Entrega Contínua Salesforce

Solução completa de CI/CD para desenvolvimento Salesforce com GitHub Actions.

## ⚡ Início Rápido

### 1. Implementação no GitHub

**Siga o guia completo**: [docs/GUIA-IMPLEMENTACAO-GITHUB.md](docs/GUIA-IMPLEMENTACAO-GITHUB.md)

### 2. Configurar Secrets no GitHub

Siga o guia em [.github/SECRETS_TEMPLATE.md](.github/SECRETS_TEMPLATE.md) para configurar todas as credenciais necessárias.

### 3. Estrutura de Branches

- `stepMaster` → Branch base para desenvolvimento
- `feat-{area}-{numero}` → Branches de desenvolvimento
- `integration` → Branch de integração
- `homolog` → Branch de homologação (sincronização automática)
- `main` → Branch de produção (sincronização automática)

### 4. Fluxo de Trabalho

```
stepMaster → feat-{area}-{numero} → merge-{area}-{numero}-integration → integration
                                                                                    ↓
                                                                        (automático a cada 3h)
                                                                                    ↓
                                                                              homolog
                                                                                    ↓
stepMaster → merge-{area}-{numero}-stepMaster → main → (automático a cada 3h) → main (produção)
```

## 📦 Scripts Disponíveis

### Validação
```bash
npm run validate          # Valida código no dev
npm run validate:staging  # Valida código no staging
npm run validate:prod     # Valida código no prod
npm run ci:validate       # Validação completa (prettier + lint + salesforce)
```

### Deploy
```bash
npm run deploy:dev        # Deploy para desenvolvimento
npm run deploy:staging    # Deploy para staging
npm run deploy:prod       # Deploy para produção
```

### Dry-Run (validação sem deploy)
```bash
npm run deploy:dev:dry
npm run deploy:staging:dry
npm run deploy:prod:dry
```

## 🔄 Workflows GitHub Actions

| Workflow | Trigger | Descrição |
|----------|---------|-----------|
| `ci.yml` | PR / Push | Validação e testes |
| `pr-check.yml` | Pull Request | Validações específicas de PR |
| `pr-integration-validation.yml` | PR para `integration` | Valida PRs para integration |
| `pr-validate-salesforce.yml` | Comentário "validar" | Valida no Salesforce (homolog) |
| `sync-homolog-scheduled.yml` | A cada 3h / Manual | Sincronização integration → homolog |
| `pr-main-validation.yml` | PR para `main` | Valida PRs para produção |
| `pr-validate-salesforce-prod.yml` | Comentário "validar" | Valida no Salesforce (produção) |
| `sync-main-scheduled.yml` | A cada 3h / Manual | Sincronização stepMaster → main |

## 📚 Documentação Completa

- [docs/GUIA-IMPLEMENTACAO-GITHUB.md](docs/GUIA-IMPLEMENTACAO-GITHUB.md) - **Guia completo de implementação**
- [docs/FLUXO-DESENVOLVIMENTO.md](docs/FLUXO-DESENVOLVIMENTO.md) - Fluxo completo de desenvolvimento
- [docs/RESUMO-FLUXO.md](docs/RESUMO-FLUXO.md) - Resumo executivo do fluxo
- [docs/CONFIGURACAO-GITHUB.md](docs/CONFIGURACAO-GITHUB.md) - Configurações do GitHub
- [.github/SECRETS_TEMPLATE.md](.github/SECRETS_TEMPLATE.md) - Template de secrets

## ✅ Checklist de Setup

- [ ] Seguir [GUIA-IMPLEMENTACAO-GITHUB.md](docs/GUIA-IMPLEMENTACAO-GITHUB.md)
- [ ] Secrets configurados no GitHub (HOMOLOG e PROD)
- [ ] Branch protection rules configuradas
- [ ] Revisores designados
- [ ] Workflows testados
- [ ] Equipe treinada

## 🆘 Suporte

Para problemas ou dúvidas:
1. Verifique a documentação completa em `docs/CI-CD.md`
2. Consulte os logs do GitHub Actions
3. Execute validações locais primeiro
