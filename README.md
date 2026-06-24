# Canaã Junina 2026 — Coleta & Análise (App Canaan)

PWA de **coleta de pesquisa de campo** (offline-first) e **análise de resultados** do
*Festival Canaã Cidade Junina 2026*. Pesquisa conduzida pela **Foccus Pesquisas** para a
Prefeitura de Canaã dos Carajás — PA. Plataforma **Just Go · Smart Access**.

## Estrutura

| Arquivo | Função |
|---|---|
| `index.html` | App de coleta (PWA). Fluxo wizard, 1 pergunta/tela, salvamento progressivo, offline (IndexedDB) e sincronização com Supabase. |
| `dashboard.html` | Dashboard **geral** (visão consolidada). Modos *demonstração* e *dados reais*. |
| `relatorios.html` | **Relatório final por público** — um dashboard completo para cada tipo de instrumento, com todas as questões. **Somente leitura.** |
| `sw.js` | Service worker (cache offline; API do Supabase sempre via rede). |
| `manifest.json` | Manifesto PWA (instalável no celular). |

## Públicos / instrumentos de coleta

| Tipo (`entrevistas.tipo`) | Público | Questões |
|---|---|---|
| `VISITANTE` | Visitantes / Turistas (Questionário A) | 26 |
| `MORADOR` | Moradores (Questionário B) | 19 |
| `EXPOSITOR` | Expositores / Operação (Questionário C) | 13 |
| `COMERCIANTE` | Comerciantes Locais (Questionário D) | 19 |

## Modelo de dados (Supabase)

- **`entrevistas`** — `id`, `tipo`, `session_id`, `status` (`rascunho`/`completo`),
  `pesquisador`, `sexo`, `faixa_etaria`, `escolaridade`, `coletado_em`,
  `geo_lat`/`geo_lng`/`geo_accuracy`/`geo_status`, `device_info`.
- **`respostas`** — `entrevista_id` (FK), `questao` (`q1`, `q2`, `a18_0`…), `valor`, `valor_num`.
  - Múltipla escolha: `valor` acumulado como `"opção A; opção B"`.
  - Escalas Likert: `valor_num` 5→1 (`9` = Não Sabe/Não Respondeu).
  - Tabelas de avaliação (`aval`): uma resposta por item, `questao = a<n>_<i>`.

## relatorios.html — relatório por público

- **100% somente leitura.** Lê as tabelas brutas via *embed* do PostgREST
  (`entrevistas?select=*,respostas(*)&tipo=eq.X&status=eq.completo`) e **agrega no navegador**.
  Não cria views nem grava nada no banco.
- *Metadata-driven*: cada instrumento é descrito em `PUBLICOS` (texto, tipo, opções, legenda
  analítica) e um motor genérico escolhe a visualização por tipo de questão:
  - categórica → rosca/barra · múltipla → barra · escala → barras + média
  - avaliação → mapa de calor · numérica → estatísticas · texto → frequência/verbatim
  - NPS automático nas questões de recomendação
- Inclui ficha técnica (n, período, pesquisadores, margem de erro estimada),
  resumo executivo automático, perfil demográfico e **todas as questões**.
- **Exportação PDF**: botão *Imprimir / Salvar PDF* + estilos `@media print`.

> **Nota sobre cobertura:** as entrevistas de Morador coletadas em jun/2026 correspondem a uma
> versão anterior (mais enxuta) do questionário; questões adicionadas depois aparecem como
> "sem respostas nesta amostra". O indicador de cobertura no relatório explicita isso.

## Como rodar localmente

Servir a pasta por HTTP (necessário para PWA/fetch — não abrir via `file://`):

```bash
# Python
python -m http.server 8765
# ou Node
npx http-server -p 8765
```

Depois acesse:
- Coleta: `http://localhost:8765/index.html`
- Dashboard geral: `http://localhost:8765/dashboard.html`
- Relatórios por público: `http://localhost:8765/relatorios.html`

## Segurança

A chave Supabase embutida é a `anon` (pública por design). A proteção real depende das
**RLS policies** do banco. Revisar as policies de `SELECT`/`INSERT` é recomendado antes de
expor o app publicamente.
