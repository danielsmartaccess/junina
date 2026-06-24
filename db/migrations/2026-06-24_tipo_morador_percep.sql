-- ============================================================================
-- Migration · Canaã Junina 2026 · 2026-06-24
-- Novo instrumento: Questionário E — Moradores · Percepção & Satisfação
-- Projeto Supabase: canaa-junina-2026 (zhioebfzuugfjhblhfwp)
-- Aplicada via MCP/apply_migration. Versionada aqui para auditoria.
-- ============================================================================

-- Inclui MORADOR_PERCEP nos tipos permitidos (2ª onda do público morador, lente de
-- satisfação/percepção de impacto — CSAT, NPS, impacto multidimensional, saldo líquido).
-- Não altera dados existentes; apenas amplia o domínio do CHECK.
ALTER TABLE public.entrevistas DROP CONSTRAINT entrevistas_tipo_check;
ALTER TABLE public.entrevistas
  ADD CONSTRAINT entrevistas_tipo_check
  CHECK (tipo = ANY (ARRAY['VISITANTE'::text, 'MORADOR'::text, 'EXPOSITOR'::text, 'COMERCIANTE'::text, 'MORADOR_PERCEP'::text]));
