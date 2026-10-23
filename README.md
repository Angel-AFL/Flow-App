# FlowApp

> Aprende a pensar paso a paso.

**Estado:** En desarrollo · **Stack:** Flutter + Dart · **Última etapa:** Mocks estáticos de todas las pantallas

## Descripción

FlowApp es una aplicación diseñada para ayudar a estudiantes de programación a mejorar el desarrollo del pensamiento lógico y crítico, así como la lógica de programación para la resolución de problemas en entornos reales.

También impulsa el desarrollo de habilidades técnicas para el desarrollo de software, conociendo desde las bases de los diagramas de flujo hasta el primer acercamiento a los fundamentos de programación. La experiencia se complementa con módulos sociales y de logros personales, haciendo del aprendizaje una travesía compartida: alcanzar metas propias y competir con una comunidad activa en continuo aprendizaje.

## Alcances

### Aprendizaje

- **Árbol de habilidades:** los usuarios avanzan por un mapa de niveles. Comienzan con diagramas lineales, luego condicionales (`if/else`), ciclos (`while/for`), funciones y recursividad.
- **Mecánica de juego:** en lugar de escribir código, el usuario se enfrenta a un lienzo. El reto consiste en arrastrar y soltar bloques lógicos para resolver un problema.

### Progreso y competencia

- **Rachas y ligas:** mantener la racha diaria resolviendo al menos un diagrama corto. Ligas semanales basadas en la cantidad de problemas lógicos resueltos sin errores.
- **Logros y emblemas técnicos:** logros específicos, por ejemplo "Código Limpio" (resolver el puzzle X usando el mínimo de bloques posibles).

### Comunidad

- **Feed de "Ejecuciones" (Reels/Stories):** cuando un usuario resuelve un diagrama de forma elegante o creativa, puede publicarlo en su feed. La publicación no es una imagen estática, sino una animación visual que muestra cómo viaja el flujo de datos a través de los nodos hasta llegar al resultado.
- **Mecánica de "Fork" (Compartir/Remix):** si un usuario ve un diagrama interesante en el feed de otro, puede darle "Like", comentar o hacer un Fork para llevarlo a su propio editor e intentar optimizarlo usando menos bloques.
- **Workshop (contenido generado por usuarios):** al alcanzar cierto nivel, los usuarios desbloquean el "Creador de Niveles". Pueden diseñar sus propios problemas lógicos, establecer las reglas de validación y publicarlos en la tienda.
- **Reseñas:** los niveles de la comunidad cuentan con un sistema de reseñas estilo Steam. Los mejores puzzles aparecen en la página principal.

### Perfil y personalización

- **Perfiles estéticos:** el perfil muestra el rango, los diagramas más populares y un "Heatmap" de actividad, similar a GitHub pero con una interfaz visual de red social.
- **Inventario y customización:** al completar retos o subir de nivel, los usuarios ganan una moneda virtual. Esta moneda se usa para comprar "Skins" para sus diagramas de flujo (nodos estilo Cyberpunk, Pixel Art o temas oscuros), que luego lucirán en sus publicaciones del feed.

## Bocetos de la aplicación

La carpeta [`/docs`](docs/) contiene todos los bocetos de alta fidelidad de la aplicación. Cada imagen representa una pantalla o flujo del producto.

| Pantalla | Boceto | Descripción | Estado |
| --- | --- | --- | --- |
| Onboarding | <img src="docs/login.png" width="180" alt="Pantalla de bienvenida de FlowApp"> | Pantalla de bienvenida con el logo, una muestra de diagrama de flujo y los accesos para comenzar o iniciar sesión. | **Mock estático** |
| Inicio | <img src="docs/inicio.png" width="180" alt="Pantalla de inicio de FlowApp"> | Dashboard con saludo, racha, monedas, ruta actual, progreso semanal, misión recomendada y meta diaria. | **Mock estático** |
| Aprender | <img src="docs/aprender-1.png" width="180" alt="Ruta de aprendizaje de FlowApp"> | Ruta de aprendizaje por unidades: diagramas lineales, condicionales, ciclos, funciones y recursividad. | **Mock estático** |
| Aprender (detalle) | <img src="docs/aprender-2.png" width="180" alt="Detalle de la ruta de aprendizaje"> | Vista extendida de la ruta con lecciones completadas, lección actual y unidades bloqueadas. | **Mock estático** |
| Comunidad | <img src="docs/comunidad-1.png" width="180" alt="Feed de la comunidad"> | Feed con pestañas "Para ti", "Siguiendo" y "Workshop", reto semanal y publicaciones con diagramas. | **Mock estático** |
| Comunidad (detalle) | <img src="docs/comunidad-2.png" width="180" alt="Detalle del feed de la comunidad"> | Vista completa del feed con likes, comentarios y acción de Remix sobre los diagramas publicados. | **Mock estático** |
| Perfil | <img src="docs/perfil-1.png" width="180" alt="Perfil del usuario"> | Perfil con nivel, estadísticas, logros desbloqueados, heatmap de actividad y diagramas propios. | **Mock estático** |
| Perfil (detalle) | <img src="docs/perfil-2.png" width="180" alt="Detalle del perfil del usuario"> | Vista extendida del perfil con la sección de logros, actividad y "Mis diagramas". | **Mock estático** |
| Tienda | <img src="docs/tienda.png" width="180" alt="Tienda de skins"> | Tienda con saldo de monedas y skins disponibles: Clásico, Pixel Art y Cyber. | **Mock estático** |

