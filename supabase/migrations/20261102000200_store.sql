-- FlowApp: tienda, inventario, moneda virtual y recompensas.
-- Ejecuta este archivo una vez en el SQL Editor de Supabase.
-- Es idempotente: puedes volver a ejecutarlo sin duplicar datos.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- 1. Catálogo de la tienda
-- ---------------------------------------------------------------------------
create table if not exists public.store_items (
  code text primary key,
  category text not null check (category in ('skin', 'title', 'diagram', 'consumable')),
  name text not null,
  description text,
  price integer not null default 0 check (price >= 0),
  rarity text not null default 'common'
    check (rarity in ('common', 'rare', 'epic', 'legendary')),
  payload jsonb not null default '{}'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.store_items
  (code, category, name, description, price, rarity, payload, sort_order)
values
  (
    'skin_classic', 'skin', 'Clásico',
    'El estilo original de Flow: nodos redondeados y acentos cian.',
    0, 'common',
    '{"background":"#0D1A2A","grid":"#2B4A63","nodeFill":"#14283C","nodeBorder":"#38BDF8","text":"#EDFBFF","accent":"#38BDF8","nodeRadius":6,"borderWidth":1.2,"glow":false}',
    1
  ),
  (
    'skin_pixel', 'skin', 'Pixel Art',
    'Nodos cuadrados, líneas firmes y una paleta retro.',
    120, 'rare',
    '{"background":"#101827","grid":"#334155","nodeFill":"#1E293B","nodeBorder":"#FBBF24","text":"#F8FAFC","accent":"#FBBF24","nodeRadius":2,"borderWidth":2,"glow":false}',
    2
  ),
  (
    'skin_cyber', 'skin', 'Cyber',
    'Bordes neón y brillo futurista para tus diagramas.',
    200, 'epic',
    '{"background":"#0A0F1E","grid":"#1E3A5F","nodeFill":"#101A2E","nodeBorder":"#22D3EE","text":"#ECFEFF","accent":"#22D3EE","nodeRadius":4,"borderWidth":1.6,"glow":true}',
    3
  ),
  (
    'skin_neon', 'skin', 'Neón',
    'Una explosión de magenta y verde sobre fondo profundo.',
    260, 'epic',
    '{"background":"#0B1020","grid":"#3B1D5E","nodeFill":"#1B1035","nodeBorder":"#F472B6","text":"#FDF2F8","accent":"#4ADE80","nodeRadius":8,"borderWidth":1.8,"glow":true}',
    4
  ),
  (
    'skin_forest', 'skin', 'Bosque',
    'Tonos verdes y tierra para un flujo tranquilo.',
    180, 'rare',
    '{"background":"#0D1A15","grid":"#2F4F3E","nodeFill":"#14291F","nodeBorder":"#4ADE80","text":"#ECFDF5","accent":"#86EFAC","nodeRadius":7,"borderWidth":1.4,"glow":false}',
    5
  ),
  (
    'skin_minimal', 'skin', 'Minimal',
    'Menos color, más claridad. Ideal para diagramas densos.',
    150, 'rare',
    '{"background":"#111827","grid":"#374151","nodeFill":"#1F2937","nodeBorder":"#9CA3AF","text":"#F9FAFB","accent":"#E5E7EB","nodeRadius":5,"borderWidth":1,"glow":false}',
    6
  ),
  (
    'title_novice', 'title', 'Novato',
    'El primer título de todo estudiante Flow.',
    0, 'common',
    '{"label":"Novato","color":"#B6C8D9","icon":"military_tech"}',
    10
  ),
  (
    'title_explorer', 'title', 'Explorador',
    'Para quienes ya recorren la ruta de aprendizaje.',
    80, 'common',
    '{"label":"Explorador","color":"#38BDF8","icon":"explore"}',
    11
  ),
  (
    'title_architect', 'title', 'Arquitecto del flujo',
    'Tus diagramas tienen estructura y propósito.',
    150, 'rare',
    '{"label":"Arquitecto del flujo","color":"#FBBF24","icon":"architecture"}',
    12
  ),
  (
    'title_loop_master', 'title', 'Maestro de ciclos',
    'while, for y recursión no tienen secretos para ti.',
    220, 'epic',
    '{"label":"Maestro de ciclos","color":"#A78BFA","icon":"loop"}',
    13
  ),
  (
    'title_flow_legend', 'title', 'Leyenda Flow',
    'Un título reservado para los grandes del pensamiento lógico.',
    400, 'legendary',
    '{"label":"Leyenda Flow","color":"#F472B6","icon":"auto_awesome"}',
    14
  ),
  (
    'template_age', 'diagram', 'Validar edad',
    'Plantilla con decisión para comprobar si alguien es mayor de edad.',
    90, 'common',
    '{"title":"Validar edad","kind":"decision","start_label":"Inicio","process_label":"Leer edad","decision_label":"¿Es mayor de edad?","yes_label":"Sí","no_label":"No","end_label":"Fin"}',
    20
  ),
  (
    'template_even_odd', 'diagram', 'Clasificar número',
    'Plantilla con decisión para distinguir números pares e impares.',
    110, 'rare',
    '{"title":"Clasificar número","kind":"decision","start_label":"Inicio","process_label":"Leer número","decision_label":"¿Es par?","yes_label":"Sí","no_label":"No","end_label":"Fin"}',
    21
  ),
  (
    'template_traffic_light', 'diagram', 'Semáforo inteligente',
    'Plantilla para practicar condiciones con un semáforo.',
    140, 'epic',
    '{"title":"Semáforo inteligente","kind":"decision","start_label":"Inicio","process_label":"Leer luz","decision_label":"¿Luz roja?","yes_label":"Detener","no_label":"Avanzar","end_label":"Fin"}',
    22
  ),
  (
    'template_sum', 'diagram', 'Suma hasta N',
    'Plantilla lineal para practicar acumuladores y ciclos.',
    160, 'epic',
    '{"title":"Suma hasta N","kind":"linear","start_label":"Inicio","process_label":"Sumar hasta N","decision_label":"Es > 0","yes_label":"Sí","no_label":"No","end_label":"Fin"}',
    23
  ),
  (
    'consumable_streak_freeze', 'consumable', 'Congelar racha',
    'Protege tu racha durante un día sin actividad.',
    60, 'rare',
    '{"effect":"streak_freeze","amount":1}',
    30
  ),
  (
    'consumable_xp_boost', 'consumable', 'XP x2 durante 24 h',
    'Duplica el XP que ganes en tus próximas lecciones.',
    100, 'epic',
    '{"effect":"xp_boost","multiplier":2,"hours":24}',
    31
  )
on conflict (code) do update set
  category = excluded.category,
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  rarity = excluded.rarity,
  payload = excluded.payload,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- ---------------------------------------------------------------------------
-- 2. Moneda virtual y equipamiento en el perfil
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists coins integer not null default 240 check (coins >= 0);

alter table public.profiles
  add column if not exists equipped_skin_code text,
  add column if not exists equipped_title_code text,
  add column if not exists streak_freezes integer not null default 0,
  add column if not exists xp_boost_until timestamptz,
  add column if not exists last_daily_reward_at timestamptz;

alter table public.profiles
  alter column equipped_skin_code set default 'skin_classic';
alter table public.profiles
  alter column equipped_title_code set default 'title_novice';

update public.profiles
set equipped_skin_code = 'skin_classic'
where equipped_skin_code is null;

update public.profiles
set equipped_title_code = 'title_novice'
where equipped_title_code is null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_equipped_skin_code_fkey'
  ) then
    alter table public.profiles
      add constraint profiles_equipped_skin_code_fkey
      foreign key (equipped_skin_code)
      references public.store_items (code)
      on delete set null;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_equipped_title_code_fkey'
  ) then
    alter table public.profiles
      add constraint profiles_equipped_title_code_fkey
      foreign key (equipped_title_code)
      references public.store_items (code)
      on delete set null;
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- 3. Inventario y compras
-- ---------------------------------------------------------------------------
create table if not exists public.user_inventory (
  user_id uuid not null references public.profiles (id) on delete cascade,
  item_code text not null references public.store_items (code) on delete cascade,
  quantity integer not null default 1 check (quantity > 0),
  acquired_at timestamptz not null default now(),
  primary key (user_id, item_code)
);

