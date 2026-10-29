-- CUIDADO: apaga o espaço do enxoval e TODOS os dados dos casais. Não tem volta.
drop function if exists public.enx_novo_convite(text);
drop function if exists public.enx_criar(text);
drop function if exists public.enx_ler(text);
drop function if exists public.enx_gravar(text, jsonb, integer);
drop function if exists public.enx_apagar(text);
drop schema if exists enxoval cascade;
