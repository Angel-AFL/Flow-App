-- FlowApp: contenido de las unidades 2, 3, 4 y 5.
-- Ejecuta este archivo después de 20261102000300_learning.sql.
-- Es idempotente: se puede ejecutar más de una vez sin duplicar datos.

begin;

-- ---------------------------------------------------------------------------
-- 1. Recompensas (primero, por la FK de lessons -> lesson_rewards)
-- ---------------------------------------------------------------------------
insert into public.lesson_rewards (lesson_id, coins, xp)
values
  ('unit-2-lesson-1', 25, 50),
  ('unit-2-lesson-2', 25, 50),
  ('unit-2-lesson-3', 25, 50),
  ('unit-2-lesson-4', 25, 50),
  ('unit-3-lesson-1', 25, 50),
  ('unit-3-lesson-2', 25, 50),
  ('unit-3-lesson-3', 25, 50),
  ('unit-3-lesson-4', 25, 50),
  ('unit-4-lesson-1', 25, 50),
  ('unit-4-lesson-2', 25, 50),
  ('unit-4-lesson-3', 25, 50),
  ('unit-4-lesson-4', 25, 50),
  ('unit-5-lesson-1', 25, 50),
  ('unit-5-lesson-2', 25, 50),
  ('unit-5-lesson-3', 25, 50),
  ('unit-5-lesson-4', 25, 50)
on conflict (lesson_id) do update set
  coins = excluded.coins,
  xp = excluded.xp;

