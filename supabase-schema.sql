-- APOLOPRIMER: ejecutar en Supabase SQL Editor.
-- Crea primero un usuario administrador en Authentication > Users.
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.movies (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  year integer,
  video_url text not null,
  video_path text not null,
  cover_url text,
  owner_id uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  owner_id uuid not null references auth.users(id),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.admins enable row level security;
alter table public.movies enable row level security;
alter table public.rooms enable row level security;

-- El usuario solo puede consultar su propio registro de administrador.
create policy "admin reads own role" on public.admins
for select to authenticated using (user_id = auth.uid());

-- El catálogo es público; las altas/ediciones/borrados requieren admin.
create policy "movies public read" on public.movies
for select to anon, authenticated using (true);
create policy "admins insert movies" on public.movies
for insert to authenticated with check (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
);
create policy "admins update movies" on public.movies
for update to authenticated using (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
) with check (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
);
create policy "admins delete movies" on public.movies
for delete to authenticated using (
  exists (select 1 from public.admins a where a.user_id = auth.uid())
);

-- Las salas se encuentran por código. Solo usuarios autenticados pueden ver/crear.
create policy "authenticated can find active rooms" on public.rooms
for select to authenticated using (active = true);
create policy "authenticated create own rooms" on public.rooms
for insert to authenticated with check (owner_id = auth.uid());
create policy "owner updates own rooms" on public.rooms
for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- Buckets públicos: la reproducción no requiere login. Solo admins pueden subir.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values
 ('movies','movies',true,2147483648,array['video/mp4','video/webm','video/quicktime']),
 ('covers','covers',true,10485760,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = excluded.public,
 file_size_limit = excluded.file_size_limit,
 allowed_mime_types = excluded.allowed_mime_types;

create policy "public can read movie files" on storage.objects
for select to anon, authenticated using (bucket_id in ('movies','covers'));
create policy "admins upload movie files" on storage.objects
for insert to authenticated with check (
 bucket_id in ('movies','covers') and
 exists (select 1 from public.admins a where a.user_id = auth.uid())
);
create policy "admins update movie files" on storage.objects
for update to authenticated using (
 bucket_id in ('movies','covers') and
 exists (select 1 from public.admins a where a.user_id = auth.uid())
) with check (
 bucket_id in ('movies','covers') and
 exists (select 1 from public.admins a where a.user_id = auth.uid())
);
create policy "admins delete movie files" on storage.objects
for delete to authenticated using (
 bucket_id in ('movies','covers') and
 exists (select 1 from public.admins a where a.user_id = auth.uid())
);

-- Habilita Realtime para mensajes/control por Broadcast.
-- En Supabase Dashboard: Database > Replication/Realtime, habilita Broadcast
-- o deja los canales de Realtime disponibles para el proyecto.
