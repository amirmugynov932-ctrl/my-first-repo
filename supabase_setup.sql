-- TANDAU database setup for Supabase
create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  category text not null check (category in ('Спорт','Одежда','Обувь','Аксессуары')),
  price_kzt numeric(12,2) not null check (price_kzt >= 0),
  stock integer not null default 0 check (stock >= 0),
  sizes text[] not null default '{}',
  badge text,
  image_urls text[] not null default '{}',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.store_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.store_admins enable row level security;

-- Security-definer helper avoids exposing the admin list to public users.
create or replace function public.is_tandau_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.store_admins
    where user_id = (select auth.uid())
  );
$$;

revoke all on function public.is_tandau_admin() from public;
grant execute on function public.is_tandau_admin() to anon, authenticated;

drop policy if exists "Public can view active products" on public.products;
create policy "Public can view active products"
on public.products for select
to anon, authenticated
using (is_active = true or public.is_tandau_admin());

drop policy if exists "Admins can insert products" on public.products;
create policy "Admins can insert products"
on public.products for insert
to authenticated
with check (public.is_tandau_admin());

drop policy if exists "Admins can update products" on public.products;
create policy "Admins can update products"
on public.products for update
to authenticated
using (public.is_tandau_admin())
with check (public.is_tandau_admin());

drop policy if exists "Admins can delete products" on public.products;
create policy "Admins can delete products"
on public.products for delete
to authenticated
using (public.is_tandau_admin());

-- Public image bucket. Product images are public to view, but only admins can upload/change/delete.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('product-images', 'product-images', true, 8388608, array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do update set public = true, file_size_limit = 8388608,
allowed_mime_types = array['image/jpeg','image/png','image/webp','image/avif'];

drop policy if exists "Anyone can view TANDAU product images" on storage.objects;
create policy "Anyone can view TANDAU product images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'product-images');

drop policy if exists "TANDAU admins can upload product images" on storage.objects;
create policy "TANDAU admins can upload product images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'product-images' and public.is_tandau_admin());

drop policy if exists "TANDAU admins can update product images" on storage.objects;
create policy "TANDAU admins can update product images"
on storage.objects for update
to authenticated
using (bucket_id = 'product-images' and public.is_tandau_admin())
with check (bucket_id = 'product-images' and public.is_tandau_admin());

drop policy if exists "TANDAU admins can delete product images" on storage.objects;
create policy "TANDAU admins can delete product images"
on storage.objects for delete
to authenticated
using (bucket_id = 'product-images' and public.is_tandau_admin());
