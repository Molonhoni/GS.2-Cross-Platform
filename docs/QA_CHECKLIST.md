# Território Vivo — Relatório de Validação

**Global Solution 2026.2 — FIAP**  
**Disciplina:** Cross-Platform Application Development  
**Data da revisão:** 11/11/2026  
**Projeto:** Território Vivo — Painel de Inteligência Territorial

## 1. Objetivo

Registrar as validações de funcionamento, estabilidade, integridade dos dados, responsividade, acessibilidade e privacidade realizadas durante o desenvolvimento do Território Vivo, distinguindo testes automatizados da validação de execução mobile informada pela equipe.

## 2. Ambiente de desenvolvimento

- **Framework:** Flutter
- **Linguagem:** Dart
- **Editor:** Visual Studio Code
- **Ambiente de desenvolvimento e demonstração:** Chrome no Windows
- **Execução mobile:** confirmada pelo integrante Vitor Limeira dos Santos
- **Testes automatizados:** `flutter_test`
- **Comunicação HTTP simulada nos testes:** `MockClient`
- **Persistência simulada nos testes:** repositório em memória
- **Persistência no aplicativo:** `shared_preferences`

## 3. Resultado dos testes automatizados

Comandos utilizados:

```bash
flutter analyze
flutter test --reporter expanded
```

| Verificação | Resultado informado |
|---|---|
| Análise estática | Aprovada — `No issues found!` |
| Testes automatizados | **23 testes aprovados** |
| Falhas remanescentes na última execução informada | Nenhuma |

Os resultados correspondem à validação realizada após as correções do **Commit 11**.

## 4. Cenários automatizados cobertos

- [x] Conversão de respostas meteorológicas
- [x] Leitura de previsões horárias
- [x] Gerenciamento de estado
- [x] Tratamento de indisponibilidade da API
- [x] Tratamento de JSON meteorológico inválido
- [x] Regras demonstrativas de precipitação
- [x] Regras demonstrativas de temperatura elevada
- [x] Priorização dos alertas
- [x] Serialização de observações em JSON
- [x] Cadastro e recuperação de registros
- [x] Persistência simulada entre inicializações
- [x] Tratamento de falhas de armazenamento
- [x] Exclusão de registros
- [x] Confirmação antes da exclusão de todos os registros
- [x] Validação dos formulários
- [x] Navegação entre módulos
- [x] Preservação do estado meteorológico
- [x] Resumo semântico de gráfico
- [x] Navegação com largura de **390 px** simulada
- [x] Navegação com largura de **960 px** simulada

## 5. Problemas encontrados e correções

### 5.1 Componentes fora da área visível nos testes

**Problema:** os testes tentavam localizar componentes ainda não construídos em listas roláveis.  
**Correção:** utilização de rolagem automatizada antes das verificações.

### 5.2 Dependência de persistência não encontrada

**Problema:** ausência do pacote `shared_preferences` na configuração inicial.  
**Correção:** adição da dependência ao projeto.

### 5.3 Suporte a links simbólicos no Windows

**Problema:** o ambiente solicitava suporte a *symlinks* para plugins.  
**Correção:** habilitação do Modo de Desenvolvedor do Windows.

### 5.4 Recurso de semântica não liberado

**Problema:** um `SemanticsHandle` permanecia ativo ao encerrar um teste.  
**Correção:** liberação explícita do recurso no teste de acessibilidade.

### 5.5 Overflow dos cartões meteorológicos

**Problema:** cartões apresentavam *overflow* vertical na largura simulada de 390 px.  
**Correção:** adequação da altura e dos espaçamentos dos indicadores.

### 5.6 Contraste dos valores nos gráficos

**Problema:** os valores dos *tooltips* tinham baixo contraste.  
**Correção:** adoção de texto branco e negrito sobre fundo escuro.

## 6. Verificações funcionais

- [x] Aplicativo iniciado no Chrome
- [x] Dashboard com informações obtidas da Open-Meteo
- [x] Gráficos de temperatura e precipitação
- [x] Navegação entre os quatro módulos
- [x] Alertas com justificativas, confiança indicativa e limitações
- [x] Formulários com validação
- [x] Cadastro e histórico de observações
- [x] Persistência local implementada
- [x] Exclusão individual e exclusão geral com confirmação
- [x] Página de privacidade disponível

## 7. Responsividade e acessibilidade

**Verificações implementadas e testadas:**

- [x] Testes automatizados em larguras de 390 px e 960 px
- [x] Correção do *overflow* identificado nos cartões de indicadores
- [x] Resumos textuais associados aos gráficos
- [x] Verificação automatizada de semântica
- [x] Melhorias de contraste nos *tooltips* dos gráficos
- [x] Ampliação das áreas mínimas de interação dos botões no tema

**Alcance da validação:** os testes cobrem os cenários automatizados e as correções registradas. Não houve documentação de auditoria integral com leitor de tela, navegação exclusivamente por teclado, zoom de 200% ou aferição formal de contraste de todos os elementos. Essas avaliações são complementares e não devem ser confundidas com os testes aprovados acima.

## 8. Privacidade

- [x] Uso de coordenadas meteorológicas fixas
- [x] Ausência de solicitação de localização GPS
- [x] Armazenamento local das observações
- [x] Informações sobre a fonte dos dados e o armazenamento
- [x] Orientações para evitar o cadastro de dados pessoais
- [x] Confirmação antes da exclusão geral
- [x] Testes de exclusão e de tratamento de falhas

## 9. Validação mobile

A **execução do aplicativo em ambiente mobile foi validada pelo integrante Vitor Limeira dos Santos**, conforme confirmação da equipe. Essa validação complementa a execução no Chrome e os testes automatizados realizados durante o desenvolvimento.

**Evidências de validação disponíveis:**

- [x] Execução em ambiente mobile confirmada por Vitor Limeira dos Santos
- [x] Navegação entre módulos coberta por testes automatizados
- [x] Formulário e regras de validação cobertos por testes automatizados
- [x] Persistência e recuperação dos registros cobertas por testes automatizados
- [x] Interface testada automaticamente em largura de referência mobile (390 px)

## 10. Limitações da validação

Os testes automatizados usam respostas simuladas e verificam cenários definidos durante o desenvolvimento. Eles não comprovam a precisão das previsões da Open-Meteo, a calibração estatística dos alertas ou acessibilidade integral para todas as pessoas e tecnologias assistivas.

## 11. Conclusão

A revisão do Commit 11 foi concluída com **23 testes automatizados aprovados** e análise estática sem problemas, conforme resultados informados durante o desenvolvimento.

O Território Vivo implementa os módulos de Dashboard, Tendências, Alertas e Registros, com integração meteorológica, regras preventivas demonstrativas, persistência local e recursos de privacidade e acessibilidade.

A **execução em ambiente mobile foi validada pelo integrante Vitor Limeira dos Santos**. A cobertura dos demais cenários está descrita de acordo com os testes automatizados efetivamente realizados, sem atribuir resultados manuais não documentados.

## 12. Evidências para apresentação

- Dashboard com indicadores da Open-Meteo
- Gráficos de temperatura e precipitação
- Alertas preventivos e suas justificativas
- Formulário e histórico de observações
- Página de privacidade e exclusão de registros
- Terminal com os 23 testes automatizados aprovados
- Histórico dos 12 commits no GitHub
- Demonstração da execução mobile validada por Vitor, caso disponível
