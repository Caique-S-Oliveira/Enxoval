# Segurança do projeto

## O que já está protegido (no código)

**Dados no Supabase**
- As tabelas ficam fechadas. A chave pública só consegue chamar 4 funções: criar, ler, gravar e apagar.
- Cada casal é identificado por um código de 25 caracteres (cerca de 125 bits de aleatoriedade), impossível de adivinhar por tentativa. O banco guarda só o resumo (hash SHA-256) do código, nunca o código em si.
- Criar um espaço novo exige um convite de 12 caracteres, de uso único, que só o dono gera no painel do Supabase.
- As funções usam `search_path` vazio (protege contra desvio de nomes) e só mexem nas tabelas do `enxoval`. Tamanho máximo por casal: cerca de 400 KB.
- A gravação confere a versão, então um celular não apaga por engano o que o outro gravou.

**Página no ar (Render)**
- Política de segurança de conteúdo (CSP) que só permite falar com o **seu** projeto Supabase e com mais nada: sem scripts, imagens, fontes ou formulários de fora.
- Proibido abrir o app dentro de outro site (`frame-ancestors 'none'` e `X-Frame-Options: DENY`).
- Sem envio de endereço de origem (`Referrer-Policy: no-referrer`), sem acesso a câmera, microfone e localização, `nosniff`, HTTPS forçado (HSTS).
- Fora dos buscadores (`robots.txt`, `noindex` e `X-Robots-Tag`).
- Só a pasta `site/` é publicada. SQL e documentos não ficam acessíveis pela internet.
- O código do casal fica só no aparelho (localStorage) e nunca vai em endereço de site (URL).

## O que só você pode fazer (checklist)

**GitHub**
- [ ] Repositório **Private**.
- [ ] Ativar verificação em duas etapas na conta (Settings → Password and authentication).
- [ ] Settings → Code security: ligar **Secret scanning** e **Push protection**, se disponíveis no seu plano.
- [ ] Settings → Branches: proteger a `main` (exigir pull request ou impedir force push).

**Render**
- [ ] Verificação em duas etapas na conta.
- [ ] Previews de pull request desligados (já está no `render.yaml`).
- [ ] Depois do primeiro deploy, conferir os cabeçalhos em securityheaders.com (ou no DevTools do navegador, aba Rede).

**Supabase**
- [ ] Verificação em duas etapas na conta.
- [ ] Em **Project Settings → API**, confirmar que no app está **só** a chave pública.
- [ ] Se alguma vez colar a chave `service_role` ou `secret` em qualquer lugar: gire (troque) a chave no painel na hora.
- [ ] Em **Database → Backups**, veja o que o seu plano oferece.
- [ ] Em **Settings → API → Exposed schemas**, confirme que `enxoval` **não** está na lista.
- [ ] Não crie políticas (policies) nem dê permissões nas tabelas do schema `enxoval`.

## Limites que você precisa conhecer

- **Quem tem o código do casal vê e altera tudo daquele casal.** Peça para não mandarem em grupo aberto nem por e-mail público.
- **O dono do Supabase (você) consegue ler os dados de todos os casais** pelo painel. Avise o casal amigo.
- Não há recuperação do código: se perderem em todos os aparelhos, o espaço fica inacessível. O backup em arquivo é a alternativa.
- Não existe limite de tentativas. Isso é aceitável porque o código é longo demais para ser adivinhado. Para uma versão paga, o ideal é adicionar login por e-mail e limite de tentativas.
- Antes de vender: aviso de privacidade, termos de uso, adequação à LGPD, e revisão por advogado e por pediatra.

## Se algo vazar

1. **Código de um casal:** o casal clica em **Apagar dados do servidor** (ou você apaga o espaço no painel), cria um espaço novo com outro convite e importa o backup.
2. **Chave secreta do Supabase:** gire a chave no painel, imediatamente.
3. **Convite não usado:** ignore e gere outro. Convites não usados não dão acesso a dados.
4. **Tudo:** rode `supabase/supabase_remover_tudo.sql` para apagar o espaço do enxoval e comece de novo.