create table if not exists public.store_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  item_code text not null references public.store_items (code) on delete restrict,
  price_paid integer not null check (price_paid >= 0),
  created_at timestamptz not null default now()
);

create index if not exists store_purchases_user_created_idx
  on public.store_purchases (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 4. Recompensas de lecciones
-- ---------------------------------------------------------------------------
create table if not exists public.lesson_rewards (
  lesson_id text primary key,
  coins integer not null default 0 check (coins >= 0),
  xp integer not null default 0 check (xp >= 0)
);

insert into public.lesson_rewards (lesson_id, coins, xp)
values ('unit-1-lesson-3', 25, 50)
on conflict (lesson_id) do update set
  coins = excluded.coins,
  xp = excluded.xp;

create table if not exists public.lesson_completions (
  user_id uuid not null references public.profiles (id) on delete cascade,
  lesson_id text not null references public.lesson_rewards (lesson_id) on delete cascade,
  completed_at timestamptz not null default now(),
  primary key (user_id, lesson_id)
);

-- ---------------------------------------------------------------------------
-- 5. Ítems iniciales para cada perfil
-- ---------------------------------------------------------------------------
create or replace function public.grant_starter_store_items()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.user_inventory (user_id, item_code)
  values
    (new.id, 'skin_classic'),
    (new.id, 'title_novice')
  on conflict (user_id, item_code) do nothing;

  return new;
end;
$$;

drop trigger if exists profiles_grant_starter_items on public.profiles;
create trigger profiles_grant_starter_items
after insert on public.profiles
for each row execute function public.grant_starter_store_items();

insert into public.user_inventory (user_id, item_code)
select profile.id, starter.code
from public.profiles profile
cross join (values ('skin_classic'), ('title_novice')) as starter (code)
on conflict (user_id, item_code) do nothing;

-- ---------------------------------------------------------------------------
-- 6. Operaciones atómicas de la tienda
-- ---------------------------------------------------------------------------
create or replace function public.purchase_store_item(p_item_code text)
returns table (coins integer, item_code text, quantity integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_item public.store_items%rowtype;
  v_balance integer;
  v_quantity integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_item
  from public.store_items
  where code = p_item_code and is_active;

  if not found then
    raise exception 'item_unavailable' using errcode = 'P0001';
  end if;

  select profile.coins into v_balance
  from public.profiles profile
  where profile.id = v_user
  for update;

  if not found then
    raise exception 'profile_not_found' using errcode = 'P0001';
  end if;

  if v_item.price > v_balance then
    raise exception 'insufficient_coins' using errcode = 'P0001';
  end if;

  if v_item.category <> 'consumable' and exists (
    select 1 from public.user_inventory
    where user_id = v_user and item_code = p_item_code
  ) then
    raise exception 'already_owned' using errcode = 'P0001';
  end if;

  update public.profiles profile
  set coins = profile.coins - v_item.price
  where profile.id = v_user
  returning profile.coins into v_balance;

  insert into public.user_inventory as inventory (user_id, item_code, quantity)
  values (v_user, p_item_code, 1)
  on conflict (user_id, item_code) do update
    set quantity = inventory.quantity + 1
  returning quantity into v_quantity;

  insert into public.store_purchases (user_id, item_code, price_paid)
  values (v_user, p_item_code, v_item.price);

  return query select v_balance, p_item_code, v_quantity;
end;
$$;

create or replace function public.equip_store_item(p_item_code text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_item public.store_items%rowtype;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_item
  from public.store_items
  where code = p_item_code and is_active;

  if not found then
    raise exception 'item_unavailable' using errcode = 'P0001';
  end if;

  if v_item.category not in ('skin', 'title') then
    raise exception 'item_not_equippable' using errcode = 'P0001';
  end if;

  if not exists (
    select 1 from public.user_inventory
    where user_id = v_user and item_code = p_item_code
  ) then
    raise exception 'item_not_owned' using errcode = 'P0001';
  end if;

  if v_item.category = 'skin' then
    update public.profiles
    set equipped_skin_code = p_item_code
    where id = v_user;
  else
    update public.profiles
    set equipped_title_code = p_item_code
    where id = v_user;
  end if;
end;
$$;

create or replace function public.claim_daily_reward()
returns table (coins integer, reward integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_last timestamptz;
  v_balance integer;
  v_reward constant integer := 25;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select profile.last_daily_reward_at into v_last
  from public.profiles profile
  where profile.id = v_user
  for update;

  if not found then
    raise exception 'profile_not_found' using errcode = 'P0001';
  end if;

  if v_last is not null and v_last > now() - interval '24 hours' then
    raise exception 'reward_not_ready' using errcode = 'P0001';
  end if;

  update public.profiles profile
  set coins = profile.coins + v_reward,
      last_daily_reward_at = now()
  where profile.id = v_user
  returning profile.coins into v_balance;

  return query select v_balance, v_reward;
end;
$$;

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
  v_user uuid := auth.uid();
  v_reward public.lesson_rewards%rowtype;
  v_multiplier integer := 1;
  v_balance integer;
  v_inserted integer;
  v_xp integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_reward
  from public.lesson_rewards
  where lesson_id = p_lesson_id;

  if not found then
    raise exception 'lesson_not_found' using errcode = 'P0001';
  end if;

  insert into public.lesson_completions (user_id, lesson_id)
  values (v_user, p_lesson_id)
  on conflict (user_id, lesson_id) do nothing;

  get diagnostics v_inserted = row_count;

  if v_inserted = 0 then
    select profile.coins into v_balance
    from public.profiles profile
    where profile.id = v_user;

    return query select v_balance, 0, 0, true;
    return;
  end if;

  if exists (
    select 1 from public.profiles
    where id = v_user and xp_boost_until > now()
  ) then
    v_multiplier := 2;
  end if;

  v_xp := v_reward.xp * v_multiplier;

  update public.profiles profile
  set coins = profile.coins + v_reward.coins,
      xp = profile.xp + v_xp,
      lessons_completed = profile.lessons_completed + 1
  where profile.id = v_user
  returning profile.coins into v_balance;

  return query select v_balance, v_xp, v_reward.coins, false;
end;
$$;

create or replace function public.use_diagram_template(p_item_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_item public.store_items%rowtype;
  v_payload jsonb;
  v_diagram_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_item
  from public.store_items
  where code = p_item_code and is_active;

  if not found then
    raise exception 'item_unavailable' using errcode = 'P0001';
  end if;

  if v_item.category <> 'diagram' then
    raise exception 'item_not_a_template' using errcode = 'P0001';
  end if;

  if not exists (
    select 1 from public.user_inventory
    where user_id = v_user and item_code = p_item_code
  ) then
    raise exception 'item_not_owned' using errcode = 'P0001';
  end if;

  v_payload := v_item.payload;

  insert into public.diagrams (
    user_id,
    title,
    kind,
    start_label,
    process_label,
    decision_label,
    yes_label,
    no_label,
    end_label
  )
  values (
    v_user,
    coalesce(nullif(v_payload ->> 'title', ''), v_item.name),
    case when v_payload ->> 'kind' = 'decision' then 'decision' else 'linear' end,
    coalesce(nullif(v_payload ->> 'start_label', ''), 'Inicio'),
    coalesce(nullif(v_payload ->> 'process_label', ''), 'Mostrar mensaje'),
    coalesce(nullif(v_payload ->> 'decision_label', ''), 'Es > 0'),
    coalesce(nullif(v_payload ->> 'yes_label', ''), 'Sí'),
    coalesce(nullif(v_payload ->> 'no_label', ''), 'No'),
    coalesce(nullif(v_payload ->> 'end_label', ''), 'Fin')
  )
  returning id into v_diagram_id;

  return v_diagram_id;
end;
$$;

create or replace function public.use_consumable(p_item_code text)
returns table (effect text, remaining integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_item public.store_items%rowtype;
  v_effect text;
  v_quantity integer;
begin
  if v_user is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into v_item
  from public.store_items
  where code = p_item_code and is_active;

  if not found then
    raise exception 'item_unavailable' using errcode = 'P0001';
  end if;

  if v_item.category <> 'consumable' then
    raise exception 'item_not_consumable' using errcode = 'P0001';
  end if;

  select inventory.quantity into v_quantity
  from public.user_inventory inventory
  where inventory.user_id = v_user and inventory.item_code = p_item_code
  for update;

  if not found or v_quantity <= 0 then
    raise exception 'item_not_owned' using errcode = 'P0001';
  end if;

  v_effect := v_item.payload ->> 'effect';

  if v_effect = 'streak_freeze' then
    update public.profiles
    set streak_freezes = streak_freezes
      + coalesce((v_item.payload ->> 'amount')::integer, 1)
    where id = v_user;
  elsif v_effect = 'xp_boost' then
    update public.profiles
    set xp_boost_until = greatest(
      coalesce(xp_boost_until, now()),
      now()
    ) + make_interval(
      hours => coalesce((v_item.payload ->> 'hours')::integer, 24)
    )
    where id = v_user;
  else
    raise exception 'unknown_effect' using errcode = 'P0001';
  end if;

  if v_quantity <= 1 then
    delete from public.user_inventory
    where user_id = v_user and item_code = p_item_code;
    v_quantity := 0;
  else
    update public.user_inventory
    set quantity = quantity - 1
    where user_id = v_user and item_code = p_item_code
    returning quantity into v_quantity;
  end if;

  return query select v_effect, v_quantity;
end;
$$;

-- ---------------------------------------------------------------------------
-- 7. Row Level Security
-- ---------------------------------------------------------------------------
alter table public.store_items enable row level security;
alter table public.user_inventory enable row level security;
alter table public.store_purchases enable row level security;
alter table public.lesson_rewards enable row level security;
alter table public.lesson_completions enable row level security;

drop policy if exists "store_items_read_authenticated" on public.store_items;
create policy "store_items_read_authenticated" on public.store_items
  for select to authenticated
  using (is_active);

drop policy if exists "user_inventory_select_own" on public.user_inventory;
create policy "user_inventory_select_own" on public.user_inventory
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "store_purchases_select_own" on public.store_purchases;
create policy "store_purchases_select_own" on public.store_purchases
  for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "lesson_rewards_read_authenticated" on public.lesson_rewards;
create policy "lesson_rewards_read_authenticated" on public.lesson_rewards
  for select to authenticated
  using (true);

drop policy if exists "lesson_completions_select_own" on public.lesson_completions;
create policy "lesson_completions_select_own" on public.lesson_completions
  for select to authenticated
  using (auth.uid() = user_id);

grant select on public.store_items to authenticated;
grant select on public.user_inventory to authenticated;
grant select on public.store_purchases to authenticated;
grant select on public.lesson_rewards to authenticated;
grant select on public.lesson_completions to authenticated;

revoke all on function public.purchase_store_item(text) from public;
revoke all on function public.equip_store_item(text) from public;
revoke all on function public.claim_daily_reward() from public;
revoke all on function public.claim_lesson_reward(text) from public;
revoke all on function public.use_diagram_template(text) from public;
revoke all on function public.use_consumable(text) from public;

grant execute on function public.purchase_store_item(text) to authenticated;
grant execute on function public.equip_store_item(text) to authenticated;
grant execute on function public.claim_daily_reward() to authenticated;
grant execute on function public.claim_lesson_reward(text) to authenticated;
grant execute on function public.use_diagram_template(text) to authenticated;
grant execute on function public.use_consumable(text) to authenticated;
