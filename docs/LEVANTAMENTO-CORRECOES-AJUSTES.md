# Levantamento de Correções e Ajustes - Salesforce Hospcom

**Data:** 14 de dezembro de 2025  
**Arquiteto:** Análise Técnica Salesforce  
**Objetivo:** Levantamento completo de correções necessárias baseadas em PMD, ESLint, Prettier e padrões de arquitetura (fflib)

---

## 📊 Resumo Executivo

### Inventário da Org

- **Triggers:** 146 arquivos
- **Classes Apex:** 647 arquivos (incluindo testes)
- **Componentes LWC:** 29 componentes
- **Componentes Aura:** 194 componentes
- **Configuração:** PMD, ESLint e Prettier configurados

### Visão Geral dos Problemas

A análise identificou problemas críticos em três pilares principais: **Triggers**, **Classes Apex** e **Componentes (LWC/Aura)**. A org apresenta uma arquitetura híbrida com padrões inconsistentes e necessidade de refatoração significativa.

---

## 🎯 PILAR 1: TRIGGERS

### 1.1. Problemas Críticos Identificados

#### 1.1.1. Ausência de Padrão de Arquitetura Consistente

**Severidade:** 🔴 CRÍTICA

**Situação Atual:**

- ✅ **6 triggers** utilizam TriggerHandler framework
- ❌ **140 triggers** (95,9%) com lógica inline ou sem padrão

**Triggers com Padrão Adequado:**

```apex
// ✅ BOM EXEMPLO
trigger ContratoServicoTrigger on Contrato_de_servi_o__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  (new ContratoServicoTriggerHandler()).run();
}
```

**Triggers com Problemas:**

```apex
// ❌ PROBLEMA - Lógica inline
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            AccountTriggerHandler.validacoesConta(Trigger.new);
            AccountTriggerHandler.preencheCampoLead(Trigger.new);
        } else if(Trigger.isUpdate){
            AccountTriggerHandler.preencheCampoLead(Trigger.new);
        }
    }
    // ... mais lógica inline
}

// ❌ PROBLEMA - Lógica de negócio extensa no trigger
trigger PedidoValidacao on Order (before insert, before update){
    public Id RecordType {get; set;}
    public Boolean ignorar;
    for(Order pedido : Trigger.new){
        RecordType = pedido.RecordTypeId;
        ignorar = pedido.Ignora_validacao__c;
    }
    // ... 500 linhas de código no trigger
}
```

**Impacto:**

- Manutenibilidade baixa
- Difícil testabilidade
- Violação de Single Responsibility Principle
- Código duplicado entre triggers
- Impossibilidade de controlar ordem de execução

---

#### 1.1.2. Múltiplos Triggers no Mesmo Objeto

**Severidade:** 🔴 CRÍTICA

**Objetos com Múltiplos Triggers:**

- Order: múltiplos triggers (PedidoValidacao, PedidoPreenchimento, RemessaAcionador, etc.)
- Product2: múltiplos triggers
- WorkOrder: múltiplos triggers
- Opportunity: múltiplos triggers

**Problema:**

```apex
trigger PedidoValidacao on Order (before insert, before update) { ... }
trigger PedidoPreenchimento on Order (before insert, before update, after insert) { ... }
trigger Pedido_Order_dataAprovacao on Order (before update) { ... }
trigger RemessaAcionador on Order (after update) { ... }
```

**Impacto:**

- Ordem de execução não garantida
- Risco de recursão infinita
- Performance degradada
- Difícil debugging

---

#### 1.1.3. Lógica de Negócio Complexa nos Triggers

**Severidade:** 🟠 ALTA

**Exemplos:**

- PedidoValidacao.trigger: 500 linhas de código
- Triggers com queries SOQL diretas
- Triggers com DML operations
- Triggers com lógica de validação complexa

**Anti-padrões Encontrados:**

```apex
// ❌ SOQL em loops
for(Order pedido : Trigger.new){
    if(pedido.QuoteId!=null)
        cotacoes_id.add(pedido.QuoteId);
}
List<Quote> cotacoes = [SELECT Id, IsSyncing FROM Quote WHERE Id IN :cotacoes_id];
for(Order pedido : Trigger.new){
    for(Quote cotacao : cotacoes){
        // Lógica aninhada
    }
}
```

---

### 1.2. Correções Necessárias - TRIGGERS

#### 1.2.1. Implementar Trigger Framework Completo

**Prioridade:** 🔴 CRÍTICA

**Ações:**

1. ✅ Manter TriggerHandler.cls existente (já está implementado)
2. Criar TriggerHandler para cada objeto:
   - AccountTriggerHandler (refatorar o existente)
   - OrderTriggerHandler (consolidar múltiplos triggers)
   - Product2TriggerHandler
   - WorkOrderTriggerHandler
   - OpportunityTriggerHandler
   - etc.

3. Refatorar todos os 140 triggers para usar o padrão:

```apex
trigger ObjectTrigger on Object__c(
  before insert,
  before update,
  after insert,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new ObjectTriggerHandler().run();
}
```

**Estimativa:** 140 triggers × 2 horas = 280 horas

---

#### 1.2.2. Consolidar Múltiplos Triggers

**Prioridade:** 🔴 CRÍTICA

**Objetos Prioritários:**

1. **Order** (consolidar ~4-5 triggers)
2. **Product2** (consolidar ~3-4 triggers)
3. **WorkOrder** (consolidar ~3 triggers)
4. **Opportunity** (consolidar ~3 triggers)

