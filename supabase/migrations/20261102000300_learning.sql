-- FlowApp: aprendizaje real y progreso persistente.
-- Ejecuta este archivo después de las migraciones de perfil y tienda.
-- Es idempotente: puedes volver a ejecutarlo sin duplicar datos.
-- El backfill recalcula nivel y lecciones completadas. Si usabas el seed de
-- demostración anterior, vuelve a ejecutar supabase/seed_demo.sql al final
-- para dejar XP, lecciones, racha y actividad coherentes.

-- ---------------------------------------------------------------------------
-- 1. Unidades
-- ---------------------------------------------------------------------------
create table if not exists public.units (
  id text primary key,
  title text not null,
  description text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.units (id, title, description, sort_order, is_active)
values
  (
    'unit-1',
    'Diagramas lineales',
    'Aprende qué es un diagrama de flujo y cómo ordenar sus pasos básicos.',
    1,
    true
  ),
  (
    'unit-2',
    'Condicionales — If / Else',
    'Toma decisiones dentro de un flujo.',
    2,
    true
  ),
  (
    'unit-3',
    'Ciclos — While / For',
    'Repite pasos mientras se cumpla una condición.',
    3,
    true
  ),
  (
    'unit-4',
    'Funciones',
    'Agrupa pasos reutilizables dentro de un proceso.',
    4,
    true
  ),
  (
    'unit-5',
    'Recursividad',
    'Resuelve problemas que se llaman a sí mismos.',
    5,
    true
  )
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- ---------------------------------------------------------------------------
-- 2. Recompensas de las lecciones (se mantiene el esquema existente)
-- ---------------------------------------------------------------------------
insert into public.lesson_rewards (lesson_id, coins, xp)
values
  ('unit-1-lesson-1', 25, 50),
  ('unit-1-lesson-2', 25, 50),
  ('unit-1-lesson-3', 25, 50),
  ('unit-1-lesson-4', 25, 50)
on conflict (lesson_id) do update set
  coins = excluded.coins,
  xp = excluded.xp;

-- ---------------------------------------------------------------------------
-- 3. Contenido de las lecciones
-- ---------------------------------------------------------------------------
create table if not exists public.lessons (
  id text primary key references public.lesson_rewards (lesson_id) on delete cascade,
  unit_id text not null references public.units (id) on delete cascade,
  number integer not null check (number > 0),
  title text not null,
  concept text not null default '',
  instructions text not null,
  content jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (unit_id, number)
);

create index if not exists lessons_unit_sort_idx
  on public.lessons (unit_id, sort_order);

insert into public.lessons (
  id,
  unit_id,
  number,
  title,
  concept,
  instructions,
  content,
  sort_order,
  is_active
)
values
  (
    'unit-1-lesson-1',
    'unit-1',
    1,
    '¿Qué es un diagrama de flujo?',
    'Un diagrama de flujo representa un proceso como una secuencia de pasos. Se lee de arriba hacia abajo y siempre empieza en Inicio y termina en Fin.',
    'Ordena los bloques para representar un saludo simple.',
    $json${
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "hello", "kind": "process", "label": "Mostrar Hola"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    1,
    true
  ),
  (
    'unit-1-lesson-2',
    'unit-1',
    2,
    'Conoce los símbolos',
    'Los óvalos representan el inicio y el fin. Los rectángulos representan procesos o acciones. En esta unidad usaremos inicio, proceso y fin.',
    'Arma el flujo para leer un nombre y mostrarlo.',
    $json${
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "read_name", "kind": "process", "label": "Leer nombre"},
        {"id": "show_name", "kind": "process", "label": "Mostrar nombre"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    2,
    true
  ),
  (
    'unit-1-lesson-3',
    'unit-1',
    3,
    'Tu primer diagrama',
    'Todo diagrama necesita un inicio, al menos un paso y un fin. Los pasos se conectan con flechas en el orden en que se ejecutan.',
    'Toca los bloques para colocarlos en el diagrama. Todo flujo empieza en Inicio y termina en Fin.',
    $json${
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "process", "kind": "process", "label": "Mostrar mensaje"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    3,
    true
  ),
  (
    'unit-1-lesson-4',
    'unit-1',
    4,
    'Una secuencia completa',
    'Los pasos se ejecutan en orden. Cada paso recibe el resultado del anterior y lo transforma.',
    'Ordena el proceso para calcular el doble de un número.',
    $json${
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "read_number", "kind": "process", "label": "Leer número"},
        {"id": "double", "kind": "process", "label": "Calcular doble"},
        {"id": "show_result", "kind": "process", "label": "Mostrar resultado"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    4,
    true
  )
on conflict (id) do update set
  unit_id = excluded.unit_id,
  number = excluded.number,
  title = excluded.title,
  concept = excluded.concept,
  instructions = excluded.instructions,
  content = excluded.content,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- Normaliza el orden por si una ejecución anterior dejó valores invertidos.
update public.units
set sort_order = case id
  when 'unit-1' then 1
  when 'unit-2' then 2
  when 'unit-3' then 3
  when 'unit-4' then 4
  when 'unit-5' then 5
  else sort_order
end
where id in ('unit-1', 'unit-2', 'unit-3', 'unit-4', 'unit-5');

update public.lessons
set sort_order = number
where unit_id = 'unit-1';

-- ---------------------------------------------------------------------------
-- 4. Última actividad y backfill de progreso
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists last_activity_date date;

update public.profiles profile
set level = floor(profile.xp / 500.0)::integer + 1,
    next_level_xp = (floor(profile.xp / 500.0)::integer + 1) * 500;

update public.profiles profile
set lessons_completed = coalesce(
  (
    select count(*)::integer
    from public.lesson_completions completion
    where completion.user_id = profile.id
  ),
  0
);

update public.profiles profile
set last_activity_date = coalesce(
  (
    select max(activity.activity_date)
    from public.daily_activity activity
    where activity.user_id = profile.id
  ),
  profile.last_activity_date
);

-- ---------------------------------------------------------------------------
-- 5. RLS y permisos de lectura
-- ---------------------------------------------------------------------------
alter table public.units enable row level security;
alter table public.lessons enable row level security;

drop policy if exists "units_read_authenticated" on public.units;
create policy "units_read_authenticated" on public.units
  for select to authenticated
  using (is_active);

drop policy if exists "lessons_read_authenticated" on public.lessons;
create policy "lessons_read_authenticated" on public.lessons
  for select to authenticated
  using (is_active);

grant select on public.units to authenticated;
grant select on public.lessons to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Logros
-- ---------------------------------------------------------------------------
create or replace function public.unlock_achievement(
  p_user_id uuid,
  p_achievement_code text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_achievements (user_id, achievement_code)
  values (p_user_id, p_achievement_code)
  on conflict (user_id, achievement_code) do nothing;
end;
$$;

revoke all on function public.unlock_achievement(uuid, text) from public;

-- ---------------------------------------------------------------------------
-- 7. Completar lección con progreso atómico
-- ---------------------------------------------------------------------------
create or replace function public.complete_lesson(
  p_lesson_id text,
  p_local_date date default null
)
returns table (
  already_completed boolean,
  xp_awarded integer,
  coins_awarded integer,
  total_xp integer,
  level integer,
  next_level_xp integer,
  lessons_completed integer,
  streak_days integer,
  coins integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_lesson public.lessons%rowtype;
  v_reward public.lesson_rewards%rowtype;
  v_profile public.profiles%rowtype;
  v_inserted integer := 0;
  v_today date;
  v_multiplier integer := 1;
  v_xp_awarded integer := 0;
  v_coins_awarded integer := 0;
  v_new_xp integer;
  v_new_level integer;
  v_new_next_level integer;
  v_new_lessons integer;
  v_new_streak integer;
  v_new_coins integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if p_local_date is null
     or abs(p_local_date - current_date) > 1 then
    v_today := current_date;
  else
    v_today := p_local_date;
  end if;

  select * into v_lesson
  from public.lessons
  where id = p_lesson_id
    and is_active;

  if not found then
    raise exception 'lesson_not_found' using errcode = 'P0001';
  end if;

  select * into v_reward
  from public.lesson_rewards
  where lesson_id = p_lesson_id;

  if not found then
    raise exception 'lesson_not_found' using errcode = 'P0001';
  end if;

  select * into v_profile
  from public.profiles
  where id = v_user
  for update;

  if not found then
    raise exception 'profile_not_found' using errcode = 'P0001';
  end if;

  -- Solo se puede hacer una lección nueva si las anteriores de la unidad
  -- ya están completadas. Los repasos siempre se permiten.
  if not exists (
    select 1
    from public.lesson_completions completion
    where completion.user_id = v_user
      and completion.lesson_id = p_lesson_id
  ) and exists (
    select 1
    from public.lessons previous
    where previous.unit_id = v_lesson.unit_id
      and previous.sort_order < v_lesson.sort_order
      and previous.is_active
      and not exists (
        select 1
        from public.lesson_completions done
        where done.user_id = v_user
          and done.lesson_id = previous.id
      )
  ) then
    raise exception 'lesson_locked' using errcode = 'P0001';
  end if;

  insert into public.lesson_completions (user_id, lesson_id)
  values (v_user, p_lesson_id)
  on conflict (user_id, lesson_id) do nothing;

  get diagnostics v_inserted = row_count;

  if v_inserted = 1 then
    if v_profile.xp_boost_until is not null
       and v_profile.xp_boost_until > now() then
      v_multiplier := 2;
    end if;

    v_xp_awarded := v_reward.xp * v_multiplier;
    v_coins_awarded := v_reward.coins;
    v_new_lessons := v_profile.lessons_completed + 1;
    v_new_xp := v_profile.xp + v_xp_awarded;
    v_new_level := floor(v_new_xp / 500.0)::integer + 1;
    v_new_next_level := v_new_level * 500;
    v_new_coins := v_profile.coins + v_coins_awarded;
  else
    v_new_lessons := v_profile.lessons_completed;
    v_new_xp := v_profile.xp;
    v_new_level := v_profile.level;
    v_new_next_level := v_profile.next_level_xp;
    v_new_coins := v_profile.coins;
  end if;

  if v_profile.last_activity_date is null then
    v_new_streak := 1;
  elsif v_profile.last_activity_date = v_today then
    v_new_streak := greatest(v_profile.streak_days, 1);
  elsif v_profile.last_activity_date = v_today - 1 then
    v_new_streak := v_profile.streak_days + 1;
  else
    v_new_streak := 1;
  end if;

  update public.profiles
  set xp = v_new_xp,
      level = v_new_level,
      next_level_xp = v_new_next_level,
      lessons_completed = v_new_lessons,
      streak_days = v_new_streak,
      last_activity_date = v_today,
      coins = v_new_coins
  where id = v_user;

  insert into public.daily_activity as activity (
    user_id,
    activity_date,
    activity_count
  )
  values (v_user, v_today, 1)
  on conflict (user_id, activity_date) do update
    set activity_count = activity.activity_count + 1;

  if v_inserted = 1 then
    if v_new_lessons >= 1 then
      perform public.unlock_achievement(v_user, 'first_step');
    end if;
    if v_new_lessons >= 10 then
      perform public.unlock_achievement(v_user, 'logic_mind');
    end if;
    if v_new_streak >= 7 then
      perform public.unlock_achievement(v_user, 'consistency');
    end if;
    if v_new_streak >= 30 then
      perform public.unlock_achievement(v_user, 'streak_30');
    end if;
  end if;

  return query
  select
    v_inserted = 0,
    v_xp_awarded,
    v_coins_awarded,
    v_new_xp,
    v_new_level,
    v_new_next_level,
    v_new_lessons,
    v_new_streak,
    v_new_coins;
end;
$$;

revoke all on function public.complete_lesson(text, date) from public;
grant execute on function public.complete_lesson(text, date) to authenticated;

-- Compatibilidad con la RPC anterior mientras se actualiza la app.
create or replace function public.claim_lesson_reward(p_lesson_id text)
returns table (
  coins integer,
  xp_awarded integer,
  coins_awarded integer,
  already_claimed boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_result record;
begin
  select * into v_result
  from public.complete_lesson(p_lesson_id, current_date)
  limit 1;

  return query
  select
    v_result.coins,
    v_result.xp_awarded,
    v_result.coins_awarded,
    v_result.already_completed;
end;
$$;

revoke all on function public.claim_lesson_reward(text) from public;
grant execute on function public.claim_lesson_reward(text) to authenticated;
