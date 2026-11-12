-- APOLOPRIMER: función para buscar salas por código.
-- Ejecutar en Supabase SQL Editor después de supabase-schema.sql.
-- SECURITY INVOKER mantiene las políticas RLS de public.rooms.
create or replace function public.find_room_by_code(p_code text)
returns table (
  id uuid,
  code text,
  name text,
  owner_id uuid,
  active boolean,
  created_at timestamptz
)
language sql
stable
security invoker
set search_path = public
as $$
  select r.id, r.code, r.name, r.owner_id, r.active, r.created_at
  from public.rooms as r
  where r.code = upper(trim(p_code))
    and r.active = true
  limit 1;
$$;

revoke all on function public.find_room_by_code(text) from public;
grant execute on function public.find_room_by_code(text) to authenticated;