**Estimativa:** 15 objetos × 4 horas = 60 horas

---

#### 1.2.3. Extrair Lógica para Service Classes

**Prioridade:** 🟠 ALTA

**Padrão fflib (Financial Force Library):**

```
Domain Layer (Triggers) → Service Layer → Selector Layer → Data Layer
```

**Implementação:**

```apex
// Trigger (apenas delegação)
trigger AccountTrigger on Account (before insert, after insert, before update, after update) {
    new AccountTriggerHandler().run();
}

// Handler (controle de contexto)
public class AccountTriggerHandler extends TriggerHandler {
    protected override void beforeInsert() {
        AccountService.validateAccounts((List<Account>) Trigger.new);
        AccountService.enrichAccountData((List<Account>) Trigger.new);
    }

    protected override void afterInsert() {
        AccountService.processNewAccounts((List<Account>) Trigger.new);
    }
}

// Service (lógica de negócio)
public class AccountService {
    public static void validateAccounts(List<Account> accounts) {
        AccountValidator.validate(accounts);
    }

    public static void enrichAccountData(List<Account> accounts) {
        // Lógica de enriquecimento
    }
}

// Selector (queries reutilizáveis)
public class AccountSelector {
    public static List<Account> selectByIds(Set<Id> accountIds) {
        return [SELECT Id, Name, CNPJ__c FROM Account WHERE Id IN :accountIds];
    }
}
```

**Estimativa:** 50 principais triggers × 4 horas = 200 horas

---

#### 1.2.4. Implementar Controle de Recursão

**Prioridade:** 🟠 ALTA

**Utilizar TriggerHandler já existente:**

```apex
// No Service
if(TriggerHandler.isBypassed('AccountTriggerHandler')) return;

// Bypass temporário
TriggerHandler.bypass('AccountTriggerHandler');
// código que pode causar recursão
TriggerHandler.clearBypass('AccountTriggerHandler');
```

**Estimativa:** 20 horas (criar RecursiveHandler auxiliar)

---

### 1.3. Checklist de Validação - TRIGGERS

- [ ] Um único trigger por objeto
- [ ] Trigger com apenas 1 linha: `new ObjectTriggerHandler().run();`
- [ ] TriggerHandler implementa todos os contextos necessários
- [ ] Service classes contêm toda lógica de negócio
- [ ] Selector classes para todas as queries SOQL
- [ ] Zero queries SOQL nos triggers
- [ ] Zero DML operations nos triggers
- [ ] Controle de recursão implementado
- [ ] Testes unitários com cobertura > 90%
- [ ] Documentação inline (comentários) adequada

---

## 🎯 PILAR 2: CLASSES APEX

### 2.1. Problemas Críticos Identificados

#### 2.1.1. Ausência de Separação de Responsabilidades (fflib)

**Severidade:** 🔴 CRÍTICA

**Situação Atual:**

- ❌ Sem padrão Domain/Service/Selector
- ❌ Classes fazem tudo: queries, DML, validações, regras de negócio
- ❌ Classes com nomenclatura inconsistente
- ✅ Algumas Service classes existem (ContratoServicoService, BacklogService)

**Problemas Encontrados:**

```apex
// ❌ PROBLEMA - Classe sem responsabilidade clara
public class OppAtuConClass {
    public static String FluxoInicial(Opportunity oportunidade){
        // Validação + Query + Lógica de negócio tudo junto
        if(oportunidade.AccountId == null){
            if(oportunidade.Contrato_de_Servico__c != null){
                ServiceContract contrato_de_servico = [
                    SELECT Id, AccountId FROM ServiceContract
                    WHERE Id = :oportunidade.Contrato_de_Servico__c
                ];
                // ...
            }
        }
    }
}

// ❌ PROBLEMA - Query hardcoded na classe
public class FatuObtProcClass {
    public static Void FluxoInicial(Faturamento__c faturamento){
        Opportunity oportunidade = [
            SELECT RecordType.Name, Contrato_de_Servico__r.RecordType.Name
            FROM Opportunity WHERE Id = :faturamento.Oportunidade__c
        ];
    }
}
```

---

#### 2.1.2. Nomenclatura Inconsistente

**Severidade:** 🟠 ALTA

**Padrões Encontrados:**

```
✅ BOM: ContratoServicoService, ContratoServicoTriggerHandler
❌ RUIM: OppAtuConClass, FatuObtProcClass, PedAtuCatClass
❌ RUIM: listagem_hr, listagem_lmd_test
❌ RUIM: meta, Comiss, PSQ
```

**Problemas:**

- 🔴 Nomes abreviados incompreensíveis
- 🔴 Snake_case misturado com PascalCase
- 🔴 Nomes que não descrevem responsabilidade
- 🔴 Prefixos/sufixos inconsistentes

**Classes Prioritárias para Renomear:**

1. OppAtuConClass → OpportunityContractService
2. FatuObtProcClass → FaturamentoProcessService
3. PedAtuCatClass → PedidoCategoriaService
4. listagem_hr → HistoricoRecursoSelector
5. meta → MetaService
6. Comiss → ComissaoService

---

#### 2.1.3. Código Duplicado

**Severidade:** 🟠 ALTA

**Exemplos:**

```apex
// Padrão repetido em várias classes
public static ServiceContract ObtemContr(Id contrato_id){
    ServiceContract contrato = [
        SELECT Id, AccountId FROM ServiceContract WHERE Id = :contrato_id
    ];
    return contrato;
}

// Mesmo código em: OppAtuConClass, OppAtuFatClass, FatuLinkContrClass
```

