# Configuração do GitHub para o Fluxo de Desenvolvimento

Este documento descreve as configurações necessárias no GitHub para o funcionamento completo do fluxo de desenvolvimento.

## Configuração de Branch Protection Rules

### Branch: `integration`

A branch `integration` deve ter as seguintes proteções configuradas:

1. **Required pull request reviews before merging**
   - ✅ Habilitado
   - Número de revisores requeridos: **1** (ou conforme necessário)
   - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require review from Code Owners (se configurado)

2. **Require status checks to pass before merging**
   - ✅ Habilitado
   - Status checks requeridos:
     - `validate-pr / validate-pr` (do workflow `pr-integration-validation.yml`)

3. **Require branches to be up to date before merging**
   - ✅ Habilitado

4. **Do not allow bypassing the above settings**
   - ✅ Habilitado (recomendado para maior segurança)

### Como configurar:

1. Acesse: **Repository Settings** → **Branches**
2. Clique em **Add rule** ou edite a regra existente para `integration`
3. Configure as opções acima
4. Em **Restrict who can push to matching branches**, adicione os usuários/teams que podem fazer push direto (se necessário)

## Configuração de CODEOWNERS (Opcional mas Recomendado)

Crie um arquivo `.github/CODEOWNERS` para definir revisores automáticos:

```
# Revisores padrão para PRs na branch integration
/integration @usuario1 @usuario2 @team-desenvolvimento

# Revisores específicos por área
/force-app/main/default/classes/**/*.cls @apex-reviewers
/force-app/main/default/lwc/**/*.js @lwc-reviewers
```

## Configuração de Secrets

Certifique-se de que todos os secrets necessários estão configurados:

### Secrets Obrigatórios para Validação no Salesforce:

- `SF_USERNAME_HOMOLOG` - Usuário da org de homologação
- `SF_PASSWORD_HOMOLOG` - Senha do usuário
- `SF_SECURITY_TOKEN_HOMOLOG` - Token de segurança
- `SF_LOGIN_URL_HOMOLOG` - URL de login do Salesforce

Veja mais detalhes em [SECRETS_TEMPLATE.md](../.github/SECRETS_TEMPLATE.md)

## Configuração de Labels

Crie os seguintes labels no repositório (opcional, mas recomendado):

- `validated` - PR validado com sucesso no Salesforce
- `ready-to-merge` - PR pronto para merge
- `validation-failed` - Validação falhou

### Como criar labels:

1. Acesse: **Repository** → **Issues** → **Labels**
2. Clique em **New label**
3. Crie cada label com as cores apropriadas

## Permissões Necessárias

### Para o Workflow `pr-validate-salesforce.yml`:

O workflow precisa das seguintes permissões:

- `pull-requests: write` - Para comentar e gerenciar reviews
- `issues: write` - Para adicionar labels
- `contents: read` - Para fazer checkout do código

Essas permissões são configuradas automaticamente quando o workflow usa `GITHUB_TOKEN`, mas podem ser ajustadas em:

**Repository Settings** → **Actions** → **General** → **Workflow permissions**

## Configuração de Revisores Padrão

Para definir revisores padrão para PRs na branch `integration`:

1. Acesse: **Repository Settings** → **Branches**
2. Edite a regra de proteção da branch `integration`
3. Em **Restrict who can push to matching branches**, adicione os revisores
4. Ou use o arquivo `CODEOWNERS` (recomendado)

## Testando a Configuração

### Teste 1: Validação de PR

1. Crie uma branch de merge: `merge-teste-0001-integration`
2. Crie um PR para `integration`
3. Verifique se o workflow `pr-integration-validation.yml` é executado
4. Verifique se as validações estão funcionando

### Teste 2: Validação no Salesforce

1. Crie um PR para `integration` (ou use o PR do teste 1)
2. Obtenha aprovação de um revisor
3. Comente "validar" no PR
4. Verifique se o workflow `pr-validate-salesforce.yml` é executado
5. Verifique se o comentário com resultado é adicionado
6. Se falhar, verifique se as aprovações foram revogadas

## Troubleshooting

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
