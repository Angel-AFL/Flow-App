-- FlowApp: perfil conectado a Supabase
-- Ejecuta este archivo una vez en el SQL Editor de Supabase.
-- Es idempotente: puedes volver a ejecutarlo sin duplicar datos.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- 1. Perfiles
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Estudiante Flow'
    check (char_length(display_name) between 2 and 40),
  username text not null
    check (char_length(username) between 3 and 20),
  role text not null default 'Aprendiz',
  avatar_path text,
  xp integer not null default 0 check (xp >= 0),
  level integer not null default 1 check (level >= 1),
  next_level_xp integer not null default 500 check (next_level_xp > 0),
  streak_days integer not null default 0 check (streak_days >= 0),
  lessons_completed integer not null default 0 check (lessons_completed >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists profiles_username_lower_key
  on public.profiles (lower(username));

-- ---------------------------------------------------------------------------
-- 2. Logros
-- ---------------------------------------------------------------------------
create table if not exists public.achievements (
  code text primary key,
  title text not null,
  description text,
  icon text not null default 'trophy',
  sort_order integer not null default 0
);

insert into public.achievements (code, title, description, icon, sort_order)
values
  ('first_step', 'Primer paso', 'Completa tu primer diagrama.', 'trophy', 1),
  ('logic_mind', 'Mente lógica', 'Resuelve 10 diagramas.', 'psychology', 2),
  ('consistency', 'Constancia', 'Mantén una racha de 7 días.', 'fire', 3),
  ('clean_code', 'Código limpio', 'Resuelve un puzzle con el mínimo de bloques.', 'code', 4),
  ('loop_master', 'Rey de los ciclos', 'Domina los ciclos while y for.', 'loop', 5),
  ('branching', 'Bifurcación', 'Resuelve 5 condicionales.', 'call_split', 6),
  ('function_fan', 'Funciones', 'Completa la unidad de funciones.', 'functions', 7),
  ('recursion', 'Recursión', 'Completa la unidad de recursividad.', 'autorenew', 8),
  ('community', 'Comunidad', 'Publica tu primer diagrama.', 'groups', 9),
  ('remixer', 'Remixer', 'Haz un Fork de un diagrama.', 'content_copy', 10),
  ('streak_30', 'Mes perfecto', 'Mantén una racha de 30 días.', 'calendar_month', 11),
  ('architect', 'Arquitecto', 'Publica un nivel en el Workshop.', 'architecture', 12)
on conflict (code) do update set
  title = excluded.title,
  description = excluded.description,
  icon = excluded.icon,
  sort_order = excluded.sort_order;

create table if not exists public.user_achievements (
  user_id uuid not null references public.profiles (id) on delete cascade,
  achievement_code text not null references public.achievements (code) on delete cascade,
  unlocked_at timestamptz not null default now(),
  primary key (user_id, achievement_code)
);

-- ---------------------------------------------------------------------------
-- 3. Diagramas propios
-- ---------------------------------------------------------------------------
create table if not exists public.diagrams (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  kind text not null default 'linear' check (kind in ('linear', 'decision')),
  start_label text not null default 'Inicio',
  process_label text not null default 'Mostrar mensaje',
  decision_label text not null default 'Es > 0',
  yes_label text not null default 'Sí',
  no_label text not null default 'No',
  end_label text not null default 'Fin',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists diagrams_user_created_idx
  on public.diagrams (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 4. Actividad diaria (para el heatmap)
-- ---------------------------------------------------------------------------
create table if not exists public.daily_activity (
  user_id uuid not null references public.profiles (id) on delete cascade,
  activity_date date not null,
  activity_count integer not null default 0 check (activity_count >= 0),
  primary key (user_id, activity_date)
);

create index if not exists daily_activity_user_date_idx
  on public.daily_activity (user_id, activity_date desc);

-- ---------------------------------------------------------------------------
-- 5. Triggers
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists diagrams_set_updated_at on public.diagrams;
create trigger diagrams_set_updated_at
before update on public.diagrams
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_username text;
  candidate text;
  suffix integer := 0;
begin
  base_username := regexp_replace(
    lower(split_part(coalesce(new.email, 'flowuser'), '@', 1)),
    '[^a-z0-9_]',
    '',
    'g'
  );

  if length(base_username) < 3 then
    base_username := 'flow' || substr(replace(new.id::text, '-', ''), 1, 6);
  end if;

  candidate := left(base_username, 16);
  while exists (
    select 1 from public.profiles where lower(username) = lower(candidate)
  ) loop
    suffix := suffix + 1;
    candidate := left(base_username, 16) || suffix::text;
  end loop;

  insert into public.profiles (id, display_name, username)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      initcap(base_username)
    ),
    candidate
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- Backfill para usuarios que ya existían antes de esta migración.
do $$
declare
  user_record record;
  base_username text;
  candidate text;
  suffix integer;
begin
  for user_record in
    select u.id, u.email
    from auth.users u
    where not exists (
      select 1 from public.profiles p where p.id = u.id
    )
  loop
    base_username := regexp_replace(
      lower(split_part(coalesce(user_record.email, 'flowuser'), '@', 1)),
      '[^a-z0-9_]',
      '',
      'g'
    );

    if length(base_username) < 3 then
      base_username := 'flow' || substr(replace(user_record.id::text, '-', ''), 1, 6);
    end if;

    candidate := left(base_username, 16);
    suffix := 0;
    while exists (
      select 1 from public.profiles where lower(username) = lower(candidate)
    ) loop
      suffix := suffix + 1;
      candidate := left(base_username, 16) || suffix::text;
    end loop;

    insert into public.profiles (id, display_name, username)
    values (user_record.id, initcap(base_username), candidate)
    on conflict (id) do nothing;
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- 6. Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.diagrams enable row level security;
alter table public.daily_activity enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "achievements_read_authenticated" on public.achievements;
create policy "achievements_read_authenticated" on public.achievements
  for select to authenticated
  using (true);

drop policy if exists "user_achievements_select_own" on public.user_achievements;
create policy "user_achievements_select_own" on public.user_achievements
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "diagrams_select_own" on public.diagrams;
create policy "diagrams_select_own" on public.diagrams
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "diagrams_insert_own" on public.diagrams;
create policy "diagrams_insert_own" on public.diagrams
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "diagrams_update_own" on public.diagrams;
create policy "diagrams_update_own" on public.diagrams
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "diagrams_delete_own" on public.diagrams;
create policy "diagrams_delete_own" on public.diagrams
  for delete to authenticated
  using (auth.uid() = user_id);

drop policy if exists "daily_activity_select_own" on public.daily_activity;
create policy "daily_activity_select_own" on public.daily_activity
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "daily_activity_insert_own" on public.daily_activity;
create policy "daily_activity_insert_own" on public.daily_activity
  for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "daily_activity_update_own" on public.daily_activity;
create policy "daily_activity_update_own" on public.daily_activity
  for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select on public.profiles to authenticated;
revoke update on public.profiles from authenticated;
grant update (display_name, username, avatar_path) on public.profiles
  to authenticated;
grant select on public.achievements to authenticated;
grant select on public.user_achievements to authenticated;
grant select, insert, update, delete on public.diagrams to authenticated;
grant select, insert, update on public.daily_activity to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Storage para avatares
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "avatars_public_read" on storage.objects;
create policy "avatars_public_read" on storage.objects
  for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars_insert_own" on storage.objects;
create policy "avatars_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars_update_own" on storage.objects;
create policy "avatars_update_own" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "avatars_delete_own" on storage.objects;
create policy "avatars_delete_own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
