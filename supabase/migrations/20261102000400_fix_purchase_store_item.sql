-- FlowApp: corrige la ambigüedad de columnas en la RPC de compra.
-- La función declaraba parámetros de salida `item_code` y `quantity` que
-- chocaban con columnas de `user_inventory`. Ejecuta este archivo en el
-- SQL Editor de Supabase. Es idempotente.

create or replace function public.purchase_store_item(p_item_code text)
returns table (coins integer, item_code text, quantity integer)
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
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
  from public.store_items si
  where si.code = p_item_code and si.is_active;

  if not found then
    raise exception 'item_unavailable' using errcode = 'P0001';
  end if;

  select p.coins into v_balance
  from public.profiles p
  where p.id = v_user
  for update;

  if not found then
    raise exception 'profile_not_found' using errcode = 'P0001';
  end if;

  if v_item.price > v_balance then
    raise exception 'insufficient_coins' using errcode = 'P0001';
  end if;

  if v_item.category <> 'consumable' and exists (
    select 1 from public.user_inventory inv
    where inv.user_id = v_user and inv.item_code = p_item_code
  ) then
    raise exception 'already_owned' using errcode = 'P0001';
  end if;

  update public.profiles p
  set coins = p.coins - v_item.price
  where p.id = v_user
  returning p.coins into v_balance;

  insert into public.user_inventory as inv (user_id, item_code, quantity)
  values (v_user, p_item_code, 1)
  on conflict (user_id, item_code) do update
    set quantity = inv.quantity + 1
  returning inv.quantity into v_quantity;

  insert into public.store_purchases (user_id, item_code, price_paid)
  values (v_user, p_item_code, v_item.price);

  return query select v_balance, p_item_code, v_quantity;
end;
$$;

revoke all on function public.purchase_store_item(text) from public;
grant execute on function public.purchase_store_item(text) to authenticated;
