# Guia de Configuração do Supabase — Radical Bike Street

Siga este passo a passo para conectar o banco de dados Supabase em produção.

---

## 1. Criar o Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com) e faça login.
2. Clique em **"New Project"**.
3. Escolha um nome (ex: `radical-bike-store`), defina uma senha segura para o banco e selecione a região mais próxima (ex: `South America (São Paulo)`).
4. Aguarde cerca de 2 minutos até o provisionamento concluir.

---

## 2. Executar o Script SQL no Supabase

1. No menu lateral do dashboard do Supabase, clique em **SQL Editor**.
2. Clique em **"New query"**.
3. Abra o arquivo **`supabase_schema.sql`** que está na raiz deste projeto, copie todo o seu conteúdo e cole no editor do Supabase.
4. Clique no botão **"Run"** (ou pressione `Ctrl + Enter`).
5. Todas as tabelas, índices, triggers de baixa de estoque automática, sequência de pedidos (`#00001`), políticas de segurança (RLS) e dados de demonstração serão criados instantaneamente.

---

## 3. Configurar as Variáveis de Ambiente no Projeto

1. No dashboard do Supabase, vá em **Project Settings** (ícone de engrenagem) ➔ **API**.
2. Copie:
   - **Project URL**
   - **anon / public key**
3. Na pasta do projeto `bike-shop-urban`, abra o arquivo `.env` e preencha:
   ```env
   VITE_SUPABASE_URL=https://seu-projeto.supabase.co
   VITE_SUPABASE_ANON_KEY=sua-chave-anon-publica-aqui
   ```
4. Reinicie o servidor de desenvolvimento (`npm run dev`). A partir desse momento, a aplicação estará lendo e gravando diretamente no PostgreSQL do Supabase!

---

## 4. Criar o Primeiro Usuário Administrador

1. No Supabase, vá em **Authentication** ➔ **Users**.
2. Clique em **"Add User"** ➔ **"Create User"**.
3. Informe o e-mail e senha desejados (ex: `admin@radicalbike.com` e uma senha forte).
4. No **SQL Editor**, vincule o ID do usuário criado à tabela de administradores:
   ```sql
   INSERT INTO public.profiles (id, full_name, role)
   SELECT id, 'Administrador Radical', 'admin'
   FROM auth.users
   WHERE email = 'admin@radicalbike.com'
   ON CONFLICT (id) DO NOTHING;
   ```
5. Agora acesse `http://localhost:3000/admin/login` e entre com o e-mail e senha cadastrados!

---

## 5. Como Configurar o WhatsApp da Loja

- O número inicial já vem configurado como **`5579998248239`**.
- Para alterá-lo a qualquer momento, basta entrar no painel administrativo em:
  👉 **`/admin/configuracoes`**
- Altere o campo **"WhatsApp Oficial"** e clique em **Salvar**.
- Todas as mensagens do checkout e dúvidas de produtos usarão imediatamente o novo número.

---

## 6. Publicação (Deploy)

### Deploy na Vercel:
1. Suba o projeto para um repositório no GitHub.
2. Conecte o repositório na [Vercel](https://vercel.com).
3. Em **Environment Variables**, adicione:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Clique em **Deploy**.