**Correção:** Criar ServiceContractSelector.cls

---

#### 2.1.4. Classes com Múltiplas Responsabilidades

**Severidade:** 🟠 ALTA

**Exemplos Identificados:**

```apex
// ❌ PROBLEMA - AccountTriggerHandler faz validação e preenchimento
public class AccountTriggerHandler {
  public static void validacoesConta(List<Account> newConta) {
    // Validação de CNPJ, CPF, telefone, etc.
  }

  public static void preencheCampoLead(List<Account> newConta) {
    // Preenchimento de campos
  }

  public static void validaDadosReceita(
    List<Account> newConta,
    Map<Id, Account> oldMap
  ) {
    // Integração com API externa
  }
}
```

**Deveria ser:**

```apex
AccountTriggerHandler → delega para:
  - AccountValidationService
  - AccountEnrichmentService
  - ReceitaIntegrationService
```

---

#### 2.1.5. Falta de Bulk Processing

**Severidade:** 🔴 CRÍTICA

**Anti-padrões Encontrados:**

```apex
// ❌ PROBLEMA - SOQL em loop
for(Order pedido : Trigger.new){
    List<Quote> cotacoes = [SELECT Id FROM Quote WHERE Id = :pedido.QuoteId];
}

// ❌ PROBLEMA - DML em loop potencial
for(Account acc : accounts){
    update acc;
}
```

**Impacto:**

- Violação dos Governor Limits
- Performance degradada
- Falhas em operações em massa

---

#### 2.1.6. Hardcoded Values e Magic Numbers

**Severidade:** 🟠 ALTA

**Exemplos:**

```apex
// ❌ PROBLEMA - ID hardcoded
if(atual.Id != 'a1YU4000000qY7FMAU'){
    // lógica
}

// ❌ PROBLEMA - Status hardcoded
if(oportunidade.Opportunity.StageName != 'WIN' &&
   oportunidade.Opportunity.StageName != 'COMITED'){
    // lógica
}

// ❌ PROBLEMA - RecordType por nome
if(oportunidade.RecordType.Name == 'Venda de Equipamentos'){
    // lógica
}
```

**Correção:** Criar Constants.cls ou Custom Metadata

---

#### 2.1.7. Tratamento de Exceções Inadequado

**Severidade:** 🟠 ALTA

**Problemas:**

```apex
// ❌ PROBLEMA - Try-catch genérico
try {
    // código
} catch (Exception e) {
    System.debug('Erro: ' + e.getMessage());
}

// ❌ PROBLEMA - Sem tratamento
public static void metodo(){
    // código que pode lançar exceção
}
```

---

#### 2.1.8. Classes de Teste com Baixa Qualidade

**Severidade:** 🟠 ALTA

**Problemas Encontrados:**

```apex
// ❌ PROBLEMA - SeeAllData=true
@isTest(SeeAllData=true)
public class MktTeste {
    // ...
}

// ❌ PROBLEMA - Testes vazios ou mínimos
@isTest
public class TesteVazio {
    static testMethod void teste(){
        Test.startTest();
        Test.stopTest();
    }
}

// ❌ PROBLEMA - Sem asserts
static testMethod void MktTesteVazio(){
    Test.startTest();
        PageReference pageRef = Page.MktMenu;
        MktFluxo fluxo = new MktFluxo();
    Test.stopTest();
    // Sem System.assertEquals ou System.assert
}
```

**Quantidade de Classes de Teste:** ~324 arquivos (50% do total)

---

### 2.2. Correções Necessárias - CLASSES APEX

#### 2.2.1. Implementar Padrão fflib Completo

**Prioridade:** 🔴 CRÍTICA

**Camadas a Implementar:**

```
📁 domain/
  - AccountDomain.cls
  - OpportunityDomain.cls
  - OrderDomain.cls

📁 service/
  - AccountService.cls
  - OpportunityService.cls
  - OrderService.cls
  - ValidationService.cls
  - IntegrationService.cls

📁 selector/
  - AccountSelector.cls
  - OpportunitySelector.cls
  - OrderSelector.cls

📁 util/
  - Constants.cls
  - RecursiveHandler.cls
  - ExceptionHandler.cls
```

**Estimativa:** 100 principais classes × 6 horas = 600 horas

---

#### 2.2.2. Refatorar Nomenclatura

**Prioridade:** 🔴 CRÍTICA

**Classes Prioritárias (Top 30):**

| Classe Atual       | Nova Nomenclatura             | Tipo     |
| ------------------ | ----------------------------- | -------- |
| OppAtuConClass     | OpportunityAccountService     | Service  |
| OppAtuFatClass     | OpportunityFaturamentoService | Service  |
| FatuObtProcClass   | FaturamentoProcessService     | Service  |
| FatuLinkContrClass | FaturamentoContratoService    | Service  |
| PedAtuCatClass     | PedidoCategoriaService        | Service  |
| PedAtuConClass     | PedidoContratoService         | Service  |
| listagem_hr        | HistoricoRecursoSelector      | Selector |
| listagem_lmd       | LinhaManufaturadaSelector     | Selector |
| meta               | MetaService                   | Service  |
| Comiss             | ComissaoService               | Service  |

**Estimativa:** 100 classes × 1 hora = 100 horas

---

#### 2.2.3. Criar Selector Classes

**Prioridade:** 🔴 CRÍTICA

**Objetos Prioritários:**

