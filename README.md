# ChapaTuRuta — App móvil (Flutter)

Cliente móvil multiplataforma del backend ASP.NET Core en `localhost:5027`. Convive con el frontend web (`Frock-frontend-main/`). Soporta **dos roles**: Pasajero y Empresa.

---

## Inicio rápido

```bash
cd Frontend/ChapaTuRuta_FlutterApp-main/frontend-mobile
flutter pub get
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:5027/api
```

| Plataforma | URL backend |
|---|---|
| Android emulador | `http://10.0.2.2:5027/api` (alias del host) |
| Dispositivo físico Android | IP local del PC: `http://192.168.x.x:5027/api` |
| Edge / Windows desktop | `http://localhost:5027/api` |

Configuración ya aplicada:
- `AndroidManifest.xml` con `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `READ_MEDIA_IMAGES` + `usesCleartextTraffic="true"` (necesario para HTTP en debug).
- `android/gradle.properties` con `kotlin.incremental=false` (evita crash en Windows cuando el proyecto y el pub cache están en discos distintos).
- `lib/core/config/api_config.dart` default a `http://10.0.2.2:5027/api`.

---

## Funcionalidades

### Autenticación
- **Login** → llama `/api/authentication/sign-in`, almacena `AuthUser {id, email, name, token, refreshToken, role}` en `SharedPreferences`.
- **Registro** con dropdown **Pasajero / Empresa**. Tras `sign-up`, el repositorio hace **sign-in automático** porque el backend solo retorna `{message}` en el endpoint de registro — sin esto, el usuario quedaba sin token ni role y caía siempre en la UI de pasajero.
- **Routing por rol** (`RoleRouterScreen`): `role == 1` → `CompanyMainScreen`, cualquier otro → `MainScreen` (Pasajero). Lógica binaria, sin Driver/Admin.

### Pasajero (`MainScreen`, 5 tabs)
| Tab | Descripción |
|---|---|
| Descubrir | Buscador de rutas |
| Colecciones | Rutas favoritas (mock por ahora) |
| Rutas | Listado de rutas disponibles |
| Alertas | Notificaciones |
| Perfil | Datos del usuario, logout |

### Empresa (`CompanyMainScreen`, 4 tabs)

| Tab | Pantalla | Endpoints |
|---|---|---|
| **Inicio** | `CompanyHomeScreen` con KPIs (paraderos, rutas) y atajo "Datos de empresa" | `GET /companies/{id}`, `GET /stops/company/{id}`, `GET /routes/company/{id}` |
| **Paraderos** | `StopsListScreen` con toggle Lista / Mapa, FAB para crear, swipe-to-refresh | `GET /stops/company/{id}` |
| **Rutas** | `CompanyRoutesListScreen` con cards (precio/duración/frecuencia) y dialog de mapa con polyline real | `GET /routes/company/{id}`, `GET /routes/{id}/geometry` |
| **Perfil** | Reusa `ProfileScreen` con logout | `/users/...` |

### Onboarding de empresa
Si un manager logueado no tiene empresa asociada, `CompanyMainScreen._bootstrap` consulta `GET /companies/user/{userId}`, si retorna 404 redirige a `CompanyOnboardingScreen` con form de creación + logo (`image_picker`). Tras crear, hace un `PUT /companies/{id}` adicional para persistir los 5 campos extras (RUC, teléfono, email, dirección, descripción) que el `POST` multipart no acepta.

### Edición de empresa (`CompanyInfoScreen`)
Form con los 9 campos del aggregate (`id`, `name`, `logoUrl`, `fkIdUser`, `ruc`, `phone`, `email`, `address`, `description`). El JSON enviado a `PUT /companies/{id}` incluye `id` y `fkIdUser` (sin ellos el backend devuelve 400 BadRequest).

