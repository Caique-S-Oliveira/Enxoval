-- =====================================================================
-- Enxoval do bebê: espaço por casal no Supabase
-- Rode UMA vez, no SQL Editor do Supabase (cole tudo e clique em Run).
--
-- O que isto cria:
--  * um espaço isolado chamado "enxoval" (não mexe em nada que já existe);
--  * uma tabela de casais (guarda só o resumo do código, nunca o código);
--  * uma tabela de convites (um convite por casal);
--  * 4 funções que o app usa: criar espaço, ler, gravar e apagar.
--
-- Segurança:
--  * as tabelas ficam fechadas: o app só entra pelas funções;
--  * sem o código do casal (25 letras e números) não se lê nem se grava nada;
--  * criar um espaço novo exige um convite de uso único, que só você gera.
-- =====================================================================

create schema if not exists enxoval;
revoke all on schema enxoval from public, anon, authenticated;

create table if not exists enxoval.casais (
  id          uuid primary key default gen_random_uuid(),
  codigo_hash bytea not null unique,
  dados       jsonb not null default '{}'::jsonb,
  versao      integer not null default 0,
  nota        text,
  criado      timestamptz not null default now(),
  atualizado  timestamptz not null default now()
);

create table if not exists enxoval.convites (
  hash   bytea primary key,
  nota   text,
  criado timestamptz not null default now(),
  usado  timestamptz
);

alter table enxoval.casais    enable row level security;
alter table enxoval.convites  enable row level security;
revoke all on all tables in schema enxoval from public, anon, authenticated;

-- ---------- funções internas (o app não chama estas) ----------

create or replace function enxoval.gerar(p_tamanho integer)
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  alfabeto constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';  -- 32 símbolos, sem I, O, 0, 1
  r text := '';
  b bytea;
  j integer;
begin
  while pg_catalog.length(r) < p_tamanho loop
    b := pg_catalog.uuid_send(pg_catalog.gen_random_uuid());
    for j in 0..15 loop
      continue when j = 6;                     -- esse byte tem bits fixos
      exit when pg_catalog.length(r) >= p_tamanho;
      r := r || pg_catalog.substr(alfabeto, (pg_catalog.get_byte(b, j) % 32) + 1, 1);
    end loop;
  end loop;
  return r;
end
$$;

create or replace function enxoval.norm(p_texto text)
returns text
language sql
immutable
set search_path = ''
as $$
  select pg_catalog.upper(pg_catalog.regexp_replace(coalesce(p_texto, ''), '[^A-Za-z0-9]', '', 'g'))
$$;

create or replace function enxoval.h(p_texto text)
returns bytea
language sql
immutable
set search_path = ''
as $$
  select pg_catalog.sha256(pg_catalog.convert_to(enxoval.norm(p_texto), 'UTF8'))
$$;

revoke all on function enxoval.gerar(integer) from public, anon, authenticated;
revoke all on function enxoval.norm(text)     from public, anon, authenticated;
revoke all on function enxoval.h(text)        from public, anon, authenticated;

-- ---------- só você roda esta, no SQL Editor: gera um convite ----------

create or replace function public.enx_novo_convite(p_nota text default null)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  c text := enxoval.gerar(12);
begin
  insert into enxoval.convites (hash, nota) values (enxoval.h(c), p_nota);
  return c;
end
$$;
revoke all on function public.enx_novo_convite(text) from public, anon, authenticated;

-- ---------- funções que o app usa ----------

create or replace function public.enx_criar(p_convite text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_nota text;
  v_cod  text;
begin
  update enxoval.convites
     set usado = pg_catalog.now()
   where hash = enxoval.h(p_convite) and usado is null
  returning nota into v_nota;

  if not found then
    return pg_catalog.jsonb_build_object('erro', 'convite');
  end if;

  v_cod := enxoval.gerar(25);
  insert into enxoval.casais (codigo_hash, nota) values (enxoval.h(v_cod), v_nota);
  return pg_catalog.jsonb_build_object('codigo', v_cod);
end
$$;

create or replace function public.enx_ler(p_codigo text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  r enxoval.casais%rowtype;
begin
  select * into r from enxoval.casais where codigo_hash = enxoval.h(p_codigo);
  if not found then
    return pg_catalog.jsonb_build_object('erro', 'codigo');
  end if;
  return pg_catalog.jsonb_build_object('versao', r.versao, 'dados', r.dados, 'atualizado', r.atualizado);
end
$$;

create or replace function public.enx_gravar(p_codigo text, p_dados jsonb, p_base integer)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  r enxoval.casais%rowtype;
begin
  select * into r from enxoval.casais where codigo_hash = enxoval.h(p_codigo) for update;
  if not found then
    return pg_catalog.jsonb_build_object('erro', 'codigo');
  end if;
  if p_dados is null or pg_catalog.jsonb_typeof(p_dados) <> 'object' then
    return pg_catalog.jsonb_build_object('erro', 'dados');
  end if;
  if pg_catalog.octet_length(p_dados::text) > 400000 then
    return pg_catalog.jsonb_build_object('erro', 'grande');
  end if;
  if p_base is distinct from r.versao then
    return pg_catalog.jsonb_build_object('conflito', true, 'versao', r.versao, 'dados', r.dados);
  end if;
  update enxoval.casais
     set dados = p_dados, versao = r.versao + 1, atualizado = pg_catalog.now()
   where id = r.id;
  return pg_catalog.jsonb_build_object('ok', true, 'versao', r.versao + 1);
end
$$;

create or replace function public.enx_apagar(p_codigo text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from enxoval.casais where codigo_hash = enxoval.h(p_codigo);
  if not found then
    return pg_catalog.jsonb_build_object('erro', 'codigo');
  end if;
  return pg_catalog.jsonb_build_object('ok', true);
end
$$;

-- o app (chave pública) só pode chamar estas 4 funções
revoke all on function public.enx_criar(text)                  from public, anon, authenticated;
revoke all on function public.enx_ler(text)                    from public, anon, authenticated;
revoke all on function public.enx_gravar(text, jsonb, integer) from public, anon, authenticated;
revoke all on function public.enx_apagar(text)                 from public, anon, authenticated;
grant execute on function public.enx_criar(text)                  to anon, authenticated;
grant execute on function public.enx_ler(text)                    to anon, authenticated;
grant execute on function public.enx_gravar(text, jsonb, integer) to anon, authenticated;
grant execute on function public.enx_apagar(text)                 to anon, authenticated;