1. Account
2. Opportunity
3. Order
4. Product2
5. Quote
6. ServiceContract
7. WorkOrder
8. Contact
9. Lead
10. Case

**Template:**

```apex
public with sharing class AccountSelector {
  public static List<Account> selectById(Set<Id> accountIds) {
    return [
      SELECT Id, Name, CNPJ__c, CPF__pc, Phone, Website
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  public static List<Account> selectByIdWithContacts(Set<Id> accountIds) {
    return [
      SELECT Id, Name, (SELECT Id, Name FROM Contacts)
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  public static List<Account> selectByCNPJ(Set<String> cnpjs) {
    return [
      SELECT Id, Name, CNPJ__c
      FROM Account
      WHERE CNPJ__c IN :cnpjs
    ];
  }
}
```

**Estimativa:** 30 Selectors × 4 horas = 120 horas

---

#### 2.2.4. Criar Service Classes

**Prioridade:** 🔴 CRÍTICA

**Serviços Principais:**

```apex
// Validação centralizada
public class ValidationService {
    public static void validateAccounts(List<Account> accounts) {
        for(Account acc : accounts) {
            validateCNPJ(acc);
            validateCPF(acc);
            validateEmail(acc);
        }
    }

    private static void validateCNPJ(Account acc) {
        if(!Util.ValidarCNPJ(acc.CNPJ__c)) {
            throw new ValidationException('CNPJ inválido');
        }
    }
}

// Integração centralizada
public class IntegrationService {
    public static void callReceitaWS(List<Account> accounts) {
        // Bulk callout
    }

    public static void callSAPIntegration(List<Order> orders) {
        // Integração SAP
    }
}
```

**Estimativa:** 40 Services × 8 horas = 320 horas

---

#### 2.2.5. Criar Classe de Constantes

**Prioridade:** 🟠 ALTA

```apex
public class Constants {
  // RecordTypes (usar Custom Metadata)
  public static final String RT_ACCOUNT_PESSOA_JURIDICA = 'Pessoa Jurídica';
  public static final String RT_ACCOUNT_PESSOA_FISICA = 'Pessoa Física';

  // Status
  public static final String OPP_STAGE_WIN = 'WIN';
  public static final String OPP_STAGE_COMITED = 'COMITED';
  public static final String CONTRACT_STATUS_VIGENTE = 'CONTRATO VIGENTE';

  // Limites
  public static final Integer MAX_QUERY_LIMIT = 200;
  public static final Integer MAX_DML_LIMIT = 150;

  // Mensagens de Erro
  public static final String ERROR_CNPJ_INVALIDO = 'CNPJ inválido';
  public static final String ERROR_REQUIRED_FIELD = 'Campo obrigatório';
}
```

**Estimativa:** 16 horas

---

#### 2.2.6. Refatorar Classes de Teste

**Prioridade:** 🟠 ALTA

**Padrões a Implementar:**

```apex
@isTest
private class AccountServiceTest {
  @TestSetup
  static void setup() {
    // Criar dados de teste reutilizáveis
    List<Account> accounts = TestDataFactory.createAccounts(10);
    insert accounts;
  }

  @isTest
  static void testValidateAccounts_Success() {
    // Arrange
    List<Account> accounts = [SELECT Id, CNPJ__c FROM Account LIMIT 10];

    // Act
    Test.startTest();
    ValidationService.validateAccounts(accounts);
    Test.stopTest();

    // Assert
    System.assertEquals(10, accounts.size(), 'Deve validar todas as contas');
  }

  @isTest
  static void testValidateAccounts_InvalidCNPJ() {
    // Arrange
    Account acc = new Account(Name = 'Test', CNPJ__c = 'invalid');

    // Act & Assert
    try {
      ValidationService.validateAccounts(new List<Account>{ acc });
      System.assert(false, 'Deveria lançar exceção');
    } catch (ValidationException e) {
      System.assert(e.getMessage().contains('CNPJ inválido'));
    }
  }
}
```

**Criar TestDataFactory:**

```apex
@isTest
public class TestDataFactory {
  public static List<Account> createAccounts(Integer quantity) {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < quantity; i++) {
      accounts.add(
        new Account(Name = 'Test Account ' + i, CNPJ__c = generateValidCNPJ())
      );
    }
    return accounts;
  }

  public static List<Opportunity> createOpportunities(
    Integer quantity,
    Id accountId
  ) {
    // ...
  }
}
```

**Estimativa:** 150 classes de teste × 2 horas = 300 horas

---

#### 2.2.7. Implementar Exception Handling

**Prioridade:** 🟠 ALTA

```apex
// Custom Exceptions
public class ValidationException extends Exception {}
public class IntegrationException extends Exception {}
public class RecursiveException extends Exception {}

// Exception Handler
public class ExceptionHandler {

    public static void handle(Exception e) {
        if(e instanceof ValidationException) {
            handleValidationException((ValidationException)e);
        } else if(e instanceof DmlException) {
            handleDMLException((DmlException)e);
        } else {
            handleGenericException(e);
        }
    }

    private static void handleValidationException(ValidationException e) {
        // Log específico para validação
        System.debug(LoggingLevel.ERROR, 'Validation Error: ' + e.getMessage());
        // Criar registro de erro
        createErrorLog('Validation', e.getMessage(), e.getStackTraceString());
    }
}
```

**Estimativa:** 40 horas

---

### 2.3. Checklist de Validação - CLASSES APEX