## Módulos implementados

El repositorio ya cuenta con la estructura base de la aplicación, el tema visual y la primera pantalla del producto, construida como mock estático.

| Módulo | Estado | Notas |
| --- | --- | --- |
| Proyecto Flutter multiplataforma | Implementado | Soporte para Android, iOS, Web, Windows, macOS y Linux. |
| Tema visual base | Implementado | Paleta extraída de los bocetos de [`/docs`](docs/) y estilos de texto centralizados. |
| Shell de navegación | Implementado (mock) | Barra inferior con las pestañas Inicio, Aprender, Comunidad, Tienda y Perfil; todas muestran su pantalla correspondiente. |
| Pantalla Bienvenida | Implementado (mock) | Logo, diagrama decorativo, titular, accesos “Comenzar” y “Ya tengo una cuenta”, y feedback para el cambio de tema. |
| Pantalla Inicio | Implementado (mock) | Saludo, racha, monedas, ruta actual, progreso semanal, misión recomendada y meta diaria con datos estáticos. |
| Pantalla Aprender | Implementado (mock) | Resumen de unidad, progreso y ruta con lecciones completadas, actuales y unidades bloqueadas. |
| Pantalla Comunidad | Implementado (mock) | Feed con pestañas, reto semanal, publicaciones con diagramas, likes locales y feedback para comentarios, Remix y menú de publicación. |
| Pantalla Tienda | Implementado (mock) | Saldo de monedas y skins Clásico, Pixel Art y Cyber con precios estáticos. |
| Pantalla Perfil | Implementado (mock) | Nivel y XP, estadísticas, logros, heatmap de actividad, “Mis diagramas” y cierre de sesión mock. |
| Módulos funcionales de FlowApp | Pendiente | Sin lógica de negocio, persistencia ni backend todavía. |

> **Nota:** las pantallas de la carpeta [`/docs`](docs/) son diseños y bocetos de referencia. Todas las pantallas documentadas replican sus bocetos con datos estáticos; la lógica de negocio, la persistencia y la autenticación real siguen pendientes.

### Detalle de la implementación actual

- **Tema:** colores y estilos centralizados en [`lib/core/theme/`](lib/core/theme/), con paleta oscura, verde neón y azul cian extraídos de los bocetos.
- **Bienvenida:** pantalla inicial en [`lib/features/welcome/`](lib/features/welcome/) con el diagrama decorativo, los accesos al shell y feedback para el cambio de tema. El botón “Cerrar sesión” del Perfil vuelve a esta pantalla.
- **Inicio:** composición responsive en [`lib/features/home/home_screen.dart`](lib/features/home/home_screen.dart), con ancho máximo de 480 px en pantallas grandes y desplazamiento vertical en pantallas pequeñas.
- **Widgets compartidos:** fondo, logo, wordmark, encabezados de sección, tarjetas de estadísticas y previsualización de diagramas en [`lib/shared/`](lib/shared/).
- **Aprender:** resumen de unidad y ruta de lecciones en [`lib/features/learn/`](lib/features/learn/), con conectores y estados de lección completada, actual y bloqueada.
- **Comunidad:** feed en [`lib/features/community/community_screen.dart`](lib/features/community/community_screen.dart), con datos mock por pestaña, banner de workshop, publicaciones y previsualizaciones de diagramas en [`lib/features/community/widgets/`](lib/features/community/widgets/). Los likes se actualizan localmente y las acciones pendientes muestran un `SnackBar`.
- **Tienda:** saldo y catálogo de skins en [`lib/features/store/`](lib/features/store/), con precios estáticos y la skin Clásico equipada.
- **Perfil:** datos mock en [`lib/features/profile/`](lib/features/profile/), con avatar, nivel y XP, estadísticas, logros, heatmap de actividad, diagramas propios y cierre de sesión.
- **Navegación:** la aplicación inicia en Bienvenida; el shell con `IndexedStack` y la barra inferior de cinco pestañas están en [`lib/core/navigation/app_shell.dart`](lib/core/navigation/app_shell.dart) y [`lib/shared/widgets/flow_bottom_nav.dart`](lib/shared/widgets/flow_bottom_nav.dart).
- **Datos:** todos los valores (`7`, `240`, `38%`, `1,250 XP`, `2/3`, `48 likes`, `3 de 12`, etc.) son constantes locales; no hay persistencia ni backend.
- **Dependencias:** no se agregaron paquetes externos; solo se usa Flutter y `flutter_test`.

## Pendientes por hacer

### Diseño y documentación