### CRUD de paraderos (`features/network/stops/`)
- **Listar**: `StopsListScreen` con `RefreshIndicator`, FAB y AppBar action para alternar lista/mapa. Cards muestran foto, nombre, dirección y distrito.
- **Mapa**: `StopsMapScreen` reusa `MapWithMarkers` con Tooltip por marker.
- **Crear / editar**: `StopFormScreen` con:
  - Campos `Name`, `Address`, `Reference`, `Phone` validados.
  - **Autocomplete** de Distrito tipado a `DistrictOption {id,name,province,region}`. El service hace fan-out a `/geographic/{districts,provinces,regions}` y une por FK para construir el label `"Distrito, Provincia, Región"` manteniendo el `id: int` que requiere el backend (`FkIdDistrict`).
  - Selector de imagen (`image_picker`) que envía multipart con campo `ImageFile`.
  - `MapPicker` (Leaflet/`flutter_map`) — tap o drag para fijar `{lat, lng}` + botón "Mi ubicación" (Geolocator).
  - Auto-genera `GoogleMapsUrl = https://maps.google.com/?q={lat},{lng}`.
- **Eliminar**: AlertDialog confirmar → `DELETE /stops/{id}`.
- POST y PUT envían los campos con los nombres exactos que pide el backend (`Name`, `Phone`, `FkIdCompany`, `FkIdDistrict`, `Address`, `Reference`, `GoogleMapsUrl`, `Latitude`, `Longitude`, `ImageFile`).

### CRUD de rutas (`features/network/routes/`)
- **Listar**: `CompanyRoutesListScreen` con cards `nombre / precio / duración / frecuencia` y acciones Mapa, Editar, Eliminar.
- **Mapa**: `CompanyRouteMapScreen` carga `/routes/{id}/geometry` con decoder dual (polyline encoded, GeoJSON LineString, array `[lat,lng]`).
- **Crear / editar**: `CompanyRouteFormScreen` con:
  - Datos básicos: nombre, precio, duración (min), frecuencia (min).
  - Selección de paraderos (≥ 2) con `CheckboxListTile`.
  - **Horarios**: 7 días (Lun-Dom) con `Switch` para activar/desactivar y dos `TimePicker` (start/end). Default 06:00–22:00, Domingo desactivado. El backend exige al menos un schedule activo.
  - Preview de polyline (línea recta entre stops seleccionados) cuando hay ≥ 2.
- POST y PUT envían `{frequency, price, duration, stopsIds, schedules}` exactamente como `CreateFullRouteResource` / `UpdateRouteResource` lo definen.

### Mapa OSM (`shared/widgets/`)

| Widget | Uso |
|---|---|
| `MapView` | Wrapper de `FlutterMap` + `TileLayer` + atribución |
| `MapPicker` | Tap-to-set, marker draggable, botón "Mi ubicación" (`geolocator`) |
| `MapWithMarkers` | Lista de marcadores con tooltip + polyline opcional |

Todos consumen `tileUrl` desde `GET /api/config/map`. Si la llamada falla, fallback a `https://tile.openstreetmap.org/{z}/{x}/{y}.png` para que el mapa siga funcionando aunque el tile server local de Docker no esté arriba.

---

## Stack

| Librería | Uso |
|---|---|
| Flutter 3.35 / Dart 3 | Framework |
| `provider: ^6.1.2` | Inyección + estado reactivo (`ChangeNotifierProxyProvider` para wiring de token) |
| `http: ^1.6.0` | Cliente REST |
| `shared_preferences: ^2.2.3` | Persistencia local del JWT |
| `flutter_map: ^7.0.2` | Tiles XYZ (Leaflet equivalente) |
| `latlong2: ^0.9.1` | Tipo `LatLng` |
| `flutter_polyline_points: ^2.1.0` | Decode de polylines OSRM |
| `image_picker: ^1.1.2` | Foto de paradero / logo de empresa |
| `geolocator: ^13.0.1` | Geolocation para "Mi ubicación" |
| `intl`, `google_fonts`, `shimmer`, `cupertino_icons` | UX / formato |

---

## Estructura