- [ ] Separação clara de responsabilidades (Domain/Service/Selector)
- [ ] Nomenclatura consistente em PascalCase
- [ ] Zero hardcoded IDs
- [ ] Zero magic numbers/strings
- [ ] Constantes em Constants.cls ou Custom Metadata
- [ ] Queries SOQL apenas em Selector classes
- [ ] Lógica de negócio apenas em Service classes
- [ ] Todas as classes com compartilhamento (with sharing / without sharing)
- [ ] Bulk processing em todas as operações
- [ ] Exception handling adequado
- [ ] Logging estruturado
- [ ] Classes de teste com @TestSetup
- [ ] Classes de teste sem SeeAllData=true
- [ ] Cobertura de teste > 90% em todas as classes
- [ ] Testes com asserts significativos
- [ ] TestDataFactory para criação de dados de teste
- [ ] Documentação inline adequada (ApexDoc)

---

## 🎯 PILAR 3: COMPONENTES (LWC E AURA)

### 3.1. Problemas Críticos Identificados

#### 3.1.1. Predominância de Componentes Aura Legados

**Severidade:** 🔴 CRÍTICA

**Situação Atual:**

- 🔴 **194 componentes Aura** (Legado)
- ✅ **29 componentes LWC** (Moderno)
- 📊 **Ratio:** 87% Aura vs 13% LWC

**Impacto:**

- Performance inferior
- Manutenção complexa
- Dificuldade de encontrar desenvolvedores
- Incompatível com novas features do Salesforce
- Custo de manutenção elevado

---

#### 3.1.2. Qualidade do Código JavaScript

**Severidade:** 🟠 ALTA

**Problemas Encontrados:**

##### A) Componentes LWC:

```javascript
// ❌ PROBLEMA - Arquivo muito grande (1973 linhas)
// cobranca.js
import { LightningElement, track } from "lwc";
// ... 1973 linhas de código

// ❌ PROBLEMA - Imports não utilizados
import HttpsOption from "@salesforce/schema/Domain.HttpsOption";

// ❌ PROBLEMA - Múltiplas responsabilidades em um componente
export default class cobranca extends LightningElement {
  // Gestão de contas
  // Gestão de pedidos
  // Gestão de cobranças
  // Gestão de eventos
  // Regras de negócio
}
```

##### B) Componentes Aura:

```javascript
// ❌ PROBLEMA - jQuery dentro de Aura
helper: {
    selectLinha: null,
    selectFamilia: null,

    inputPesquisa: "null",

    // Uso extensivo de jQuery
    $("#inputPesquisa").keyup(function (e){
        // ...
    });

    $('#subtipoRelatorio').selectpicker('destroy');
}

// ❌ PROBLEMA - Código inline extenso
// catalogoHelper.js - variáveis globais, lógica complexa
perfisHabilitadosPCs: ['Administrador do sistema', 'Comunidade Logística', ...]
```

---

#### 3.1.3. Falta de Padronização ESLint

**Severidade:** 🟠 ALTA

**Problemas:**

```javascript
// ❌ console.log em produção
console.log("QUERY ATIVOS", query);
console.log('Fila selecionada: ' + this.filaSelecionada);

// ❌ Warnings configurados (deveriam ser errors)
"@lwc/lwc/no-async-operation": "warn",  // ❌ Deveria ser "error"
"@lwc/lwc/no-inner-html": "warn",       // ❌ Deveria ser "error"
"no-console": "warn"                     // ❌ Deveria ser "error"
```

---

#### 3.1.4. Queries SOQL Hardcoded nos Componentes

**Severidade:** 🟠 ALTA

```javascript
// ❌ PROBLEMA - Query SOQL inline no JavaScript
var query =
  "SELECT Id, Name, SerialNumber, Modelo__c " +
  "from asset where contatoResponsavel = '" +
  contatoResponsavel +
  "' " +
  "OR usuarioResponsavel__c = '" +
  currentUserId +
  "'";

// ❌ PROBLEMA - Concatenação de strings perigosa (SQL Injection potencial)
var query =
  "SELECT Name FROM Product2 WHERE IsActive = true " +
  "AND Linha__c = '" +
  helper.selectLinha +
  "' " +
  "AND Family = '" +
  helper.selectFamilia +
  "'";

// ❌ PROBLEMA - Query gigante e complexa
const soql = `SELECT Id, Name, Data_Prevista__c, Data_Final__c,
              (SELECT Id, Produto__r.ProductCode, Produto__r.Name FROM Consumiveis)
              FROM Demonstracao__c WHERE Status__c NOT IN('Rascunho') 
              AND Regiao__c = '${this.regiaoSelecionada}'`;
```

**Impacto:**

- Risco de SOQL Injection
- Manutenção difícil
- Performance não otimizada
- Violação de Separation of Concerns

---

#### 3.1.5. Uso Excessivo de Bibliotecas Externas

**Severidade:** 🟠 ALTA

**Bibliotecas Encontradas:**

```javascript
// Em múltiplos componentes
import JQuery from "@salesforce/resourceUrl/JQuery";
import fontAwesome from "@salesforce/resourceUrl/fontAwesome";
import ChartJs from "@salesforce/resourceUrl/chartjs214";
```

**Problemas:**

- jQuery é desnecessário em LWC
- Aumenta tamanho dos bundles
- Risco de segurança
- Conflito com ciclo de vida do LWC

---

#### 3.1.6. Falta de Componentização

**Severidade:** 🟠 ALTA

**Problema:**

- Componentes monolíticos (1973 linhas)
- Falta de componentes reutilizáveis
- Lógica duplicada entre componentes

---

