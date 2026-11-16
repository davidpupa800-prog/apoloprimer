-- APOLOPRIMER: reconocimiento de películas y series.
-- Ejecuta este archivo una sola vez en Supabase > SQL Editor.
alter table public.movies
  add column if not exists media_type text not null default 'movie',
  add column if not exists series_title text,
  add column if not exists season_number integer,
  add column if not exists episode_number integer,
  add column if not exists metadata jsonb not null default '{}'::jsonb;

alter table public.movies
  drop constraint if exists movies_media_type_check;

alter table public.movies
  add constraint movies_media_type_check
  check (media_type in ('movie','series_episode'));

alter table public.movies
  drop constraint if exists movies_season_episode_positive_check;

alter table public.movies
  add constraint movies_season_episode_positive_check
  check (
    (season_number is null or season_number > 0)
    and (episode_number is null or episode_number > 0)
  );

create index if not exists movies_media_type_created_at_idx
  on public.movies (media_type, created_at desc);

create index if not exists movies_series_season_episode_idx
  on public.movies (series_title, season_number, episode_number);
