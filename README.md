
# Território Vivo

### Painel de Inteligência Territorial

**Global Solution 2026.2 — FIAP**  
**Curso:** Ciência da Computação  
**Disciplina:** Cross-Platform Application Development  
**Tecnologia principal:** Flutter e Dart

---

## Sobre o projeto

O Território Vivo é um aplicativo desenvolvido para apoiar o acompanhamento de condições ambientais e territoriais, com foco na prevenção de problemas que podem afetar a qualidade de vida da população.

A proposta é reunir informações meteorológicas, apresentar tendências, identificar condições que merecem atenção e permitir o registro de observações sobre o território.

Nesta versão, o projeto utiliza São Paulo como área de referência, consumindo previsões meteorológicas da Open-Meteo.

O aplicativo não substitui sistemas oficiais de monitoramento, órgãos de defesa civil ou decisões tomadas por profissionais responsáveis.

## Objetivo

Desenvolver uma aplicação multiplataforma que transforme dados meteorológicos em informações organizadas e compreensíveis, auxiliando gestores na identificação de situações que podem exigir acompanhamento.

O sistema prioriza:

- Visualização clara de informações;
- Análise preventiva;
- Transparência dos critérios utilizados;
- Apoio à decisão humana;
- Acessibilidade e privacidade.

## Funcionalidades

### 1. Painel principal

O Dashboard apresenta informações meteorológicas referentes à cidade de São Paulo:

- Temperatura atual;
- Umidade relativa do ar;
- Precipitação;
- Probabilidade máxima prevista de chuva no dia;
- Gráfico de previsão de temperatura;
- Atualização dos dados por meio da API.

Os indicadores são apresentados em cartões com identificação e descrição.

### 2. Tendências meteorológicas

O módulo Tendências apresenta gráficos das próximas 24 horas de previsão:

- Evolução da temperatura;
- Precipitação prevista por hora;
- Temperaturas mínima e máxima previstas;
- Precipitação acumulada prevista;
- Resumos textuais dos gráficos.

Os gráficos possuem interação por toque ou mouse, permitindo consultar valores específicos.

### 3. Alertas preventivos

O aplicativo analisa as previsões meteorológicas e identifica condições de chuva e temperatura que podem exigir atenção.

Cada alerta apresenta:

- Nível de atenção;
- Indicadores que motivaram a classificação;
- Justificativa da análise;
- Confiança indicativa;
- Limitações;
- Recomendações para avaliação humana.

As regras são demonstrativas e não representam um modelo preditivo de riscos calibrado.

### 4. Registros de campo

O usuário pode cadastrar observações territoriais contendo:

- Título;
- Categoria;
- Bairro ou região;
- Descrição;
- Data e horário de criação.

O formulário verifica o preenchimento e o tamanho mínimo dos campos.

Também é possível consultar o histórico e excluir registros mediante confirmação.

### 5. Persistência local

As observações são armazenadas localmente utilizando o pacote `shared_preferences`.

Os registros permanecem disponíveis após reiniciar o aplicativo, enquanto os dados locais forem preservados.

Não há sincronização entre dispositivos ou armazenamento em servidor.

### 6. Privacidade e acessibilidade

O aplicativo inclui uma página dedicada à transparência sobre os dados utilizados e armazenados.

Foram implementados:

- Orientações para evitar dados pessoais;
- Exclusão de todos os registros locais;
- Confirmação antes da exclusão;
- Resumos textuais dos gráficos;
- Identificação de botões e controles;
- Melhorias de contraste e legibilidade;
- Adaptação da interface a diferentes larguras.

## Tecnologias utilizadas

| Tecnologia | Utilização |
|---|---|
| Flutter | Desenvolvimento da aplicação |
| Dart | Linguagem de programação |
| Material 3 | Componentes e identidade visual |
| http | Comunicação com a API |
| fl_chart | Gráficos de temperatura e chuva |
| ChangeNotifier | Gerenciamento de estado |
| ListenableBuilder | Atualização reativa da interface |
| shared_preferences | Armazenamento local |
| flutter_test | Testes automatizados |
| Git e GitHub | Versionamento do projeto |

