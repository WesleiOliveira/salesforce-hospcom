# Template de Secrets para GitHub Actions

Este arquivo serve como referência para configurar os secrets necessários no GitHub.

## 📍 Localização

**GitHub Repository** → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

## 🔐 Secrets Necessários

> **Nota**: Não é necessário configurar credenciais para o ambiente de DEV, pois não há validação ou deploy automático via CI/CD para esse ambiente.

### Ambiente de Homologação (HOMOLOG)

| Nome do Secret | Descrição | Exemplo |
|---------------|-----------|---------|
| `SF_USERNAME_HOMOLOG` | Usuário do org de homologação | `user@homolog.com` |
| `SF_PASSWORD_HOMOLOG` | Senha do usuário | `SuaSenha123!` |
| `SF_SECURITY_TOKEN_HOMOLOG` | Token de segurança do usuário | `ABC123XYZ456` |
| `SF_LOGIN_URL_HOMOLOG` | URL de login do Salesforce | `https://test.salesforce.com` |

### Ambiente de Staging

| Nome do Secret | Descrição | Exemplo |
|---------------|-----------|---------|
| `SF_USERNAME_STAGING` | Usuário do org de staging | `user@staging.com` |
| `SF_PASSWORD_STAGING` | Senha do usuário | `SuaSenha123!` |
| `SF_SECURITY_TOKEN_STAGING` | Token de segurança do usuário | `ABC123XYZ456` |
| `SF_LOGIN_URL_STAGING` | URL de login do Salesforce | `https://test.salesforce.com` |

### Ambiente de Produção (PROD)

| Nome do Secret | Descrição | Exemplo |
|---------------|-----------|---------|
| `SF_USERNAME_PROD` | Usuário do org de produção | `user@prod.com` |
| `SF_PASSWORD_PROD` | Senha do usuário | `SuaSenha123!` |
| `SF_SECURITY_TOKEN_PROD` | Token de segurança do usuário | `ABC123XYZ456` |
| `SF_LOGIN_URL_PROD` | URL de login do Salesforce | `https://login.salesforce.com` |

### Opcionais

| Nome do Secret | Descrição | Exemplo |
|---------------|-----------|---------|
| `APEX_TEST_CLASSES` | Classes de teste separadas por vírgula (opcional) | `TestClass1,TestClass2,TestClass3` |

## 🔑 Como Obter o Security Token

1. Acesse o Salesforce como o usuário configurado
2. Navegue até: **Setup** → **My Personal Information** → **Reset My Security Token**
3. Clique em **Reset Security Token**
4. Verifique seu email para receber o novo token
5. Copie o token e adicione como secret no GitHub

## 🌐 URLs de Login

### Sandbox/Development
- `https://test.salesforce.com`

### Production
- `https://login.salesforce.com`

### Custom Domain
- `https://seu-domain.my.salesforce.com`

## ⚠️ Boas Práticas de Segurança

1. **Use contas de serviço dedicadas** para CI/CD
2. **Nunca commite** credenciais no código
3. **Rotacione tokens** regularmente (recomendado: a cada 90 dias)
4. **Use MFA** nas contas de serviço quando possível
5. **Monitore** o uso das credenciais
6. **Limite permissões** das contas apenas ao necessário

## ✅ Checklist de Configuração

- [ ] Todos os secrets de HOMOLOG configurados
- [ ] Todos os secrets de STAGING configurados
- [ ] Todos os secrets de PROD configurados
- [ ] Environments configurados (staging, production)
- [ ] Required reviewers configurados para production
- [ ] Testes locais passando
- [ ] Primeiro workflow de CI executado com sucesso

> **Nota**: Secrets de DEV não são necessários, pois não há CI/CD automático para esse ambiente.
