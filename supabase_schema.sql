-- ==============================================================================
-- LOJA VIRTUAL DE PEÇAS E ACESSÓRIOS PARA BICICLETAS (STREET / URBAN / NEON)
-- ESQUEMA COMPLETO DE BANCO DE DADOS SUPABASE (PostgreSQL + RLS + Triggers)
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Perfis de Usuário (Admin)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'staff')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Categorias
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    active BOOLEAN NOT NULL DEFAULT true,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Produtos
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    sale_price NUMERIC(10,2) CHECK (sale_price IS NULL OR sale_price >= 0),
    cost_price NUMERIC(10,2) CHECK (cost_price IS NULL OR cost_price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    minimum_stock INTEGER NOT NULL DEFAULT 3 CHECK (minimum_stock >= 0),
    sku TEXT UNIQUE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    compatibility TEXT,
    specifications JSONB NOT NULL DEFAULT '{}'::jsonb,
    image_url TEXT,
    featured BOOLEAN NOT NULL DEFAULT false,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Imagens Adicionais
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Clientes
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Pedidos
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1;

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT NOT NULL UNIQUE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Novo' CHECK (status IN ('Novo', 'Confirmado', 'Pago', 'Separando', 'Saiu para entrega', 'Concluído', 'Cancelado')),
    payment_method TEXT NOT NULL CHECK (payment_method IN ('PIX', 'Dinheiro', 'Combinar pelo WhatsApp')),
    delivery_method TEXT NOT NULL CHECK (delivery_method IN ('Retirada', 'Entrega')),
    delivery_address TEXT,
    subtotal NUMERIC(10,2) NOT NULL DEFAULT 0,
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
    total NUMERIC(10,2) NOT NULL DEFAULT 0,
    notes TEXT,
    stock_deducted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Itens do Pedido (congelados na compra)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Configurações da Loja
CREATE TABLE IF NOT EXISTS public.store_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_name TEXT NOT NULL DEFAULT 'RADICAL BIKE STREET',
    logo_url TEXT,
    hero_image_url TEXT,
    whatsapp TEXT NOT NULL DEFAULT '5579998248239',
    instagram TEXT DEFAULT '@radicalbikestreet',
    address TEXT DEFAULT 'Av. Beira Mar, 1200 - Bairro 13 de Julho',
    city TEXT DEFAULT 'Aracaju - SE',
    opening_hours TEXT DEFAULT 'Segunda a Sábado: 08:00 às 19:00',
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 5.00,
    minimum_order NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    hero_title TEXT NOT NULL DEFAULT 'PEÇAS. BIKE. ATITUDE.',
    hero_subtitle TEXT NOT NULL DEFAULT 'Peças e acessórios de alta performance para deixar sua bike pronta para a rua e para a trilha.',
    primary_color TEXT NOT NULL DEFAULT '#A855F7',
    secondary_color TEXT NOT NULL DEFAULT '#00FF66',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Triggers
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE OR REPLACE TRIGGER trg_store_settings_updated_at BEFORE UPDATE ON public.store_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Geração sequencial de número de pedido (#00001)
CREATE OR REPLACE FUNCTION public.set_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        NEW.order_number := '#' || LPAD(nextval('order_number_seq')::text, 5, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_order_number BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_order_number();

-- Baixa de estoque automática ao confirmar pedido (nunca negativo)
CREATE OR REPLACE FUNCTION public.handle_order_stock_deduction()
RETURNS TRIGGER AS $$
DECLARE
    item RECORD;
BEGIN
    IF NEW.status = 'Confirmado' AND (OLD.status IS DISTINCT FROM 'Confirmado') AND NEW.stock_deducted = false THEN
        FOR item IN SELECT product_id, quantity FROM public.order_items WHERE order_id = NEW.id LOOP
            IF item.product_id IS NOT NULL THEN
                UPDATE public.products
                SET stock = GREATEST(0, stock - item.quantity)
                WHERE id = item.product_id;
            END IF;
        END LOOP;
        NEW.stock_deducted := true;
    END IF;

    IF NEW.status = 'Cancelado' AND OLD.status != 'Cancelado' AND NEW.stock_deducted = true THEN
        FOR item IN SELECT product_id, quantity FROM public.order_items WHERE order_id = NEW.id LOOP
            IF item.product_id IS NOT NULL THEN
                UPDATE public.products
                SET stock = stock + item.quantity
                WHERE id = item.product_id;
            END IF;
        END LOOP;
        NEW.stock_deducted := false;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_order_stock_deduction
BEFORE UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.handle_order_stock_deduction();

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN (EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    ));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Profiles view" ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "Categories public select" ON public.categories FOR SELECT USING (active = true OR public.is_admin());
CREATE POLICY "Categories admin all" ON public.categories FOR ALL USING (public.is_admin());
CREATE POLICY "Products public select" ON public.products FOR SELECT USING (active = true OR public.is_admin());
CREATE POLICY "Products admin all" ON public.products FOR ALL USING (public.is_admin());
CREATE POLICY "Store settings select" ON public.store_settings FOR SELECT USING (true);
CREATE POLICY "Store settings admin" ON public.store_settings FOR ALL USING (public.is_admin());
CREATE POLICY "Orders public insert" ON public.orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Orders select" ON public.orders FOR SELECT USING (true);
CREATE POLICY "Orders admin" ON public.orders FOR ALL USING (public.is_admin());
CREATE POLICY "Order items insert" ON public.order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Order items select" ON public.order_items FOR SELECT USING (true);
CREATE POLICY "Order items admin" ON public.order_items FOR ALL USING (public.is_admin());