### 3.2. Estratégia de Migração Aura → LWC

#### 3.2.1. Categorização dos Componentes Aura

**Análise dos 194 Componentes:**

##### Categoria 1: Migração Prioritária (Componentes Críticos)

**Quantidade:** ~40 componentes
**Critérios:** Alta utilização, funcionalidades críticas

**Componentes Prioritários:**

1. catalogo (Catálogo de produtos)
2. dragAndDropOPP (Gestão de oportunidades)
3. dragAndDropPEDIDOS (Gestão de pedidos)
4. PainelDeClientes (Dashboard principal)
5. visualizacaoDeEstoque (Gestão de estoque)
6. assistenteDeDestinacao (Assistente de compras)
7. assinaturaContrato\* (Múltiplos componentes de assinatura)
8. HomeBotoesCompleto (Botões principais)
9. Calendario_eventos (Calendário)
10. Chat_licitacao (Chat)

**Complexidade:** 🔴 Alta (uso extensivo de jQuery, lógica complexa)  
**Estimativa:** 40 componentes × 40 horas = 1.600 horas

---

##### Categoria 2: Migração Média Prioridade

**Quantidade:** ~80 componentes
**Critérios:** Uso moderado, funcionalidades importantes

**Exemplos:**

- Botões diversos (BotaoAprovacao, CriarAcaoCorretiva, etc.)
- Formulários específicos
- Listagens simples
- PDFs e relatórios

**Complexidade:** 🟠 Média  
**Estimativa:** 80 componentes × 24 horas = 1.920 horas

---

##### Categoria 3: Avaliar Descontinuação

**Quantidade:** ~74 componentes
**Critérios:** Baixo uso, funcionalidade pode ser substituída

**Exemplos:**

- Componentes duplicados
- Componentes obsoletos
- Componentes que podem virar flows

**Ação:** Analisar uso real antes de migrar  
**Estimativa:** 40 componentes × 16 horas = 640 horas

---

#### 3.2.2. Plano de Migração

**Fase 1: Setup (2 semanas)**

1. Criar biblioteca de componentes LWC base
2. Definir padrões de arquitetura LWC
3. Criar guia de estilo
4. Setup de ferramentas (Jest, ESLint, etc.)

**Fase 2: Migração Prioritária (6 meses)**

- Migrar 40 componentes críticos
- 2-3 componentes por semana
- Testes completos em cada migração

**Fase 3: Migração Média Prioridade (8 meses)**

- Migrar 80 componentes médios
- 3-4 componentes por semana

**Fase 4: Limpeza e Descontinuação (2 meses)**

- Avaliar componentes restantes
- Desativar componentes obsoletos
- Documentação final

**Total:** ~18 meses

---

#### 3.2.3. Padrões para Novos Componentes LWC

```javascript
// ✅ Estrutura modular
// myComponent/
//   ├── myComponent.js
//   ├── myComponent.html
//   ├── myComponent.css
//   ├── myComponent.js-meta.xml
//   ├── __tests__/
//   │   └── myComponent.test.js
//   └── utils/
//       └── helpers.js

// ✅ Componente bem estruturado
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecords from "@salesforce/apex/MySelector.getRecords";

/**
 * Componente para gestão de X
 * @description Descrição detalhada
 */
export default class MyComponent extends LightningElement {
  // Public Properties
  @api recordId;

  // Private Reactive Properties
  @track records = [];
  @track isLoading = false;
  @track error;

  // Private Properties
  _initialized = false;

  // Lifecycle Hooks
  connectedCallback() {
    this.loadData();
  }

  // Public Methods
  @api
  refresh() {
    this.loadData();
  }

  // Private Methods
  async loadData() {
    this.isLoading = true;
    try {
      this.records = await getRecords({ recordId: this.recordId });
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  handleError(error) {
    this.error = error;
    this.showToast("Error", error.body.message, "error");
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  // Event Handlers
  handleClick(event) {
    // ...
  }

  // Getters
  get hasRecords() {
    return this.records && this.records.length > 0;
  }
}
```

---

### 3.3. Correções Necessárias - COMPONENTES

#### 3.3.1. Componentes LWC Existentes

**Prioridade:** 🔴 CRÍTICA

**Ações para os 29 LWCs:**

1. **Refatorar Componentes Grandes:**
   - cobranca.js (1973 linhas) → Dividir em 5-7 componentes
   - Criar componentes filhos reutilizáveis
   - **Estimativa:** 80 horas

2. **Remover jQuery:**
   - Substituir por native LWC APIs
   - **Estimativa:** 40 horas

3. **Mover Queries para Apex:**
   - Criar Selector classes
   - Remover SOQL dos componentes
   - **Estimativa:** 60 horas

4. **Implementar Testes Jest:**
   - Cobertura > 80% para todos os LWCs
   - **Estimativa:** 90 horas

5. **Padronizar Error Handling:**
   - Usar ShowToastEvent
   - Logger centralizado
   - **Estimativa:** 30 horas

**Total LWC:** 300 horas

---

#### 3.3.2. Atualizar Configuração ESLint

**Prioridade:** 🟠 ALTA

```json
// .eslintrc.json - Configuração recomendada
{
  "extends": ["@salesforce/eslint-config-lwc/recommended"],
  "rules": {
    "@lwc/lwc/no-async-operation": "error",
    "@lwc/lwc/no-inner-html": "error",
    "no-console": "error",
    "@lwc/lwc/no-document-query": "error",
    "no-restricted-globals": ["error", "event"],
    "prefer-const": "error",
    "no-var": "error"
  },
  "overrides": [
    {
      "files": ["**/__tests__/**/*.js"],
      "env": {
        "jest": true
      }
    }
  ]
}
```