## Fonte de dados

### Open-Meteo

**Documentação:** https://open-meteo.com/en/docs

O aplicativo utiliza o endpoint público de previsão meteorológica da Open-Meteo.

Parâmetros geográficos:

- Localidade de referência: São Paulo, SP;
- Latitude: -23.5505;
- Longitude: -46.6333;
- Fuso horário: America/Sao_Paulo.

Indicadores consultados:

**Dados atuais:**
- temperature_2m
- relative_humidity_2m
- precipitation

**Previsão horária:**
- temperature_2m
- precipitation

**Previsão diária:**
- precipitation_probability_max

A API é consultada por meio do serviço `WeatherService`, responsável pela requisição HTTP e pelo tratamento de respostas inválidas e falhas de conexão.

Os dados são originados de produtos e modelos meteorológicos disponibilizados pela Open-Meteo, sujeitos a atualizações e incertezas.

## Metodologia dos alertas

Os alertas são gerados por regras condicionais implementadas no serviço `TerritorialAlertEngine`.

O horizonte analisado corresponde a até 24 horas de previsão.

### Critérios demonstrativos

| Indicador | Atenção | Elevado |
|---|---|---|
| Chuva acumulada em 24h | >= 12 mm | >= 30 mm |
| Pico de precipitação horária | >= 4 mm | >= 10 mm |
| Temperatura máxima | >= 31 °C | >= 34 °C |

Basta um dos critérios associados ao indicador atingir o limiar para que o respectivo alerta seja gerado.

### Confiança indicativa

A confiança é classificada como baixa ou moderada conforme as evidências disponíveis.

Para chuva, considera-se a combinação entre acumulado previsto e pico horário.

Para temperatura, considera-se também a quantidade de horas acima do limiar definido.

Essa classificação é heurística: não corresponde a uma probabilidade estatística validada ou a uma avaliação oficial de risco.

### Apoio à tomada de decisão

O aplicativo apresenta recomendações de acompanhamento, como consulta a comunicados oficiais e avaliação das condições locais.

Nenhuma decisão operacional de alto impacto é executada automaticamente.

## Arquitetura do projeto

O projeto foi organizado em camadas para separar interface, regras de negócio, gerenciamento de estado e acesso a dados.

```text
lib/
├── controllers/
│   ├── record_controller.dart
│   └── weather_controller.dart
├── core/
│   └── theme/
│       └── app_theme.dart
├── models/
│   ├── territorial_alert.dart
│   ├── territorial_record.dart
│   └── weather_data.dart
├── screens/
│   ├── alerts_screen.dart
│   ├── home_screen.dart
│   ├── main_navigation_screen.dart
│   ├── privacy_screen.dart
│   ├── records_screen.dart
│   └── trends_screen.dart
├── services/
│   ├── record_repository.dart
│   ├── territorial_alert_engine.dart
│   └── weather_service.dart
├── widgets/
│   ├── accessible_forecast_chart.dart
│   ├── forecast_charts.dart
│   ├── module_card.dart
│   └── weather_overview_card.dart
└── main.dart
```

### Fluxo dos dados

1. O `WeatherService` consulta a Open-Meteo.
2. O `WeatherData` estrutura os dados recebidos.
3. O `WeatherController` disponibiliza as informações às telas.
4. O Dashboard e Tendências apresentam indicadores e gráficos.
5. O `TerritorialAlertEngine` avalia os limiares demonstrativos.
6. O módulo Registros utiliza o `RecordController` e o `RecordRepository` para armazenar observações.

A aplicação utiliza um controlador meteorológico compartilhado para evitar requisições desnecessárias ao trocar de módulo.

## Como executar

### Pré-requisitos

