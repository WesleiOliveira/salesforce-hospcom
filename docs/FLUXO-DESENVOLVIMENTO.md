# Fluxo de Desenvolvimento

Este documento descreve o processo de desenvolvimento e as regras para criação de branches no projeto.

## Padrão de Nomenclatura de Branches

Todas as branches de desenvolvimento devem seguir o padrão:

```
feat-{area *opcional}-{numero do card da demanda}
```

### Exemplos válidos:
- `feat-0001` - Branch sem área específica
- `feat-vendas-0001` - Branch para área de vendas
- `feat-financeiro-1234` - Branch para área financeira
- `feat-area-teste-5678` - Branch com área composta

### Exemplos inválidos:
- `feature-0001` - Não começa com `feat-`
- `feat-0001-vendas` - Número do card deve estar no final
- `feat-vendas` - Falta o número do card
- `vendas-0001` - Falta o prefixo `feat-`

## Branch Base: stepMaster

**IMPORTANTE**: Todas as branches de desenvolvimento **DEVEM** ser criadas a partir da branch `stepMaster`.

### Como criar uma branch corretamente:

```bash
# 1. Certifique-se de estar na branch stepMaster
git checkout stepMaster

# 2. Atualize a branch stepMaster com as últimas alterações
git pull origin stepMaster

# 3. Crie sua branch de desenvolvimento a partir de stepMaster
git checkout -b feat-vendas-0001

# 4. Agora você pode começar a desenvolver
```

### ❌ NÃO faça isso:

```bash
# NÃO crie branch a partir de main, develop ou outras branches
git checkout main
git checkout -b feat-vendas-0001  # ❌ ERRADO!

# NÃO crie branch sem atualizar stepMaster primeiro
git checkout stepMaster
git checkout -b feat-vendas-0001  # ⚠️ Pode estar desatualizado
```

## Validações de Pre-Commit

Quando você tentar fazer commit, o hook de pre-commit executará automaticamente as seguintes validações:

### 1. Validação do Nome da Branch
- Verifica se o nome da branch segue o padrão `feat-{area}-{numero}`
- Se não seguir, o commit será bloqueado

### 2. Validação da Origem da Branch
- Verifica se a branch foi criada a partir de `stepMaster`
- Se não foi, o commit será bloqueado

### 3. Prettier (Formatação de Código)
- Formata automaticamente os arquivos modificados
- Garante consistência no estilo de código

### 4. ESLint (Análise de Código JavaScript/LWC)
- Valida código JavaScript e Lightning Web Components
- Verifica boas práticas e possíveis erros

### 5. PMD (Análise de Código Apex)
- Analisa código Apex (classes e triggers)
- Verifica melhores práticas, performance e segurança

## Instalação do PMD

O PMD é necessário para a validação de código Apex. Se você ainda não tem instalado:

### macOS (usando Homebrew):
```bash
brew install pmd
```

### Outros sistemas:
Baixe o PMD de: https://pmd.github.io/

**Nota**: Se o PMD não estiver instalado, a validação PMD será pulada, mas as outras validações continuarão funcionando.

## Resolução de Problemas

### Erro: "Nome da branch não segue o padrão esperado"
**Solução**: Renomeie sua branch para seguir o padrão `feat-{area}-{numero}`:
```bash
git branch -m feat-vendas-0001
```

### Erro: "Branch não foi criada a partir de stepMaster"
**Solução**: Recrie a branch a partir de stepMaster:
```bash
# Salve suas alterações
git stash

# Vá para stepMaster e atualize
git checkout stepMaster
git pull origin stepMaster

# Crie a branch novamente
git checkout -b feat-vendas-0001

# Restaure suas alterações
git stash pop
```

### Erro: "ESLint encontrou problemas"
**Solução**: Corrija os problemas indicados pelo ESLint. Você pode executar manualmente:
```bash
npm run lint
```

### Erro: "PMD encontrou problemas"
**Solução**: Corrija os problemas indicados pelo PMD. Você pode executar manualmente:
```bash
./scripts/run-pmd.sh
```