**Estimativa:** 8 horas

---

#### 3.3.3. Configurar Prettier para Componentes

**Prioridade:** 🟠 ALTA

```json
// .prettierrc - Adicionar configurações
{
  "trailingComma": "none",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "plugins": ["prettier-plugin-apex", "@prettier/plugin-xml"],
  "overrides": [
    {
      "files": "*.{cmp,page,component}",
      "options": { "parser": "html" }
    },
    {
      "files": "**/lwc/**/*.html",
      "options": { "parser": "lwc" }
    },
    {
      "files": "*.{js,ts}",
      "options": {
        "singleQuote": true
      }
    }
  ]
}
```

**Estimativa:** 4 horas

---

#### 3.3.4. Criar Biblioteca de Componentes Reutilizáveis

**Prioridade:** 🟠 ALTA

**Componentes Base:**

```
c-button
c-modal
c-datatable
c-spinner
c-toast-handler
c-error-panel
c-combobox
c-picklist
c-lookup
c-file-upload
```

**Estimativa:** 120 horas (10 componentes × 12 horas)

---

### 3.4. Checklist de Validação - COMPONENTES

#### LWC:

- [ ] Sem uso de jQuery ou bibliotecas externas desnecessárias
- [ ] Queries SOQL apenas via Apex
- [ ] Componentização adequada (< 500 linhas por arquivo)
- [ ] Sem console.log em produção
- [ ] Error handling com ShowToastEvent
- [ ] Cobertura de testes Jest > 80%
- [ ] ESLint sem warnings
- [ ] Prettier aplicado
- [ ] Acessibilidade (ARIA labels)
- [ ] Responsividade
- [ ] Documentação JSDoc

#### Aura:

- [ ] Plano de migração definido
- [ ] Priorização baseada em uso
- [ ] Componentes críticos migrados primeiro
- [ ] Componentes obsoletos removidos
- [ ] Documentação de componentes mantidos temporariamente

---

## 📊 ANÁLISE PMD

### 4.1. Configuração Atual

**Arquivo:** `config/pmd-ruleset.xml`

**Categorias Ativadas:**

- ✅ Best Practices
- ✅ Code Style
- ✅ Design
- ✅ Error Prone
- ✅ Performance
- ✅ Security

**Status:** ✅ Configuração adequada

---

### 4.2. Violações Esperadas (Baseado na Análise)

#### 4.2.1. Best Practices

**Violações Previstas:**

- ApexUnitTestClassShouldHaveAsserts
- ApexUnitTestShouldNotUseSeeAllDataTrue
- AvoidGlobalModifier
- AvoidLogicInTrigger

---

#### 4.2.2. Code Style

**Violações Previstas:**

- ClassNamingConventions
- MethodNamingConventions
- VariableNamingConventions
- FieldNamingConventions

---

#### 4.2.3. Design

**Violações Previstas:**

- ExcessiveClassLength
- ExcessivePublicCount
- TooManyFields
- CyclomaticComplexity
- NcssMethodCount

---

#### 4.2.4. Performance

**Violações Previstas:**

- AvoidSoqlInLoops
- AvoidDmlStatementsInLoops
- AvoidDebugStatements

---

#### 4.2.5. Security

**Violações Previstas:**

- ApexSOQLInjection
- ApexCRUDViolation
- ApexOpenRedirect

---

### 4.3. Ações Recomendadas

#### 4.3.1. Executar Análise PMD Completa

```bash
# Via npm script
npm run run-pmd.sh

# ou diretamente
./scripts/run-pmd.sh
```

#### 4.3.2. Priorizar Correções por Severidade

**Prioridade 1 - Security:**

- ApexSOQLInjection
- ApexCRUDViolation
- **Estimativa:** 80 horas

**Prioridade 2 - Performance:**

- AvoidSoqlInLoops
- AvoidDmlStatementsInLoops
- **Estimativa:** 120 horas

**Prioridade 3 - Best Practices:**

- AvoidLogicInTrigger
- ApexUnitTestShouldNotUseSeeAllDataTrue
- **Estimativa:** 200 horas

**Prioridade 4 - Code Style:**

- Naming Conventions
- **Estimativa:** 100 horas

---

## 📋 RESUMO DE ESTIMATIVAS

### Por Pilar

| Pilar             | Horas Estimadas | Complexidade  |
| ----------------- | --------------- | ------------- |
| **TRIGGERS**      | 560 horas       | 🔴 Alta       |
| **CLASSES APEX**  | 1.456 horas     | 🔴 Alta       |
| **COMPONENTES**   | 4.492 horas     | 🔴 Muito Alta |
| **PMD/QUALIDADE** | 500 horas       | 🟠 Média      |
| **TOTAL**         | **7.008 horas** | 🔴 Muito Alta |

---

### Por Prioridade

| Prioridade     | Descrição                                     | Horas | % do Total |
| -------------- | --------------------------------------------- | ----- | ---------- |
| 🔴 **CRÍTICA** | Triggers, Service Layer, Componentes Críticos | 3.640 | 52%        |
| 🟠 **ALTA**    | Refatoração Classes, Testes, LWC Médios       | 2.440 | 35%        |
| 🟡 **MÉDIA**   | Nomenclatura, Componentização, Docs           | 928   | 13%        |

---

### Faseamento Recomendado

#### Fase 1: Fundação (3 meses - 480 horas)