- Flutter SDK instalado;
- Dart SDK compatível com o projeto;
- VS Code ou Android Studio;
- Chrome, emulador ou dispositivo compatível;
- Conexão com a internet para os dados meteorológicos.

### Clonar o repositório

```bash
git clone https://github.com/Molonhoni/GS.2-Cross-Platform.git
cd GS.2-Cross-Platform
```

### Instalar as dependências

```bash
flutter pub get
```

### Consultar os dispositivos disponíveis

```bash
flutter devices
```

### Executar no Chrome

```bash
flutter run -d chrome
```

### Executar no Android

Com emulador ou dispositivo Android configurado:

```bash
flutter run
```

Selecione o dispositivo desejado caso o Flutter apresente mais de uma opção.

## Testes e qualidade

O projeto conta com testes automatizados para as principais funcionalidades.

Entre os cenários avaliados estão:

- Conversão dos dados meteorológicos;
- Tratamento de falhas da API;
- Gerenciamento de estado;
- Leitura e gravação dos registros;
- Serialização e recuperação dos dados;
- Falhas de armazenamento;
- Formulários e navegação;
- Regras dos alertas preventivos;
- Exclusão de observações;
- Confirmação da exclusão de dados;
- Acessibilidade dos gráficos;
- Responsividade em diferentes larguras.

### Análise estática

```bash
flutter analyze
```

### Testes automatizados

```bash
flutter test --reporter expanded
```

Na validação do Commit 11, foram aprovados 23 testes automatizados, sem problemas apontados pelo `flutter analyze`.

O plano de verificação está documentado em:

`docs/QA_CHECKLIST.md`

## Privacidade dos dados

O aplicativo não solicita acesso à localização GPS e utiliza coordenadas fixas para a consulta meteorológica.

As observações são mantidas localmente e não são enviadas a um servidor pelo aplicativo.

Recomenda-se não inserir dados pessoais, documentos, telefones, nomes de cidadãos ou endereços completos.

O usuário pode excluir suas observações individualmente ou apagar todos os registros por meio da página de privacidade.

## Limitações

O Território Vivo é um projeto acadêmico e possui limitações importantes:

- As previsões dependem da disponibilidade da Open-Meteo;
- Os indicadores representam a área de referência de São Paulo, não cada bairro individualmente;
- Os dados meteorológicos podem mudar conforme a atualização dos modelos;
- Não há integração com sensores locais ou bases oficiais de ocorrências urbanas;
- Os alertas utilizam limiares demonstrativos, sem calibração estatística;
- A confiança dos alertas é indicativa, não probabilística;
- Não existe previsão validada de enchentes ou de ondas de calor;
- Não são realizadas decisões automáticas de alto impacto;
- O armazenamento local não oferece backup em nuvem;
- A limpeza dos dados do navegador ou a desinstalação do aplicativo pode remover os registros;
- O armazenamento não foi projetado para dados sensíveis ou críticos;
- Os testes automatizados não substituem testes de acessibilidade com usuários e dispositivos reais.

## Evolução do desenvolvimento

O projeto foi implementado em etapas, com commits separados para demonstrar a evolução das funcionalidades.

| Commit | Etapa |
|---|---|
| 01 | Estrutura inicial do Flutter |
| 02 | Identidade visual |
| 03 | Navegação entre telas |
| 04 | Integração com API meteorológica |
| 05 | Gerenciamento de estado |
| 06 | Dashboard e gráficos |
| 07 | Alertas preditivos |
| 08 | Formulários com validação |
| 09 | Persistência local |
| 10 | Acessibilidade e privacidade |
| 11 | Testes e responsividade |
| 12 | Documentação final |

O histórico completo está disponível na aba de commits do GitHub.

## Integrantes

**Felipe Paula Burba Molonhoni**  
RM: 564395

**Vitor Limeira dos Santos**
RM: 565280



**Território Vivo — Tecnologia para compreender o território e apoiar decisões mais responsáveis.**