## Fluxo de Merge para Integration

Após terminar o desenvolvimento na branch `feat-{area}-{numero}`, você deve criar uma branch de merge para a branch `integration`.

### Padrão de Nomenclatura da Branch de Merge

A branch de merge deve seguir o padrão:

```
merge-{area *opcional}-{numero do card da demanda}-integration
```

### Exemplos válidos:
- `merge-0001-integration` - Branch de merge sem área específica
- `merge-vendas-0001-integration` - Branch de merge para área de vendas
- `merge-financeiro-1234-integration` - Branch de merge para área financeira

### Como criar a branch de merge:

```bash
# 1. Certifique-se de estar na branch integration
git checkout integration

# 2. Atualize a branch integration com as últimas alterações
git pull origin integration

# 3. Crie a branch de merge a partir de integration
git checkout -b merge-vendas-0001-integration

# 4. Faça merge das branches feat que você desenvolveu
git merge feat-vendas-0001
# Se tiver múltiplas branches feat:
# git merge feat-vendas-0001 feat-vendas-0002

# 5. Resolva conflitos se houver (se necessário)

# 6. Faça push da branch de merge
git push origin merge-vendas-0001-integration
```

### Validações da Branch de Merge

A branch de merge será validada automaticamente quando você criar o Pull Request:

1. **Validação do Nome**: Deve seguir o padrão `merge-{area}-{numero}-integration`
2. **Validação da Origem**: Deve ter sido criada a partir de `integration`
3. **Validação de Commits**: Todos os commits devem vir de outras branches (branches feat), não podem ser commits diretos na branch de merge
4. **Validação de Código**: Prettier e ESLint serão executados

### Criando o Pull Request

1. Crie o Pull Request da sua branch `merge-{area}-{numero}-integration` para `integration`
2. O workflow de validação será executado automaticamente
3. Aguarde a aprovação dos revisores designados

### Aprovação e Validação no Salesforce

Após o PR ser aprovado pelos revisores designados:

1. **Comente "validar" no PR** para iniciar a validação na org de homolog do Salesforce
2. O workflow irá:
   - Executar a validação do código na org de homolog
   - Se **sucesso**: Habilitar o botão de merge e adicionar labels indicando que está pronto
   - Se **falha**: 
     - Comentar no PR com os erros encontrados
     - Revogar as aprovações anteriores automaticamente
     - Você precisará corrigir os erros e solicitar nova aprovação

### Exemplo de Fluxo Completo

```bash
# 1. Desenvolvimento na branch feat
git checkout stepMaster
git pull origin stepMaster
git checkout -b feat-vendas-0001
# ... desenvolve e faz commits ...

# 2. Criar branch de merge
git checkout integration
git pull origin integration
git checkout -b merge-vendas-0001-integration

# 3. Fazer merge das branches feat
git merge feat-vendas-0001

# 4. Push e criar PR
git push origin merge-vendas-0001-integration
# Criar PR no GitHub: merge-vendas-0001-integration → integration

# 5. Aguardar aprovação e comentar "validar" no PR
# 6. Após validação bem-sucedida, fazer merge do PR
```

## Resolução de Problemas - Branch de Merge

### Erro: "Nome da branch de merge não segue o padrão esperado"
**Solução**: Renomeie sua branch para seguir o padrão `merge-{area}-{numero}-integration`:
```bash
git branch -m merge-vendas-0001-integration
```

### Erro: "Branch de merge não foi criada a partir de integration"
**Solução**: Recrie a branch a partir de integration:
```bash
# Salve suas alterações
git stash

# Vá para integration e atualize
git checkout integration
git pull origin integration

# Crie a branch novamente
git checkout -b merge-vendas-0001-integration

# Restaure suas alterações
git stash pop
```

### Erro: "Alguns commits não foram encontrados em outras branches"
**Solução**: A branch de merge deve conter apenas commits que foram mergeados de branches feat. Não faça commits diretos na branch de merge. Se necessário:
```bash
# Crie uma branch feat temporária para seus commits
git checkout -b feat-temp-commits
git add .
git commit -m "feat: suas alterações"
git checkout merge-vendas-0001-integration
git merge feat-temp-commits
```