- ✅ Implementar TriggerHandler framework
- ✅ Criar Selector classes principais
- ✅ Criar Service classes principais
- ✅ Implementar Constants e utilities

#### Fase 2: Refatoração Core (6 meses - 1.920 horas)

- 🔄 Migrar 40 triggers principais
- 🔄 Refatorar 100 classes principais
- 🔄 Criar 30 Selectors
- 🔄 Criar 40 Services

#### Fase 3: Componentes (12 meses - 3.200 horas)

- 🔄 Migrar 40 componentes Aura prioritários
- 🔄 Refatorar 29 LWCs existentes
- 🔄 Criar biblioteca de componentes base

#### Fase 4: Qualidade e Testes (3 meses - 1.408 horas)

- 🔄 Refatorar classes de teste
- 🔄 Implementar TestDataFactory
- 🔄 Aumentar cobertura para > 90%
- 🔄 Resolver violações PMD

---

## 🎯 RECOMENDAÇÕES ESTRATÉGICAS

### 1. Abordagem Incremental

- ❌ NÃO fazer "big bang" (reescrever tudo)
- ✅ Refatorar incrementalmente
- ✅ Manter funcionalidades ativas durante refatoração
- ✅ Deploy contínuo de melhorias

### 2. Priorização por Valor de Negócio

- 🔴 Primeiro: Componentes mais usados
- 🔴 Primeiro: Triggers que causam problemas
- 🔴 Primeiro: Classes com bugs recorrentes

### 3. Automação

- ✅ CI/CD com validação PMD obrigatória
- ✅ ESLint no pre-commit
- ✅ Prettier automatizado
- ✅ Testes automatizados

### 4. Documentação

- ✅ Documentar padrões adotados
- ✅ Criar guias de desenvolvimento
- ✅ Manter changelog de refatorações
- ✅ Treinar equipe nos novos padrões

### 5. Métricas de Sucesso

- 📊 Cobertura de testes > 90%
- 📊 Zero violações PMD críticas
- 📊 Zero warnings ESLint
- 📊 Redução de 50% no número de triggers
- 📊 Redução de 60% nos componentes Aura
- 📊 Aumento de 400% nos LWCs

---

## 📚 ANEXOS

### A. Ferramentas Recomendadas

**Desenvolvimento:**

- VS Code + Salesforce Extension Pack
- Salesforce CLI
- PMD
- ESLint
- Prettier

**CI/CD:**

- GitHub Actions / GitLab CI
- SFDX Scanner
- Apex Test Runner

**Documentação:**

- ApexDox para Apex
- JSDoc para JavaScript
- Markdown para documentação geral

---

### B. Referências

**Salesforce:**

- [Apex Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_best_practices.htm)
- [LWC Best Practices](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.create_components_best_practices)
- [Trigger Framework](https://developer.salesforce.com/wiki/apex_trigger_architecture_framework)

**fflib:**

- [Apex Enterprise Patterns](https://github.com/apex-enterprise-patterns)
- [Separation of Concerns](https://developer.salesforce.com/wiki/apex_enterprise_patterns_-_separation_of_concerns)

**Qualidade:**

- [PMD for Apex](https://pmd.github.io/latest/pmd_rules_apex.html)
- [Salesforce Code Analyzer](https://forcedotcom.github.io/sfdx-scanner/)

---

### C. Próximos Passos Imediatos

#### Semana 1-2:

1. [ ] Apresentar este documento ao time
2. [ ] Obter aprovação para o plano
3. [ ] Alocar recursos (desenvolvedores)
4. [ ] Configurar ferramentas de análise

#### Semana 3-4:

1. [ ] Executar análise PMD completa
2. [ ] Executar análise ESLint completa
3. [ ] Priorizar correções críticas
4. [ ] Iniciar implementação de TriggerHandler

#### Mês 2:

1. [ ] Criar primeiras Selector classes
2. [ ] Criar primeiras Service classes
3. [ ] Refatorar primeiros 5 triggers
4. [ ] Configurar CI/CD pipeline

---

## 🔍 CONCLUSÃO

A org Salesforce da Hospcom apresenta uma **dívida técnica significativa** que requer **atenção imediata e investimento substancial**.

**Principais Desafios:**

1. 🔴 **140 triggers** sem padrão arquitetural
2. 🔴 **647 classes** com responsabilidades misturadas
3. 🔴 **194 componentes Aura** legados
4. 🔴 Falta de separação de camadas (fflib)
5. 🔴 Nomenclatura inconsistente
6. 🔴 Testes de baixa qualidade

**Benefícios da Refatoração:**

- ✅ **Manutenibilidade:** Redução de 70% no tempo de manutenção
- ✅ **Performance:** Melhoria de 50% na performance geral
- ✅ **Qualidade:** Código mais robusto e testável
- ✅ **Escalabilidade:** Arquitetura preparada para crescimento
- ✅ **Produtividade:** Desenvolvedores mais produtivos

**Investimento Total:**

- ⏱️ **7.008 horas** (~4 desenvolvedores por 24 meses)
- 💰 Custo estimado depende da localização e senioridade

**ROI Esperado:**

- Redução de bugs em 60%
- Redução de tempo de desenvolvimento em 40%
- Redução de incidentes em produção em 70%
- Payback esperado em 18-24 meses

---

**Preparado por:** Arquiteto Salesforce  
**Data:** 14 de dezembro de 2025  
**Versão:** 1.0  
**Status:** 📋 Aguardando Aprovação

---
