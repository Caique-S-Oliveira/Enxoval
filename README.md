# Enxoval do bebê

App de uma página só para planejar o enxoval do bebê, com lista ajustada ao perfil do casal e sincronização opcional entre celulares.

## O que tem aqui

| Pasta ou arquivo | Para que serve |
|---|---|
| `site/` | O app. **Só esta pasta vai para o ar.** |
| `site/index.html` | O app inteiro (sem bibliotecas externas). |
| `render.yaml` | Configuração do Render, com os cabeçalhos de segurança. |
| `supabase/supabase_setup.sql` | Cria o espaço `enxoval` no Supabase (rodar uma vez). |
| `supabase/supabase_remover_tudo.sql` | Apaga tudo do enxoval no Supabase (sem volta). |
| `SECURITY.md` | Lista de proteções e o que conferir. |
| `PASSO_A_PASSO.md` | Como publicar e como gerar convites. |

## Regras deste repositório

- **Nunca** colocar aqui a chave `service_role` ou `secret` do Supabase. Só a chave pública (`sb_publishable_...` ou `anon`) pode ficar em `site/index.html`.
- Nunca subir backups (`backup*.json`), códigos de casais ou convites.
- Mantenha o repositório **privado**.

## Aviso

O app é um apoio de planejamento. Não substitui a orientação do pediatra.
