-- ============================================================================
-- Migration · Canaã Junina 2026 · 2026-06-24
-- Integridade do sync + correção do tipo COMERCIANTE
-- Projeto Supabase: canaa-junina-2026 (zhioebfzuugfjhblhfwp)
-- Aplicada via MCP/apply_migration. Versionada aqui para auditoria.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PARTE A — Limpeza one-off dos dados já existentes (executada com backup prévio:
--           backups/supabase_backup_2026-06-24.json). NÃO re-executar.
-- ----------------------------------------------------------------------------

-- A1) Deduplica respostas: mantém a de menor id por (entrevista_id, questao).
--     Removeu 10 linhas (1 entrevista com o conjunto de respostas gravado em dobro).
DELETE FROM respostas r
USING respostas r2
WHERE r.entrevista_id = r2.entrevista_id
  AND r.questao       = r2.questao
  AND r.id > r2.id;

-- A2) Remove entrevistas status=completo SEM nenhuma resposta (brancos/abandonados).
--     Removeu 17 registros. Resultado: 412 entrevistas válidas / 4121 respostas.
DELETE FROM entrevistas e
WHERE e.status = 'completo'
  AND NOT EXISTS (SELECT 1 FROM respostas r WHERE r.entrevista_id = e.id);

-- ----------------------------------------------------------------------------
-- PARTE B — Constraints de integridade (DDL permanente).
-- ----------------------------------------------------------------------------

-- B1) Impede respostas duplicadas na origem; habilita o upsert idempotente do app
--     (POST /respostas?on_conflict=entrevista_id,questao  Prefer: resolution=ignore-duplicates).
ALTER TABLE public.respostas
  ADD CONSTRAINT respostas_entrevista_questao_key UNIQUE (entrevista_id, questao);

-- B2) Inclui COMERCIANTE nos tipos permitidos.
--     Bug: o Questionário D (Comerciantes Locais, v0.7.0) era rejeitado pelo CHECK antigo.
ALTER TABLE public.entrevistas DROP CONSTRAINT entrevistas_tipo_check;
ALTER TABLE public.entrevistas
  ADD CONSTRAINT entrevistas_tipo_check
  CHECK (tipo = ANY (ARRAY['VISITANTE'::text, 'MORADOR'::text, 'EXPOSITOR'::text, 'COMERCIANTE'::text]));

-- ----------------------------------------------------------------------------
-- Observação: entrevistas.session_id já possuía UNIQUE (entrevistas_session_id_key),
-- usado pelo upsert da entrevista (on_conflict=session_id). Nenhuma ação necessária.
-- ============================================================================