### Erro na validação do Salesforce
**Solução**: 
1. Verifique os erros comentados no PR
2. Corrija os problemas no código
3. Faça commit e push das correções
4. Solicite nova aprovação
5. Comente "validar" novamente no PR

## Sincronização Automática: Integration → Homolog

Existe um processo automático agendado que sincroniza a branch `integration` com a branch `homolog` através de deploy automático na org de homologação.

### Como Funciona

1. **Agendamento**: O workflow executa automaticamente a cada 3 horas (00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00)

2. **Detecção de Mudanças**: 
   - Calcula o delta (diferenças) entre as branches `homolog` e `integration`
   - Se não houver mudanças, o processo é encerrado

3. **Deploy Automático**:
   - Se houver mudanças, executa deploy na org de homolog do Salesforce
   - Apenas os arquivos modificados são deployados (deploy delta)

4. **Em Caso de Sucesso**:
   - ✅ Faz merge automático de `integration` para `homolog`
   - ✅ A branch `homolog` é atualizada automaticamente

5. **Em Caso de Falha**:
   - ❌ O deploy não é realizado
   - 📄 O log de erro é salvo em `logs/deploy-errors/deploy-error-{timestamp}.log`
   - 📝 O log é commitado na branch `homolog` para referência
   - ⚠️ A branch `homolog` **não** é atualizada

### Execução Manual

O workflow também pode ser executado manualmente através do GitHub Actions:

1. Acesse: **Actions** → **Sync Homolog - Deploy Automático Agendado**
2. Clique em **Run workflow**
3. Selecione a branch (geralmente `main` ou `integration`)
4. Clique em **Run workflow**

### Logs de Erro

Quando um deploy falha, o log de erro é salvo em:
```
logs/deploy-errors/deploy-error-YYYYMMDD_HHMMSS.log
```

O log contém:
- Data e hora do erro
- Branch e commit relacionados
- Erros detalhados do deploy
- Lista de arquivos modificados
- Lista de commits que causaram o erro

### Monitoramento

Para monitorar o processo:
1. Acesse **Actions** no GitHub
2. Filtre por workflow: **Sync Homolog - Deploy Automático Agendado**
3. Verifique os logs de cada execução
4. Em caso de falhas recorrentes, verifique os logs salvos na branch `homolog`

### Importante

- ⚠️ A branch `homolog` é atualizada automaticamente apenas em caso de sucesso no deploy
- ⚠️ Se o deploy falhar, a branch `homolog` permanece inalterada
- ⚠️ Os logs de erro são sempre salvos para análise posterior
- ⚠️ O processo não interfere com o trabalho manual na branch `homolog`

## Fluxo de Merge para Produção (Main)

Após o código estar na branch `stepMaster`, você pode criar uma branch de merge para a branch `main` (produção).

### Padrão de Nomenclatura da Branch de Merge para Produção

A branch de merge para produção deve seguir o padrão:

```
merge-{area *opcional}-{numero do card da demanda}-stepMaster
```

### Exemplos válidos:
- `merge-0001-stepMaster` - Branch de merge sem área específica
- `merge-vendas-0001-stepMaster` - Branch de merge para área de vendas
- `merge-financeiro-1234-stepMaster` - Branch de merge para área financeira

### Como criar a branch de merge para produção:

```bash
# 1. Certifique-se de estar na branch stepMaster
git checkout stepMaster

# 2. Atualize a branch stepMaster com as últimas alterações
git pull origin stepMaster

# 3. Crie a branch de merge a partir de stepMaster
git checkout -b merge-vendas-0001-stepMaster

# 4. Faça merge das branches que você desenvolveu (se necessário)
# Normalmente você já terá feito merge na stepMaster anteriormente

# 5. Faça push da branch de merge
git push origin merge-vendas-0001-stepMaster
```

**Ou use o script helper:**
```bash
./scripts/create-merge-branch-prod.sh vendas 0001
```