```
lib/
├── core/
│   ├── config/api_config.dart              # baseUrl con --dart-define
│   ├── theme/app_theme.dart                # paleta carbón+dorado
│   └── widgets/
├── shared/
│   └── widgets/
│       ├── map_view.dart
│       ├── map_picker.dart
│       └── map_with_markers.dart
├── features/
│   ├── auth/
│   │   ├── data/{datasources,models,repositories}/
│   │   ├── domain/{entities,repositories}/
│   │   └── presentation/
│   │       ├── providers/auth_provider.dart
│   │       └── screens/{login,register}_screen.dart
│   ├── company/                             # NUEVO bounded context
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── providers/company_provider.dart
│   │       └── screens/
│   │           ├── company_home_screen.dart
│   │           ├── company_info_screen.dart
│   │           └── company_onboarding_screen.dart
│   ├── network/                             # NUEVO bounded context (gestión empresa)
│   │   ├── stops/
│   │   │   ├── data/
│   │   │   │   ├── datasources/stop_api_service.dart
│   │   │   │   └── models/{company_stop_model,district_option}.dart
│   │   │   └── presentation/
│   │   │       ├── providers/stop_provider.dart
│   │   │       ├── screens/{stops_list,stops_map,stop_form}_screen.dart
│   │   │       └── widgets/stop_card.dart
│   │   └── routes/
│   │       ├── data/
│   │       │   ├── datasources/company_route_api_service.dart
│   │       │   └── models/company_route_model.dart   # incluye RouteScheduleModel
│   │       └── presentation/
│   │           ├── providers/company_route_provider.dart
│   │           └── screens/{company_routes_list,company_route_form,company_route_map}_screen.dart
│   ├── main/presentation/screens/
│   │   ├── role_router_screen.dart          # redirige según role
│   │   ├── main_screen.dart                 # Pasajero
│   │   └── company_main_screen.dart         # Empresa (NUEVO)
│   ├── collections/, discovery/, notifications/, profile/, ratings/, routes/, trips/
│   │                                        # features de pasajero (existentes)
└── main.dart                                # MultiProvider con 5 providers
```

---

## Wiring de providers

`main.dart` registra 5 providers vía `MultiProvider`. Los services HTTP de empresa, paraderos y rutas reciben el `Bearer token` automáticamente cuando `AuthProvider` cambia, gracias a `ChangeNotifierProxyProvider<AuthProvider, T>`:

```dart
ChangeNotifierProxyProvider<AuthProvider, CompanyProvider>(
  create: (_) => CompanyProvider(repository: ...),
  update: (_, auth, prev) {
    if (auth.token != null) companyApiService.setBearerToken(auth.token!);
    return prev!;
  },
),
// ídem para StopProvider, CompanyRouteProvider, RouteProvider
```

---

## Fases entregadas

| Fase | Alcance | Estado |
|---|---|---|
| 0 | Deps, permisos, `MapView/MapPicker/MapWithMarkers`, `RoleRouterScreen`, `CompanyMainScreen` shell | ✅ |
| 1 | Onboarding de empresa con logo (multipart) + PUT secundario para campos extra | ✅ |
| 2 | Dashboard `CompanyHomeScreen` con KPIs paraderos/rutas | ✅ |
| 3 | Edición `CompanyInfoScreen` con `id` + `fkIdUser` + `logoUrl` correctos | ✅ |
| 4 | Stops CRUD móvil con MapPicker + autocomplete de distrito (id real) + foto + referencia | ✅ |
| 5 | Routes CRUD móvil con horarios (TimePicker × 7 días) + polyline real OSRM | ✅ |
| 6 | RefreshIndicator, AlertDialog confirmar borrar, SnackBars, decoder dual de geometry, sign-in tras sign-up | ✅ |

### Bugs corregidos durante la implementación

