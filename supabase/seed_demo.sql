-- Datos de demostración opcionales para FlowApp.
-- Cambia el correo de abajo por el de tu cuenta y ejecútalo en el SQL Editor.
-- No es necesario para que el perfil funcione: solo rellena el perfil con los
-- valores del boceto (1,250 XP, nivel 8, 7 días de racha, 8 lecciones...).

do $$
declare
  target_email text := 'tu-correo@ejemplo.com';
  target_id uuid;
  day_offset integer;
  activity_count integer;
begin
  select id into target_id
  from auth.users
  where lower(email) = lower(target_email);

  if target_id is null then
    raise exception 'No existe un usuario con el correo %', target_email;
  end if;

  if not exists (select 1 from public.profiles where id = target_id) then
    insert into public.profiles (id, display_name, username)
    values (
      target_id,
      'Estudiante Flow',
      'flow_' || substr(replace(target_id::text, '-', ''), 1, 8)
    );
  end if;

  update public.profiles
  set display_name = 'Estudiante Flow',
      role = 'Aprendiz',
      xp = 1250,
      level = 8,
      next_level_xp = 1500,
      streak_days = 7,
      lessons_completed = 8
  where id = target_id;

  if not exists (
    select 1
    from public.profiles
    where lower(username) = 'flowstudent'
      and id <> target_id
  ) then
    update public.profiles set username = 'flowstudent' where id = target_id;
  end if;

  insert into public.user_achievements (user_id, achievement_code)
  values
    (target_id, 'first_step'),
    (target_id, 'logic_mind'),
    (target_id, 'consistency')
  on conflict do nothing;

  if not exists (
    select 1 from public.diagrams
    where user_id = target_id and title = 'Mi primer diagrama'
  ) then
    insert into public.diagrams (user_id, title, kind, decision_label)
    values (target_id, 'Mi primer diagrama', 'linear', 'Es > 0');
  end if;

  if not exists (
    select 1 from public.diagrams
    where user_id = target_id and title = '¿Es un número positivo?'
  ) then
    insert into public.diagrams (user_id, title, kind, decision_label)
    values (target_id, '¿Es un número positivo?', 'decision', 'Es > 0');
  end if;

  for day_offset in 0..34 loop
    activity_count := case
      when day_offset % 7 in (1, 4) then 0
      when day_offset % 5 = 0 then 1
      when day_offset % 3 = 0 then 2
      else 4
    end;

    insert into public.daily_activity (user_id, activity_date, activity_count)
    values (target_id, current_date - day_offset, activity_count)
    on conflict (user_id, activity_date) do update
      set activity_count = excluded.activity_count;
  end loop;
end;
$$;