- [x] Definir la identidad visual de la aplicación.
- [x] Documentar los bocetos de las pantallas en `/docs`.
- [x] Crear la estructura base del proyecto Flutter.
- [ ] Validar los bocetos con usuarios y ajustar el diseño.

### Autenticación y onboarding

- [x] Implementar la pantalla de bienvenida (mock estático).
- [ ] Implementar el registro de usuarios.
- [ ] Implementar el inicio y cierre de sesión.
- [ ] Implementar la recuperación de contraseña.

### Navegación y pantallas principales

- [x] Configurar la navegación principal con barra inferior.
- [x] Implementar la pantalla de Inicio como mock estático.
- [x] Implementar la pantalla de Aprender (mock estático).
- [x] Implementar la pantalla de Comunidad (mock estático).
- [x] Implementar la pantalla de Tienda (mock estático).
- [x] Implementar la pantalla de Perfil (mock estático).

### Ruta de aprendizaje

- [ ] Modelar unidades, lecciones y niveles.
- [ ] Implementar el mapa de progreso y el desbloqueo de unidades.
- [ ] Implementar el sistema de XP.
- [ ] Implementar rachas diarias.
- [ ] Implementar ligas semanales.
- [ ] Implementar logros y emblemas.

### Editor y motor de diagramas

- [ ] Implementar el lienzo de arrastrar y soltar bloques.
- [ ] Implementar los bloques lógicos básicos: inicio, proceso, decisión, entrada/salida y fin.
- [ ] Implementar el motor de ejecución y validación de diagramas.
- [ ] Implementar la animación del flujo de datos.
- [ ] Implementar la optimización por cantidad mínima de bloques.

### Comunidad

- [x] Implementar el feed de ejecuciones (mock local).
- [x] Implementar likes locales en el feed (sin persistencia).
- [ ] Implementar comentarios y la acción de Remix/Fork.
- [ ] Implementar el Workshop y el creador de niveles.
- [ ] Implementar el sistema de reseñas de niveles.
- [ ] Implementar los perfiles públicos.
- [x] Implementar el heatmap de actividad en el Perfil (mock estático).

### Tienda e inventario

- [ ] Implementar el saldo de moneda virtual.
- [ ] Implementar la compra y equipamiento de skins.
- [ ] Implementar los estilos Clásico, Pixel Art y Cyber.
- [ ] Implementar el inventario de objetos del usuario.

### Infraestructura

- [ ] Definir e implementar el backend y la API.
- [ ] Implementar la persistencia de datos.
- [x] Implementar pruebas de widgets para Bienvenida, Inicio, Aprender, Comunidad, Tienda y Perfil.
- [ ] Implementar pruebas unitarias de la lógica de negocio.
- [ ] Configurar integración continua y despliegue.

## Stack y estructura

- **Framework:** Flutter
- **Lenguaje:** Dart
- **Pruebas:** `flutter_test`

```text
flow_app/
├── docs/          # Bocetos de las pantallas
├── lib/
│   ├── core/
│   │   ├── navigation/   # Shell de navegación
│   │   └── theme/        # Colores y tema
│   ├── features/
│   │   ├── welcome/      # Pantalla de bienvenida y diagrama
│   │   ├── home/         # Pantalla Inicio y widgets
│   │   ├── learn/        # Pantalla Aprender y ruta de lecciones
│   │   ├── community/    # Pantalla Comunidad, modelos y widgets
│   │   ├── store/        # Pantalla Tienda y skins
│   │   └── profile/      # Pantalla Perfil, datos y widgets
│   ├── shared/
│   │   ├── models/       # Modelos compartidos de diagramas
│   │   └── widgets/      # Fondo, logo, barra inferior y componentes
│   ├── app.dart          # Configuración de la aplicación
│   └── main.dart         # Punto de entrada
├── test/          # Pruebas
├── android/       # Proyecto Android
├── ios/           # Proyecto iOS
├── web/           # Proyecto Web
├── windows/       # Proyecto Windows
├── macos/         # Proyecto macOS
├── linux/         # Proyecto Linux
├── pubspec.yaml   # Dependencias y configuración
└── README.md
```

### Ejecución

```bash
flutter pub get
flutter run
```

### Pruebas y análisis

```bash
flutter analyze
flutter test
```

Las pruebas actuales cubren la bienvenida y su navegación (`welcome_screen_test.dart`), el contenido estático de Inicio y Perfil, el feed y las pestañas de Comunidad, el like local, el feedback de Remix y de la galería, Aprender, Tienda, el cierre de sesión y la ausencia de desbordamientos en pantallas pequeñas. En total son 20 pruebas de widgets.

## Estado del proyecto

FlowApp se encuentra en fase de diseño y estructuración. Los bocetos de la experiencia están definidos en [`/docs`](docs/), el tema visual y el shell de navegación están configurados, y todas las pantallas documentadas ya están implementadas como mocks estáticos: Bienvenida, Inicio, Aprender, Comunidad, Tienda y Perfil. Actualmente `flutter analyze` no reporta problemas y las 20 pruebas de widgets pasan. La lógica de negocio, la persistencia, el backend y la autenticación real están pendientes.
