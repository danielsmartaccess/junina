-- ============================================================================
-- Migration · Canaã Junina 2026 · 2026-06-26
-- Limpeza one-off da tabela EXPOSITOR antes do início da coleta de campo
-- Projeto Supabase: canaa-junina-2026 (zhioebfzuugfjhblhfwp)
-- Aplicada via MCP/execute_sql. Versionada aqui para auditoria.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONTEXTO
--   A onda EXPOSITOR (Questionário C) ainda NÃO havia começado oficialmente.
--   Restava 1 registro avulso de teste/treino do piloto (18/06), do pesquisador
--   "Luciano da Costa Sousa" (session SES-1781790282824-3gj5), sincronizado só
--   em 26/06 — ruído antes do início real da coleta.
--   Backup íntegro prévio: backups/expositor_pre_delete_2026-06-26.json
--   (1 entrevista + 18 respostas). NÃO re-executar.
-- ----------------------------------------------------------------------------

-- Exclusão atômica e escopada a tipo='EXPOSITOR' (respostas → entrevista).
-- Resultado: 1 entrevista e 18 respostas removidas.
-- Públicos não afetados: MORADOR (413 entrevistas / 4130 respostas).
WITH alvo AS (
  SELECT id FROM entrevistas WHERE tipo = 'EXPOSITOR'
),
del_resp AS (
  DELETE FROM respostas
  WHERE entrevista_id IN (SELECT id FROM alvo)
  RETURNING id
),
del_ent AS (
  DELETE FROM entrevistas
  WHERE id IN (SELECT id FROM alvo)
  RETURNING id
)
SELECT (SELECT COUNT(*) FROM del_ent)  AS entrevistas_removidas,
       (SELECT COUNT(*) FROM del_resp) AS respostas_removidas;

-- ----------------------------------------------------------------------------
-- Observação: a coleta COMERCIANTE (Questionário D) inicia 26/06 com a tabela
-- zerada. Os 3 registros de teste de 24/06 (pesquisador Dani, geo Porto Alegre)
-- já haviam sido removidos; backup em
-- backups/comerciantes_teste_pre_delete_2026-06-26.json.
-- ============================================================================
