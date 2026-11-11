
# Território Vivo — Plano de Validação

Global Solution 2026.2 — FIAP  
Disciplina: Cross-Platform Application Development

## 1. Objetivo

Verificar a estabilidade, usabilidade, acessibilidade
e integridade dos dados do aplicativo Território Vivo.

## 2. Testes automatizados

Executar:

- flutter analyze
- flutter test --reporter expanded

Critério de aprovação:

- Nenhum erro de análise estática.
- Todos os testes automatizados aprovados.
- Nenhum erro de renderização nos testes de interface.

## 3. Testes funcionais

- [ ] Dashboard apresenta dados da Open-Meteo.
- [ ] Atualização meteorológica funciona.
- [ ] Gráficos de temperatura e precipitação funcionam.
- [ ] Valores dos gráficos são legíveis ao passar o mouse.
- [ ] Navegação funciona entre os quatro módulos.
- [ ] Alertas apresentam justificativas e limitações.
- [ ] Formulário rejeita dados incompletos.
- [ ] Formulário permite cadastrar observações válidas.
- [ ] Observações persistem após reiniciar o aplicativo.
- [ ] Exclusão individual funciona.
- [ ] Exclusão de todos os registros exige confirmação.

## 4. Responsividade

- [ ] Interface verificada em largura de 390 pixels.
- [ ] Interface verificada em largura de 960 pixels.
- [ ] Nenhum conteúdo importante fica cortado.
- [ ] Gráficos permanecem legíveis.
- [ ] Navegação inferior permanece acessível.
- [ ] Formulário pode ser preenchido sem problemas.

## 5. Acessibilidade

- [ ] Botões possuem identificação compreensível.
- [ ] Indicadores não dependem apenas de cores.
- [ ] Gráficos possuem resumos textuais.
- [ ] Textos permanecem legíveis com zoom ampliado.
- [ ] Navegação por teclado foi verificada.
- [ ] Contraste visual foi revisado.
- [ ] Leitor de tela foi testado, quando disponível.

## 6. Privacidade

- [ ] Não é solicitada a localização GPS do usuário.
- [ ] O aplicativo informa as fontes meteorológicas.
- [ ] Os registros são armazenados localmente.
- [ ] O aplicativo orienta a não informar dados pessoais.
- [ ] A exclusão dos registros é controlada pelo usuário.
- [ ] As limitações da persistência são apresentadas.

## 7. Validação mobile

- [ ] Aplicativo executado em Android, quando disponível.
- [ ] Navegação e formulário verificados no dispositivo.
- [ ] Persistência verificada após fechar e reabrir o app.

## 8. Limitações conhecidas

- Os dados climáticos dependem da API Open-Meteo.
- Os alertas utilizam regras demonstrativas.
- Não existe modelo de risco territorial calibrado.
- As decisões finais dependem de avaliação humana.
- Os registros não possuem sincronização em nuvem.
- O armazenamento local não é adequado a dados sensíveis.
- Os testes automatizados não substituem testes reais
  de acessibilidade e de dispositivos.

## 9. Resultado

Preencher após a execução dos testes:

- Flutter Analyze: pendente
- Flutter Test: pendente
- Testes manuais: pendente
- Validação mobile: pendente
- Problemas encontrados: pendente
- Correções realizadas: pendente

## 10. Evidências sugeridas

- Dashboard com indicadores meteorológicos
- Gráficos de temperatura e precipitação
- Tela de alertas preventivos
- Formulário e histórico de registros
- Página de privacidade
- Terminal mostrando testes aprovados
- Histórico de commits no GitHub