- `CompanyApiService.createCompany` enviaba `userId` (debería ser `FkIdUser`) y `logo` (debería ser `LogoFile`) → onboarding fallaba con 400.
- `CompanyModel.toUpdateJson` no incluía `id`, `fkIdUser`, `logoUrl` → PUT siempre devolvía 400.
- `getStats` invocaba `/trips/company/{id}/last-month` (no existe) → KPI fantasma de "Viajes último mes" eliminado.
- `StopApiService.createStop` mandaba campos lowercase (`companyId`, `district` string, `image`) en lugar de `FkIdCompany`, `FkIdDistrict` (int), `ImageFile`. Faltaba `Reference`.
- `getDistricts()` aplastaba los distritos a strings sin id → no se podía mapear a `FkIdDistrict`. Reemplazado por `DistrictOption` tipado con id.
- `CompanyRouteApiService.createRoute` enviaba `name/companyId/status` y `stopIds`. Faltaban `schedules`. Backend rechazaba con 500 por null deref. Modelo y form actualizados para enviar `{frequency, price, duration, stopsIds, schedules}`.
- `loadGeometry` solo decodificaba polyline encoded. Ahora detecta string / GeoJSON LineString / array.
- `MapPicker.initState` llamaba `widget.onChanged` síncronamente — sigue ahí pero los consumidores actuales no rompen porque solo asignan a una variable local.
- `route_model.fromJson` (UI pasajera) crasheaba con `Type 'int' is not a subtype of type 'String?'`. Reemplazado por parser tolerante con helpers `_parseInt/_parseDouble/_asString`.
- Sign-up retornaba `{message}` sin token → `AuthUserModel` quedaba con `role=0` y caía a Pasajero. Repository ahora hace `sign-in` automático tras `sign-up`.
- AndroidManifest necesitaba `usesCleartextTraffic="true"` para HTTP en debug.
- `kotlin.incremental=false` en `gradle.properties` evita crash de cross-drive en Windows.

---

## Troubleshooting

| Síntoma | Causa | Fix |
|---|---|---|
| Connection refused desde emulador | URL apunta a `localhost` | Usar `10.0.2.2` para emulador Android |
| `CleartextNotPermitted` | Manifest sin `usesCleartextTraffic` | Ya aplicado, verificar después de rebase |
| `Type 'int' is not a subtype of type 'String?'` | Modelo parsea numérico como String | Usar helpers `_parseInt/_parseDouble` con casts tolerantes |
| Login funciona pero datos no cargan | `Bearer token` no llega al service | Verificar `ChangeNotifierProxyProvider.update` y el `setBearerToken` |
| Te registras como Empresa pero ves UI de Pasajero | Sign-up backend no retorna `role`/`token` | Repository hace login automático tras sign-up (ya aplicado) |
| `INSTALL_FAILED_INSUFFICIENT_STORAGE` | Disco del emulador casi lleno | `adb uninstall` apps de prueba o `adb shell pm trim-caches 4G` |
| `BUILD FAILED` con stacktraces de Kotlin paths cross-drive | proyecto en F:, pub cache en C: | `kotlin.incremental=false` (ya aplicado) |
| Mapa gris en celular | Tile server local apagado | Frontend cae al tile público de OSM automáticamente |
| Distrito no se guarda | Selección sin `DistrictOption` válido | `force-selection` exige escoger de la lista |

---

## Pendientes / mejoras futuras

- `MapPicker` debería usar `MapController` para recentrar al usar "Mi ubicación".
- `MapPicker.initState` aún llama `onChanged` síncronamente — diferir con `addPostFrameCallback`.
- Edit-stop popup no integra `MapPicker` para mover la coordenada (se pueden mover con drag desde el form).
- `previewRoute` (POST `/api/routes/preview`) podría usarse en el form de ruta para mostrar la geometría real OSRM antes de guardar (hoy se muestra la línea recta entre stops).
- Si la lista de paraderos crece > 200, integrar `flutter_map_marker_cluster`.
- Manejo global de 401: interceptor que detecte expiración del JWT y haga `authProvider.logout()` automático.
- Skeletons con `shimmer` (la dep está instalada pero no se usa).
- Pantalla "Olvidé mi contraseña" — backend aún no expone endpoint.
