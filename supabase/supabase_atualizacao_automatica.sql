-- =====================================================================
-- Atualização automática entre os celulares (rode UMA vez, depois do supabase_setup.sql)
-- Cria uma função pequena que só diz "qual é a versão atual" do espaço do casal.
-- O app consulta isso a cada poucos segundos e só baixa os dados quando a versão muda.
-- Sem esta função o app continua funcionando, mas só vê a mudança do outro celular
-- a cada 45 segundos.
-- =====================================================================
create or replace function public.enx_versao(p_codigo text)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v integer;
begin
  select versao into v from enxoval.casais where codigo_hash = enxoval.h(p_codigo);
  if not found then
    return pg_catalog.jsonb_build_object('erro', 'codigo');
  end if;
  return pg_catalog.jsonb_build_object('versao', v);
end
$$;

revoke all on function public.enx_versao(text) from public, anon, authenticated;
grant execute on function public.enx_versao(text) to anon, authenticated;
