# Publicar e gerenciar casais

Este repositório já está com a URL e a chave pública do seu Supabase dentro de `site/index.html`.

## 1. Subir no GitHub (pelo site, sem instalar nada)

1. Em github.com, clique em **New repository**. Nome: `enxoval`. Marque **Private**. Clique em **Create repository**.
2. Clique em **uploading an existing file**.
3. Abra a pasta do projeto no seu computador, selecione **todo o conteúdo** (as pastas `site` e `supabase`, e os arquivos `render.yaml`, `README.md`, `SECURITY.md`, `PASSO_A_PASSO.md`, `.gitignore`) e arraste para a página.
   - O arquivo `.gitignore` começa com ponto e pode ficar escondido. Se não aparecer, tudo bem: o app funciona sem ele.
4. Clique em **Commit changes**.
5. Confira, na página do repositório, que existe a pasta `site` com `index.html` dentro.

## 2. Colocar no ar com o Render

**Opção A (recomendada): pelo `render.yaml`, que já traz os cabeçalhos de segurança**
1. Em render.com, entre com o GitHub. Clique em **New → Blueprint**.
2. Escolha o repositório `enxoval` e clique em **Connect**.
3. O Render lê o `render.yaml` e mostra o serviço `enxoval`. Clique em **Apply** (ou **Deploy Blueprint**).
4. Espere terminar. O endereço aparece no serviço, parecido com `https://enxoval-xxxx.onrender.com`.

**Opção B (se a A der problema): manual**
1. **New → Static Site**, escolha o repositório.
2. **Build Command:** `echo ok`. **Publish Directory:** `site`.
3. Depois de criar, abra **Settings → Headers** e adicione os cabeçalhos do `render.yaml`, um por um (path `/*`).

Confira os limites do plano gratuito no site do Render, porque eles mudam.

## 3. Conferir

- Abra o endereço no celular. Em **Resumo** deve aparecer o card **Sincronizar os dois celulares**.
- No computador, abra o DevTools (F12), aba **Rede**, clique no primeiro item e veja se aparece `Content-Security-Policy` nos cabeçalhos da resposta.
- Se o card aparecer mas der erro ao criar o espaço, o problema geralmente é o texto do banco não ter sido executado, ou a chave colada errada.

## 4. Novo casal (sempre o mesmo processo)

1. No Supabase: **SQL Editor → New query**.
2. Rode, trocando o nome:
   ```
   select public.enx_novo_convite('Casal Fulano');
   ```
3. Copie o convite de 12 caracteres e mande ao casal, junto com o endereço do site.
4. No celular deles: abrir o endereço, preencher o perfil, **Resumo → Criar espaço do casal** e digitar o convite.
5. O app mostra o **código do casal** (25 caracteres). Eles anotam e usam no outro celular em **Entrar com código**.

**Para ver os espaços criados (sem mostrar nenhum código):**
```
select nota, criado, usado from enxoval.convites order by criado;
select nota, criado, atualizado, versao from enxoval.casais order by criado;
```

## 5. Atualização automática entre os celulares

O app consulta o servidor a cada 4 segundos, enquanto está aberto na tela, só para saber se algo mudou. Se mudou, baixa e junta sozinho. Com isso, o que um celular altera aparece no outro em poucos segundos, sem apertar "Sincronizar agora".

Para isso funcionar, o Supabase precisa de uma função pequena a mais:
1. Abra **SQL Editor → New query** no Supabase.
2. Cole o conteúdo de `supabase/supabase_atualizacao_automatica.sql` e clique em **Run**. Rodar de novo não dá problema.
3. Pronto. Não precisa mexer no site de novo além de publicar o `index.html` novo.

Sem essa função o app continua funcionando, mas a mudança do outro celular só aparece a cada 45 segundos.

Observações: o app só consulta com a tela ligada e aberta (celular bloqueado ou app em segundo plano não consulta, e ao voltar ele atualiza na hora). Cada consulta é minúscula e não conta como baixar os dados.

## 6. Atualizar o app depois

No GitHub, abra `site/index.html`, clique no lápis (editar) ou em **Add file → Upload files**, substitua e dê **Commit changes**. O Render publica de novo sozinho.

Se trocar a URL ou a chave do Supabase, atualize também o valor `connect-src` no `render.yaml` e na tag `Content-Security-Policy` do `index.html`. Do contrário o navegador bloqueia a conexão.
