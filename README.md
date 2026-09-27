# 🚲 RADICAL BIKE STREET — Loja Virtual & Painel de Gestão

Aplicação completa, funcional e escalável para loja local de peças e acessórios de bicicletas, construída com identidade visual **Street + BMX + MTB + Urbano + Neon**, integração dinâmica com **WhatsApp** e backend em **Supabase**.

---

## ⚡ Destaques & Funcionalidades

### 1. Vitrine & Experiência do Cliente
- **Visual Urbano Neon**: Fundo grafite escuro (`#07080A`), roxo neon (`#B829E3`) e verde neon elétrico (`#00FF87`), com tipografia street marcante.
- **Catálogo Completo (`/produtos`)**:
  - Busca em tempo real por nome, descrição ou código SKU.
  - Filtro interativo por categorias e status de disponibilidade.
  - Ordenação por menor preço, maior preço ou lançamentos.
  - Badges de estoque visuais:
    - 🟢 Em estoque
    - 🟡 Estoque baixo (≤ 3 unidades)
    - 🔴 Esgotado
- **Página de Detalhes da Peça (`/produto/:slug`)**:
  - Especificações técnicas detalhadas (material, medidas, peso, fluido).
  - Indicação de compatibilidade (aros, guidões, relações de marcha).
  - Trava automática: quando estoque = 0, exibe **"FORA DE ESTOQUE"** e desabilita o carrinho.
  - Botão de compra direta e dúvidas no WhatsApp.
- **Carrinho de Compras (`/carrinho`)**:
  - Ajuste dinâmico de quantidades com trava de estoque máximo.
  - Cálculo de subtotal, frete estimado e total.
  - Validação de pedido mínimo configurável.
- **Checkout Inteligente (`/checkout`)**:
  - Escolha entre **Retirada na Loja** (sem taxa, endereço dispensado) ou **Entrega** (taxa calculada, endereço obrigatório).
  - Opções de pagamento: **PIX**, **Dinheiro** ou **Combinar pelo WhatsApp**.
  - Gravação do pedido no banco de dados e redirecionamento para confirmação.
- **Integração com WhatsApp Oficial**:
  - **Número centralizado**: Armazenado na tabela `store_settings` (padrão inicial: `5579998248239`) e editável pelo painel — **sem números fixos espalhados pelo código**.
  - **Disparo dinâmico do checkout**: Gera automaticamente o formato estruturado do pedido com emojis, lista de itens, subtotais, dados de entrega e observações.

---

### 2. Painel Administrativo (`/admin`)
- **Autenticação Segura**: Integrada com Supabase Auth (e-mail e senha) e suporte a acesso de demonstração instantâneo.
- **Dashboard (`/admin`)**:
  - Métricas: Vendas hoje, vendas no mês, pedidos hoje, pedidos pendentes, total de peças, produtos com estoque baixo e produtos esgotados.
  - Alertas visuais de produtos críticos.
  - Lista de pedidos recentes.
- **Gerenciamento de Produtos (`/admin/produtos`)**:
  - CRUD completo: Cadastrar, Editar, Excluir, Duplicar e Ativar/Desativar em 1 clique.
  - **Preço de Custo (`cost_price`)**: Exibido com cálculo de margem de lucro percentual no painel admin, estritamente oculto para clientes na loja pública.
- **Controle de Estoque (`/admin/estoque`)**:
  - Ajustes rápidos com botões `+1` / `-1` e edição direta.
  - **Baixa Automática**: Ao alterar o status de um pedido para `"Confirmado"`, o estoque dos produtos é decrementado automaticamente sem nunca ficar negativo.
- **Gestão de Pedidos (`/admin/pedidos`)**:
  - Funil de status: `Novo` ➔ `Confirmado` ➔ `Pago` ➔ `Separando` ➔ `Saiu para entrega` ➔ `Concluído` ➔ `Cancelado`.
  - Botão direto para iniciar conversa no WhatsApp com o cliente.
- **Clientes (`/admin/clientes`)**:
  - Histórico de compradores, total gasto acumulado e link rápido para WhatsApp.
- **Categorias (`/admin/categorias`)**:
  - Gestão de categorias de peças (Freios, Transmissão, Pneus, etc.).
- **Aparência (`/admin/aparencia`)**:
  - Edição do título e subtítulo da home, imagem do hero e paleta de cores neon.
- **Configurações Gerais (`/admin/configuracoes`)**:
  - Edição do número de WhatsApp da loja, Instagram, endereço físico, horário de funcionamento e taxa de entrega.

---

## 🛠️ Tecnologias Utilizadas

- **Frontend**: React 18, TypeScript, Tailwind CSS, Lucide Icons, React Router DOM v6
- **Build Tool**: Vite 6 (build ultraveloz e otimizado)
- **Backend & Banco**: Supabase (PostgreSQL, Row Level Security, Triggers e Auth)
- **Resiliência / Modo Híbrido**: Camada de serviço inteligente com fallback automático para LocalStorage caso as credenciais do Supabase ainda não tenham sido inseridas, permitindo testes locais imediatos sem quebra de execução.

---

## 🚀 Como Executar o Projeto Localmente

1. **Instalar dependências**:
   ```bash
   npm install
   ```

2. **Iniciar servidor de desenvolvimento**:
   ```bash
   npm run dev
   ```
   Acesse no navegador: `http://localhost:3000`

3. **Gerar build de produção**:
   ```bash
   npm run build
   ```

---

## 📦 Como Conectar ao Supabase

Consulte o arquivo **[SUPABASE_SETUP.md](./SUPABASE_SETUP.md)** para o passo a passo ilustrado de como criar o banco de dados, rodar o script SQL e configurar suas chaves.