-- ---------------------------------------------------------------------------
-- 2. Lecciones de la Unidad 2: Condicionales if/else
-- ---------------------------------------------------------------------------
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
    'unit-2-lesson-1',
    'unit-2',
    1,
    '¿Qué es una condición?',
    'Una condición es una expresión que solo puede dar verdadero o falso. Se usa para decidir qué camino sigue un flujo. Por ejemplo: edad >= 18, nota < 60 o respuesta == "sí".',
    'Elige la expresión que sea una condición válida.',
    $json${
      "exercise": "choice",
      "question": "¿Cuál de estas expresiones es una condición?",
      "options": [
        {"id": "a", "label": "edad >= 18"},
        {"id": "b", "label": "Leer edad"},
        {"id": "c", "label": "Mostrar resultado"}
      ],
      "correct": "a",
      "explanation": "edad >= 18 compara la edad con 18 y devuelve verdadero o falso. Las otras opciones son acciones."
    }$json$::jsonb,
    1,
    true
  ),
  (
    'unit-2-lesson-2',
    'unit-2',
    2,
    'El rombo de decisión',
    'El rombo representa una decisión. Recibe un flujo de entrada y tiene dos salidas: Sí (verdadero) y No (falso). La condición se escribe dentro del rombo.',
    'Ordena los bloques del camino que se ejecuta cuando la edad es mayor o igual a 18.',
    $json${
      "exercise": "order",
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "read_age", "kind": "process", "label": "Leer edad"},
        {"id": "check", "kind": "decision", "label": "¿Edad >= 18?", "yesLabel": "Sí", "noLabel": "No"},
        {"id": "show_adult", "kind": "process", "label": "Mostrar 'Mayor de edad'"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    2,
    true
  ),
  (
    'unit-2-lesson-3',
    'unit-2',
    3,
    'If / Else: elige el camino',
    'if ejecuta un bloque cuando la condición es verdadera; else ejecuta el otro bloque cuando es falsa. Solo uno de los dos caminos se ejecuta.',
    'Lee el pseudocódigo y elige la salida correcta.',
    $json${
      "exercise": "trace",
      "snippet": "edad = 20\nsi edad >= 18:\n  mostrar 'Mayor de edad'\nsi no:\n  mostrar 'Menor de edad'",
      "question": "¿Qué se muestra si edad = 20?",
      "options": [
        {"id": "a", "label": "Mayor de edad"},
        {"id": "b", "label": "Menor de edad"},
        {"id": "c", "label": "Se muestran los dos"}
      ],
      "correct": "a",
      "explanation": "20 >= 18 es verdadero, así que se ejecuta la rama del if y no la del else."
    }$json$::jsonb,
    3,
    true
  ),
  (
    'unit-2-lesson-4',
    'unit-2',
    4,
    'Condiciones compuestas',
    'Las condiciones se pueden combinar con Y (&&) y O (||). Con Y, ambas deben cumplirse; con O, basta una.',
    'Elige el resultado de la condición compuesta.',
    $json${
      "exercise": "choice",
      "question": "Si edad = 17 y tiene_permiso = verdadero, ¿qué devuelve edad >= 18 Y tiene_permiso?",
      "options": [
        {"id": "a", "label": "falso"},
        {"id": "b", "label": "verdadero"},
        {"id": "c", "label": "No se puede saber"}
      ],
      "correct": "a",
      "explanation": "Con Y ambas condiciones deben ser verdaderas. edad >= 18 es falso porque 17 no es mayor o igual a 18."
    }$json$::jsonb,
    4,
    true
  ),

-- ---------------------------------------------------------------------------
-- 3. Lecciones de la Unidad 3: Ciclos while / for
-- ---------------------------------------------------------------------------
  (
    'unit-3-lesson-1',
    'unit-3',
    1,
    '¿Por qué repetir pasos?',
    'Un ciclo repite un grupo de pasos mientras se cumpla una condición. Evita copiar el mismo bloque muchas veces y permite procesar muchos datos.',
    'Elige la ventaja principal de usar un ciclo.',
    $json${
      "exercise": "choice",
      "question": "¿Cuál es la ventaja principal de usar un ciclo?",
      "options": [
        {"id": "a", "label": "Repetir pasos sin duplicar el diagrama"},
        {"id": "b", "label": "Hacer que el programa termine más rápido siempre"},
        {"id": "c", "label": "Evitar usar condiciones"}
      ],
      "correct": "a",
      "explanation": "El ciclo repite el mismo conjunto de pasos; la condición decide cuándo detenerse."
    }$json$::jsonb,
    1,
    true
  ),
  (
    'unit-3-lesson-2',
    'unit-3',
    2,
    'Ciclo while',
    'while revisa la condición antes de cada repetición. Si es verdadera, ejecuta el cuerpo y vuelve a revisar; si es falsa, sale del ciclo.',
    'Ordena los pasos para mostrar los números del 1 al 3. Después del incremento, el flujo vuelve a la condición.',
    $json${
      "exercise": "order",
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "init", "kind": "process", "label": "i = 1"},
        {"id": "check", "kind": "decision", "label": "¿i <= 3?", "yesLabel": "Sí", "noLabel": "No"},
        {"id": "show", "kind": "process", "label": "Mostrar i"},
        {"id": "increment", "kind": "process", "label": "i = i + 1"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    2,
    true
  ),
  (
    'unit-3-lesson-3',
    'unit-3',
    3,
    'Ciclo for',
    'for agrupa la inicialización, la condición y el incremento. Es ideal cuando sabes cuántas veces repetir.',
    'Ordena los pasos del ciclo for para mostrar los números del 1 al 5.',
    $json${
      "exercise": "order",
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "init", "kind": "process", "label": "i = 1"},
        {"id": "check", "kind": "decision", "label": "¿i <= 5?", "yesLabel": "Sí", "noLabel": "No"},
        {"id": "show", "kind": "process", "label": "Mostrar i"},
        {"id": "increment", "kind": "process", "label": "i = i + 1"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    3,
    true
  ),
  (
    'unit-3-lesson-4',
    'unit-3',
    4,
    'Contador y acumulador',
    'Un contador suma 1 en cada vuelta (i = i + 1). Un acumulador guarda una suma (suma = suma + i).',
    'Lee el pseudocódigo y elige el valor que se muestra.',
    $json${
      "exercise": "trace",
      "snippet": "suma = 0\npara i = 1 hasta 4:\n  suma = suma + i\nmostrar suma",
      "question": "¿Qué valor se muestra?",
      "options": [
        {"id": "a", "label": "10"},
        {"id": "b", "label": "4"},
        {"id": "c", "label": "5"}
      ],
      "correct": "a",
      "explanation": "1 + 2 + 3 + 4 = 10. El acumulador guarda la suma de cada vuelta."
    }$json$::jsonb,
    4,
    true
  ),

-- ---------------------------------------------------------------------------
-- 4. Lecciones de la Unidad 4: Funciones
-- ---------------------------------------------------------------------------
  (
    'unit-4-lesson-1',
    'unit-4',
    1,
    '¿Qué es una función?',
    'Una función es un grupo de pasos con un nombre que puedes reutilizar. Puede recibir datos (parámetros) y devolver un resultado.',
    'Elige para qué sirve una función.',
    $json${
      "exercise": "choice",
      "question": "¿Para qué sirve una función?",
      "options": [
        {"id": "a", "label": "Reutilizar un conjunto de pasos"},
        {"id": "b", "label": "Repetir el diagrama para siempre"},
        {"id": "c", "label": "Guardar monedas en el perfil"}
      ],
      "correct": "a",
      "explanation": "Al nombrar y agrupar pasos, puedes llamarlos varias veces sin volver a dibujarlos."
    }$json$::jsonb,
    1,
    true
  ),
  (
    'unit-4-lesson-2',
    'unit-4',
    2,
    'Parámetros y valor de retorno',
    'Los parámetros son los datos que recibe una función. El valor de retorno es el resultado que devuelve.',
    'Lee el pseudocódigo y elige el resultado.',
    $json${
      "exercise": "trace",
      "snippet": "función doble(n):\n  devolver n * 2\n\nresultado = doble(5)\nmostrar resultado",
      "question": "¿Qué se muestra?",
      "options": [
        {"id": "a", "label": "10"},
        {"id": "b", "label": "5"},
        {"id": "c", "label": "2"}
      ],
      "correct": "a",
      "explanation": "doble(5) recibe 5 como parámetro y devuelve 5 * 2 = 10."
    }$json$::jsonb,
    2,
    true
  ),
  (
    'unit-4-lesson-3',
    'unit-4',
    3,
    'Llamar una función',
    'Para usar una función se escribe su nombre con los argumentos entre paréntesis. El flujo principal continúa con el valor que devuelve.',
    'Ordena el flujo que lee un número, llama a doble y muestra el resultado.',
    $json${
      "exercise": "order",
      "blocks": [
        {"id": "start", "kind": "start", "label": "Inicio"},
        {"id": "read", "kind": "process", "label": "Leer número"},
        {"id": "call", "kind": "process", "label": "Llamar doble(número)"},
        {"id": "show", "kind": "process", "label": "Mostrar resultado"},
        {"id": "end", "kind": "end", "label": "Fin"}
      ]
    }$json$::jsonb,
    3,
    true
  ),
  (
    'unit-4-lesson-4',
    'unit-4',
    4,
    'Reutilizar una función',
    'Puedes llamar la misma función varias veces. Cada llamada usa sus propios argumentos y devuelve su propio resultado.',
    'Lee el pseudocódigo y elige el valor que se muestra.',
    $json${
      "exercise": "trace",
      "snippet": "función doble(n):\n  devolver n * 2\n\na = doble(3)\nb = doble(4)\nmostrar a + b",
      "question": "¿Qué se muestra?",
      "options": [
        {"id": "a", "label": "14"},
        {"id": "b", "label": "7"},
        {"id": "c", "label": "12"}
      ],
      "correct": "a",
      "explanation": "doble(3) = 6 y doble(4) = 8. Luego 6 + 8 = 14."
    }$json$::jsonb,
    4,
    true
  ),

-- ---------------------------------------------------------------------------
-- 5. Lecciones de la Unidad 5: Recursividad
-- ---------------------------------------------------------------------------
  (
    'unit-5-lesson-1',
    'unit-5',
    1,
    'Caso base',
    'Una función recursiva se llama a sí misma. El caso base es la condición que detiene las llamadas y evita que se repita para siempre.',
    'Elige qué ocurre si falta el caso base.',
    $json${
      "exercise": "choice",
      "question": "¿Qué pasa si una función recursiva no tiene caso base?",
      "options": [
        {"id": "a", "label": "Se llama indefinidamente"},
        {"id": "b", "label": "Devuelve siempre 0"},
        {"id": "c", "label": "Se ejecuta más rápido"}
      ],
      "correct": "a",
      "explanation": "Sin una condición de parada, la función sigue llamándose a sí misma."
    }$json$::jsonb,
    1,
    true
  ),
  (
    'unit-5-lesson-2',
    'unit-5',
    2,
    'Llamada recursiva',
    'En cada llamada recursiva el problema debe hacerse más pequeño. Así se acerca al caso base.',
    'Lee el pseudocódigo y elige el orden de la salida.',
    $json${
      "exercise": "trace",
      "snippet": "función cuenta(n):\n  si n == 0:\n    mostrar 'Fin'\n    devolver\n  mostrar n\n  cuenta(n - 1)\n\ncuenta(3)",
      "question": "¿Qué se muestra, en orden?",
      "options": [
        {"id": "a", "label": "3, 2, 1, Fin"},
        {"id": "b", "label": "1, 2, 3, Fin"},
        {"id": "c", "label": "3, 2, 1"}
      ],
      "correct": "a",
      "explanation": "Cada llamada muestra n y luego llama con n - 1 hasta llegar a 0, donde muestra Fin."
    }$json$::jsonb,
    2,
    true
  ),
  (
    'unit-5-lesson-3',
    'unit-5',
    3,
    'Factorial paso a paso',
    'El factorial de n (n!) multiplica todos los enteros desde 1 hasta n. Por definición, 0! = 1. La recursión usa factorial(n) = n * factorial(n - 1).',
    'Lee el pseudocódigo y elige el valor que se muestra.',
    $json${
      "exercise": "trace",
      "snippet": "función factorial(n):\n  si n == 0:\n    devolver 1\n  devolver n * factorial(n - 1)\n\nmostrar factorial(4)",
      "question": "¿Qué valor se muestra?",
      "options": [
        {"id": "a", "label": "24"},
        {"id": "b", "label": "12"},
        {"id": "c", "label": "16"}
      ],
      "correct": "a",
      "explanation": "4! = 4 * 3 * 2 * 1 = 24. El caso base es factorial(0) = 1."
    }$json$::jsonb,
    3,
    true
  ),
  (
    'unit-5-lesson-4',
    'unit-5',
    4,
    'Traza de la pila',
    'Cada llamada recursiva queda pendiente hasta que la siguiente devuelve un valor. La pila guarda el orden de las llamadas y luego se resuelve de abajo hacia arriba.',
    'Elige qué llamada se resuelve primero.',
    $json${
      "exercise": "choice",
      "question": "Para factorial(3), ¿qué llamada se resuelve primero?",
      "options": [
        {"id": "a", "label": "factorial(0)"},
        {"id": "b", "label": "factorial(3)"},
        {"id": "c", "label": "factorial(2)"}
      ],
      "correct": "a",
      "explanation": "La llamada más profunda es factorial(0). Al llegar al caso base devuelve 1 y la pila empieza a resolverse de regreso."
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

-- ---------------------------------------------------------------------------
-- 6. Logros de unidad
-- ---------------------------------------------------------------------------
update public.achievements
set description = 'Completa la unidad de condicionales.'
where code = 'branching';

-- ---------------------------------------------------------------------------
-- 7. Completar lección con bloqueo entre unidades
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

  -- Tampoco se puede saltar a una unidad posterior sin completar las
  -- unidades anteriores que ya tienen lecciones activas.
  if not exists (
    select 1
    from public.lesson_completions completion
    where completion.user_id = v_user
      and completion.lesson_id = p_lesson_id
  ) and exists (
    select 1
    from public.units current_unit
    join public.units previous_unit
      on previous_unit.sort_order < current_unit.sort_order
     and previous_unit.is_active
    where current_unit.id = v_lesson.unit_id
      and exists (
        select 1
        from public.lessons previous_lesson
        where previous_lesson.unit_id = previous_unit.id
          and previous_lesson.is_active
      )
      and exists (
        select 1
        from public.lessons previous_lesson
        where previous_lesson.unit_id = previous_unit.id
          and previous_lesson.is_active
          and not exists (
            select 1
            from public.lesson_completions previous_done
            where previous_done.user_id = v_user
              and previous_done.lesson_id = previous_lesson.id
          )
      )
  ) then
    raise exception 'unit_locked' using errcode = 'P0001';
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

    -- Logro al completar todas las lecciones activas de una unidad.
    if not exists (
      select 1
      from public.lessons pending
      where pending.unit_id = v_lesson.unit_id
        and pending.is_active
        and not exists (
          select 1
          from public.lesson_completions done
          where done.user_id = v_user
            and done.lesson_id = pending.id
        )
    ) then
      if v_lesson.unit_id = 'unit-2' then
        perform public.unlock_achievement(v_user, 'branching');
      elsif v_lesson.unit_id = 'unit-3' then
        perform public.unlock_achievement(v_user, 'loop_master');
      elsif v_lesson.unit_id = 'unit-4' then
        perform public.unlock_achievement(v_user, 'function_fan');
      elsif v_lesson.unit_id = 'unit-5' then
        perform public.unlock_achievement(v_user, 'recursion');
      end if;
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

commit;
