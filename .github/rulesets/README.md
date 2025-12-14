# GitHub Rulesets - Branch Protection Rules

Este diretório contém os arquivos JSON para configurar as Branch Protection Rules via GitHub Rulesets.

## 📋 Como Importar

### Método 1: Via Interface Web do GitHub

1. Acesse seu repositório no GitHub
2. Vá em **Settings** → **Rules** → **Rulesets**
3. Clique em **New ruleset** → **Import a ruleset**
4. Selecione o arquivo JSON correspondente à branch que deseja proteger
5. Revise as configurações e clique em **Create**

### Método 2: Via GitHub CLI

```bash
# Instalar GitHub CLI (se ainda não tiver)
# brew install gh (macOS)
# ou baixe de: https://cli.github.com/

# Autenticar
gh auth login

# Importar ruleset para integration
gh api repos/:owner/:repo/rulesets \
  --method POST \
  --input .github/rulesets/integration-ruleset.json

# Importar ruleset para main
gh api repos/:owner/:repo/rulesets \
  --method POST \
  --input .github/rulesets/main-ruleset.json

# Importar ruleset para stepMaster
gh api repos/:owner/:repo/rulesets \
  --method POST \
  --input .github/rulesets/stepMaster-ruleset.json

# Importar ruleset para homolog
gh api repos/:owner/:repo/rulesets \
  --method POST \
  --input .github/rulesets/homolog-ruleset.json
```

### Método 3: Via cURL

```bash
# Substitua OWNER e REPO pelos valores corretos
# Substitua YOUR_TOKEN por um token com permissão repo

# Integration
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/rulesets \
  -d @.github/rulesets/integration-ruleset.json

# Main
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/rulesets \
  -d @.github/rulesets/main-ruleset.json

# StepMaster
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/rulesets \
  -d @.github/rulesets/stepMaster-ruleset.json

# Homolog
curl -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/OWNER/REPO/rulesets \
  -d @.github/rulesets/homolog-ruleset.json
```

## 📁 Arquivos Disponíveis

### `integration-ruleset.json`

- **Branch**: `integration`
- **Requisitos**:
  - ✅ 1 revisor obrigatório antes do merge
  - ✅ Status check `validate-pr / validate-pr` deve passar
  - ✅ Branch deve estar atualizada antes do merge
  - ✅ Revoga aprovações quando novos commits são adicionados
  - ✅ Não permite force push
  - ✅ Não permite deleção da branch

### `main-ruleset.json`

- **Branch**: `main` (Produção)
- **Requisitos**:
  - ✅ 2 revisores obrigatórios antes do merge
  - ✅ Status check `validate-pr / validate-pr` deve passar
  - ✅ Branch deve estar atualizada antes do merge
  - ✅ Revoga aprovações quando novos commits são adicionados
  - ✅ Não permite force push
  - ✅ Não permite deleção da branch

### `stepMaster-ruleset.json`

- **Branch**: `stepMaster`
- **Requisitos**:
  - ✅ Não permite force push
  - ✅ Não permite deleção da branch

### `homolog-ruleset.json`

- **Branch**: `homolog`
- **Requisitos**:
  - ✅ Não permite force push
  - ✅ Não permite deleção da branch
  - ℹ️ Esta branch é atualizada automaticamente pelo workflow de sincronização

## ⚠️ Importante

- Cada arquivo JSON deve ser importado separadamente
- Certifique-se de que as branches existem antes de importar os rulesets
- O status check `validate-pr / validate-pr` deve existir nos workflows antes de ativar as regras
- Após importar, verifique se as regras estão ativas em **Settings** → **Rules** → **Rulesets**

## 🔍 Verificar Rulesets Existentes

```bash
# Via GitHub CLI
gh api repos/:owner/:repo/rulesets

# Via cURL
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/rulesets
```

## 📝 Notas

- Os rulesets substituem as Branch Protection Rules antigas do GitHub
- Rulesets oferecem mais flexibilidade e podem ser aplicados a múltiplas branches usando padrões
- Para editar um ruleset existente, use a interface web ou a API do GitHub