### Validações da Branch de Merge para Produção

A branch de merge será validada automaticamente quando você criar o Pull Request:

1. **Validação do Nome**: Deve seguir o padrão `merge-{area}-{numero}-stepMaster`
2. **Validação da Origem**: Deve ter sido criada a partir de `stepMaster`
3. **Validação de Commits**: Todos os commits devem vir de outras branches, não podem ser commits diretos na branch de merge
4. **Validação de Código**: Prettier e ESLint serão executados

### Criando o Pull Request para Produção

1. Crie o Pull Request da sua branch `merge-{area}-{numero}-stepMaster` para `main`
2. O workflow de validação será executado automaticamente
3. Aguarde a aprovação dos revisores designados

### Aprovação e Validação no Salesforce (Produção)

Após o PR ser aprovado pelos revisores designados:

1. **Comente "validar" no PR** para iniciar a validação na org de produção do Salesforce
2. O workflow irá:
   - Executar a validação do código na org de produção
   - Se **sucesso**: Habilitar o botão de merge e adicionar labels indicando que está pronto
   - Se **falha**: 
     - Comentar no PR com os erros encontrados
     - Revogar as aprovações anteriores automaticamente
     - Você precisará corrigir os erros e solicitar nova aprovação

### Exemplo de Fluxo Completo para Produção

```bash
# 1. Código já está na stepMaster (após passar por integration e homolog)

# 2. Criar branch de merge para produção
git checkout stepMaster
git pull origin stepMaster
git checkout -b merge-vendas-0001-stepMaster

# 3. Push e criar PR
git push origin merge-vendas-0001-stepMaster
# Criar PR no GitHub: merge-vendas-0001-stepMaster → main

# 4. Aguardar aprovação e comentar "validar" no PR
# 5. Após validação bem-sucedida, fazer merge do PR
```

## Sincronização Automática: stepMaster → Main (Produção)

Existe um processo automático agendado que sincroniza a branch `stepMaster` com a branch `main` através de deploy automático na org de produção.

### Como Funciona

1. **Agendamento**: O workflow executa automaticamente a cada 3 horas (00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00)

2. **Detecção de Mudanças**: 
   - Calcula o delta (diferenças) entre as branches `main` e `stepMaster`
   - Se não houver mudanças, o processo é encerrado

3. **Deploy Automático**:
   - Se houver mudanças, executa deploy na org de produção do Salesforce
   - Apenas os arquivos modificados são deployados (deploy delta)

4. **Em Caso de Sucesso**:
   - ✅ Faz merge automático de `stepMaster` para `main`
   - ✅ A branch `main` é atualizada automaticamente

5. **Em Caso de Falha**:
   - ❌ O deploy não é realizado
   - 📄 O log de erro é salvo em `logs/deploy-errors/deploy-error-prod-{timestamp}.log`
   - 📝 O log é commitado na branch `main` para referência
   - ⚠️ A branch `main` **não** é atualizada

### Execução Manual

O workflow também pode ser executado manualmente através do GitHub Actions:

1. Acesse: **Actions** → **Sync Main - Deploy Automático Agendado (Produção)**
2. Clique em **Run workflow**
3. Selecione a branch (geralmente `main` ou `stepMaster`)
4. Clique em **Run workflow**

### Logs de Erro (Produção)

Quando um deploy falha, o log de erro é salvo em:
```
logs/deploy-errors/deploy-error-prod-YYYYMMDD_HHMMSS.log
```

O log contém:
- Data e hora do erro
- Branch e commit relacionados
- Erros detalhados do deploy
- Lista de arquivos modificados
- Lista de commits que causaram o erro

### Importante - Produção

- ⚠️ A branch `main` é atualizada automaticamente apenas em caso de sucesso no deploy
- ⚠️ Se o deploy falhar, a branch `main` permanece inalterada
- ⚠️ Os logs de erro são sempre salvos para análise posterior
- ⚠️ O processo não interfere com o trabalho manual na branch `main`
- ⚠️ **ATENÇÃO**: Deploy em produção deve ser feito com muito cuidado!
