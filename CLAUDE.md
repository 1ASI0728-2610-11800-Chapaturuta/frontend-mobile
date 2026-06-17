# API Reference — Chapaturuta Backend

## URL Base

| Entorno | URL |
|---------|-----|
| Producción | `https://frock-backend-monolito.onrender.com` |
| Desarrollo | `http://localhost:5000` |
| Swagger UI | `{base_url}/swagger` |

---

## Autenticación

La API usa **JWT Bearer Token** con un middleware personalizado (`RequestAuthorizationMiddleware`).

### Cómo autenticarse

1. Obtener token con `POST /api/authentication/sign-in`
2. Incluir el token en todas las peticiones protegidas:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Roles

| Valor | Nombre | Descripción |
|-------|--------|-------------|
| `0` | `Traveller` | Pasajero (usuario final) |
| `2` | `Driver` | Conductor |
| `3` | `Admin` | Administrador |

### Niveles de acceso

- **Público** — sin token requerido
- **Autenticado** — cualquier rol válido con token
- **Driver / Admin** — solo conductores o administradores
- **Traveller / Admin** — solo pasajeros o administradores
- **Admin** — solo administradores

---

## Diagrama de módulos

```
┌─────────────────────────────────────────────────────────┐
│                   Chapaturuta API                        │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│   IAM    │  Driver  │  Routes  │  Stops   │  Geographic │
│ (auth +  │ (perfil  │ (rutas   │(paraderos│ (regiones,  │
│ usuarios)│ vehículo)│ y mapa)  │)         │ provincias, │
│          │          │          │          │ distritos)  │
├──────────┴──────────┴──────────┴──────────┴─────────────┤
│  Trips   │Reservations│Payments│ Ratings  │Subscriptions│
│ (viajes) │(reservas)  │(pagos) │(reseñas) │(planes)     │
├──────────┴────────────┴────────┴──────────┴─────────────┤
│Collections│Notifications│ Discovery │  Config  │ Health  │
│(favoritos)│(avisos)     │(búsqueda  │(mapa OSM)│(estado) │
│           │             │ + IA)     │          │         │
└───────────┴─────────────┴───────────┴──────────┴─────────┘
```

---

## Entidades principales

### User
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `username` | `string` | Nombre de usuario |
| `email` | `string` | Correo electrónico (usado para login) |
| `role` | `Role` enum | `Traveller=0`, `Driver=2`, `Admin=3` |

### Driver
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User |
| `firstName` | `string` | Nombres |
| `lastName` | `string` | Apellidos |
| `documentNumber` | `string` | DNI |
| `phone` | `string` | Teléfono |
| `photoUrl` | `string` | URL foto de perfil |
| `licenseNumber` | `string` | Nº de licencia |
| `licenseCategory` | `LicenseCategory` | `AIIa`, `AIIb`, `AIIIa`, `AIIIb`, `AIIIc` |
| `vehiclePlate` | `string` | Placa |
| `vehicleBrand` | `string` | Marca |
| `vehicleModel` | `string` | Modelo |
| `vehicleYear` | `int` | Año (≥ 1980) |
| `vehicleCapacity` | `int` | Capacidad de pasajeros (≥ 1) |
| `vehicleType` | `VehicleType` | `Car`, `Pickup`, `Combi`, `Van`, `Bus`, `Minivan` |
| `isAvailable` | `bool` | Disponible actualmente |
| `createdAt` | `datetime` | Fecha de registro |
| `updatedAt` | `datetime?` | Última modificación |

### Stop (Paradero)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `name` | `string` | Nombre del paradero |
| `googleMapsUrl` | `string` | URL Google Maps |
| `imageUrl` | `string` | URL imagen |
| `fkIdDriver` | `int` | FK → Driver |
| `address` | `string` | Dirección |
| `reference` | `string` | Referencia adicional |
| `fkIdDistrict` | `int` | FK → District |
| `latitude` | `double?` | Latitud |
| `longitude` | `double?` | Longitud |

### Route (Ruta)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `price` | `double` | Precio del pasaje (S/.) |
| `frequency` | `int` | Frecuencia en minutos |
| `duration` | `int` | Duración estimada en minutos |
| `isActive` | `bool` | Ruta activa |
| `status` | `string` | Estado |
| `distanceMeters` | `decimal?` | Distancia calculada por OSRM |
| `durationSeconds` | `int?` | Duración calculada por OSRM |
| `geometry` | `string?` | Polyline codificada de la ruta |
| `stops` | `array` | Lista ordenada de paraderos |
| `schedules` | `array` | Horarios de operación |

### Trip (Viaje)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User (pasajero) |
| `fkIdDriver` | `int?` | FK → Driver |
| `fkIdRoute` | `int` | FK → Route |
| `fkIdOriginStop` | `int` | FK → Stop (origen) |
| `fkIdDestinationStop` | `int` | FK → Stop (destino) |
| `startTime` | `datetime` | Inicio del viaje |
| `endTime` | `datetime?` | Fin del viaje |
| `price` | `decimal?` | Tarifa cobrada (S/.) |
| `status` | `TripStatus` | `Pending`, `InProgress`, `Completed`, `Cancelled` |
| `availableSeats` | `int` | Asientos disponibles |

### Reservation (Reserva)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User (pasajero) |
| `fkIdTrip` | `int` | FK → Trip |
| `documentType` | `DocumentType` | `Dni` |
| `documentNumber` | `string` | Nº de documento |
| `seats` | `int` | Asientos reservados |
| `status` | `ReservationStatus` | `Pending`, `Confirmed`, `Cancelled`, `Completed`, `Refunded` |
| `fkIdPayment` | `int?` | FK → Payment |
| `reservedAt` | `datetime` | Fecha de reserva |
| `confirmedAt` | `datetime?` | Fecha de confirmación |

### Payment (Pago)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User |
| `amount` | `decimal` | Monto |
| `currency` | `string` | Moneda ISO (ej. `PEN`) |
| `method` | `PaymentMethod` | `Yape`, `Plin`, `Card`, `Cash` |
| `status` | `PaymentStatus` | `Pending`, `Completed`, `Failed`, `Refunded`, `PartiallyRefunded` |
| `externalReference` | `string?` | Referencia de la pasarela |
| `referenceType` | `string` | `Reservation` o `Subscription` |
| `referenceId` | `int` | ID de la entidad referenciada |
| `createdAt` | `datetime` | Fecha de creación |
| `confirmedAt` | `datetime?` | Fecha de confirmación |

### Plan (Suscripción)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `name` | `string` | Nombre comercial |
| `planType` | `PlanType` | `Free`, `Premium` |
| `targetRole` | `TargetRole` | `Traveller`, `Driver`, `Both` |
| `price` | `decimal` | Precio |
| `currency` | `string` | Moneda ISO |
| `billingCycle` | `BillingCycle` | `Monthly`, `Yearly` |
| `benefits` | `string` | Descripción de beneficios |
| `discoveryQuota` | `int?` | Cuota mensual de consultas Discovery (`null` = ilimitado) |
| `isActive` | `bool` | Plan disponible |

### Subscription (Suscripción activa)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User |
| `fkIdPlan` | `int` | FK → Plan |
| `status` | `SubscriptionStatus` | `Active`, `Expired`, `Cancelled`, `PendingPayment` |
| `startsAt` | `datetime` | Inicio del ciclo |
| `endsAt` | `datetime` | Fin del ciclo |
| `autoRenew` | `bool` | Renovación automática |
| `fkIdPayment` | `int?` | FK → Payment |
| `discoveryUsageInCycle` | `int` | Consultas Discovery usadas en el ciclo actual |

### Rating (Calificación)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User (quién califica) |
| `fkIdDriver` | `int` | FK → Driver (calificado) |
| `fkIdTrip` | `int` | FK → Trip |
| `score` | `int` | Puntaje 1–5 |
| `comment` | `string?` | Comentario opcional |
| `createdAt` | `datetime` | Fecha |

### Collection (Colección de rutas)
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `name` | `string` | Nombre de la colección |
| `fkIdUser` | `int` | FK → User |
| `createdAt` | `datetime` | Fecha de creación |
| `itemCount` | `int` | Cantidad de rutas guardadas |

### Notification
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | `int` | Identificador único |
| `fkIdUser` | `int` | FK → User destinatario |
| `title` | `string` | Título |
| `message` | `string` | Cuerpo del mensaje |
| `type` | `string` | Tipo de notificación |
| `isRead` | `bool` | Leída |
| `createdAt` | `datetime` | Fecha |

---

## 1. Autenticación

Base path: `/api/authentication`

---

### POST /api/authentication/sign-up

Registra un nuevo usuario en el sistema.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "username": "juan123",
  "email": "juan@example.com",
  "password": "Password1",
  "role": 0
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `username` | `string` | Nombre de usuario único |
| `email` | `string` | Correo electrónico |
| `password` | `string` | Mínimo 8 caracteres, mayúscula y número |
| `role` | `int` | `0`=Traveller, `2`=Driver, `3`=Admin |

**Response 200 OK:**

```json
{ "message": "User created successfully" }
```

| Código | Descripción |
|--------|-------------|
| 200 | Usuario creado |
| 400 | Datos inválidos o email ya registrado |

---

### POST /api/authentication/sign-in

Autentica un usuario y devuelve un JWT.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "email": "juan@example.com",
  "password": "Password1"
}
```

**Response 200 OK:**

```json
{
  "id": 1,
  "username": "juan123",
  "role": "Traveller",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Autenticación exitosa |
| 400 | Credenciales incorrectas |

---

## 2. Usuarios

Base path: `/api/users`  
**Requiere token** en todos los endpoints (clase con `[Authorize]`).

---

### GET /api/users/{id}

Obtiene un usuario por ID.

- **Rol requerido:** Autenticado
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | `int` | ID del usuario |

**Response 200 OK:**

```json
{
  "id": 1,
  "username": "juan123",
  "role": "Traveller"
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Usuario encontrado |
| 401 | Token faltante o inválido |
| 404 | Usuario no encontrado |

---

### GET /api/users

Lista todos los usuarios.

- **Rol requerido:** Admin
- **Headers:** `Authorization: Bearer {token}`

**Response 200 OK:**

```json
[
  { "id": 1, "username": "juan123", "role": "Traveller" },
  { "id": 2, "username": "pedro_chofer", "role": "Driver" }
]
```

| Código | Descripción |
|--------|-------------|
| 200 | Lista de usuarios |
| 401 | Token faltante o inválido |
| 403 | Rol insuficiente (requiere Admin) |

---

### GET /api/users/email/{email}

Obtiene un usuario por email.

- **Rol requerido:** Autenticado
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `email` | `string` | Email del usuario |

**Response 200 OK:**

```json
{ "id": 1, "username": "juan123", "role": "Traveller" }
```

| Código | Descripción |
|--------|-------------|
| 200 | Usuario encontrado |
| 401 | Token faltante o inválido |
| 404 | No encontrado |

---

### PUT /api/users/{id}

Actualiza username y email de un usuario.

- **Rol requerido:** Autenticado
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "username": "juan_nuevo",
  "email": "nuevo@example.com"
}
```

**Response 200 OK:** objeto `UserResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Usuario actualizado |
| 401 | Token faltante o inválido |
| 404 | Usuario no encontrado |

---

### PUT /api/users/{id}/role

Cambia el rol de un usuario (solo admin).

- **Rol requerido:** Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{ "role": 2 }
```

**Response 200 OK:** objeto `UserResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Rol actualizado |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | Usuario no encontrado |

---

## 3. Conductores (Drivers)

Base path: `/api/v1/drivers`  
Sin `[Authorize]` a nivel de clase. Endpoints individuales no tienen restricción salvo los indicados.

---

### POST /api/v1/drivers

Crea un perfil de conductor.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 5,
  "firstName": "Pedro",
  "lastName": "García",
  "documentNumber": "12345678",
  "phone": "999888777",
  "photoUrl": "https://res.cloudinary.com/...",
  "licenseNumber": "Q12345678",
  "licenseCategory": "AIIb",
  "vehiclePlate": "ABC-123",
  "vehicleBrand": "Toyota",
  "vehicleModel": "Coaster",
  "vehicleYear": 2018,
  "vehicleCapacity": 25,
  "vehicleType": "Bus"
}
```

**Response 201 Created:** objeto `DriverResource`.

| Código | Descripción |
|--------|-------------|
| 201 | Conductor creado |
| 400 | Datos inválidos |

---

### GET /api/v1/drivers

Lista todos los conductores.

- **Rol requerido:** Público

**Response 200 OK:** array de `DriverResource`.

---

### GET /api/v1/drivers/{id}

Obtiene un conductor por ID.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `DriverResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Conductor encontrado |
| 404 | No encontrado |

---

### GET /api/v1/drivers/by-user/{userId}

Obtiene el conductor asociado a un usuario IAM.

- **Rol requerido:** Público

**Parámetros de ruta:** `userId` (int)

**Response 200 OK:** objeto `DriverResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Conductor encontrado |
| 404 | No encontrado |

---

### GET /api/v1/drivers/by-vehicle-type/{vehicleType}

Filtra conductores por tipo de vehículo.

- **Rol requerido:** Público

**Parámetros de ruta:**

| Parámetro | Tipo | Valores |
|-----------|------|---------|
| `vehicleType` | `string` | `Car`, `Pickup`, `Combi`, `Van`, `Bus`, `Minivan` |

**Response 200 OK:** array de `DriverResource`.

---

### GET /api/v1/drivers/available?day={day}

Lista conductores disponibles en un día de la semana.

- **Rol requerido:** Público

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `day` | `DayOfWeek` | `0`=Sunday … `6`=Saturday |

**Response 200 OK:** array de `DriverResource`.

---

### PATCH /api/v1/drivers/{id}

Actualiza datos personales del conductor (nombre, teléfono, foto).

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "firstName": "Pedro",
  "lastName": "García López",
  "phone": "988777666",
  "photoUrl": "https://res.cloudinary.com/..."
}
```

**Response 200 OK:** objeto `DriverResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Actualizado |
| 400 | Datos inválidos |
| 404 | Conductor no encontrado |

---

### PATCH /api/v1/drivers/{id}/vehicle

Actualiza los datos del vehículo del conductor.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "plate": "DEF-456",
  "brand": "Mercedes",
  "model": "Sprinter",
  "year": 2020,
  "capacity": 18,
  "vehicleType": "Van"
}
```

**Response 200 OK:** objeto `DriverResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Vehículo actualizado |
| 400 | Datos inválidos |
| 404 | Conductor no encontrado |

---

### PATCH /api/v1/drivers/{id}/availability

Alterna el estado de disponibilidad del conductor.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `DriverResource` con `isAvailable` invertido.

| Código | Descripción |
|--------|-------------|
| 200 | Disponibilidad actualizada |
| 404 | No encontrado |

---

### POST /api/v1/drivers/{id}/photo

Sube una foto de perfil del conductor a Cloudinary.

- **Rol requerido:** Público
- **Headers:** `Content-Type: multipart/form-data`

**Parámetros de ruta:** `id` (int)

**Form-data:**

| Campo | Tipo | Restricciones |
|-------|------|---------------|
| `file` | `IFormFile` | JPEG/PNG/WebP, máx. 5 MB |

**Response 200 OK:** objeto `DriverResource` con `photoUrl` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Foto subida |
| 400 | Archivo inválido o muy grande |
| 404 | Conductor no encontrado |

---

### DELETE /api/v1/drivers/{id}

Elimina (soft-delete) un conductor.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Eliminado |
| 404 | No encontrado |

---

## 4. Tarifas (Tariffs)

Base path: `/api/v1/tariffs`

---

### POST /api/v1/tariffs

Crea una tarifa para un conductor.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdDriver": 3,
  "baseFare": 1.50,
  "pricePerKm": 0.80,
  "pricePerMinute": 0.15,
  "minFare": 2.00,
  "currency": "PEN",
  "availableDays": [1, 2, 3, 4, 5]
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `fkIdDriver` | `int` | ID del conductor |
| `baseFare` | `decimal` | Tarifa base |
| `pricePerKm` | `decimal` | Precio por km |
| `pricePerMinute` | `decimal` | Precio por minuto |
| `minFare` | `decimal` | Tarifa mínima |
| `currency` | `string` | ISO (default `PEN`) |
| `availableDays` | `int[]` | Días (0=Sunday…6=Saturday) |

**Response 201 Created:** objeto `TariffResource`.

```json
{
  "id": 1,
  "fkIdDriver": 3,
  "baseFare": 1.50,
  "pricePerKm": 0.80,
  "pricePerMinute": 0.15,
  "minFare": 2.00,
  "currency": "PEN",
  "availableDays": ["Monday","Tuesday","Wednesday","Thursday","Friday"],
  "isActive": true,
  "createdAt": "2025-01-15T10:00:00Z"
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Tarifa creada |
| 400 | Datos inválidos |

---

### GET /api/v1/tariffs/by-driver/{driverId}

Obtiene la tarifa activa de un conductor.

- **Rol requerido:** Público

**Parámetros de ruta:** `driverId` (int)

**Response 200 OK:** objeto `TariffResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Tarifa encontrada |
| 404 | Sin tarifa para ese conductor |

---

### PATCH /api/v1/tariffs/{id}

Actualiza precios y días disponibles de una tarifa.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "baseFare": 2.00,
  "pricePerKm": 1.00,
  "pricePerMinute": 0.20,
  "minFare": 3.00,
  "availableDays": [1, 2, 3, 4, 5, 6]
}
```

**Response 200 OK:** objeto `TariffResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Tarifa actualizada |
| 404 | No encontrada |

---

### POST /api/v1/tariffs/{id}/route-durations

Registra la duración estimada de un viaje para un par tarifa/ruta.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int) — ID de la tarifa

**Request body:**

```json
{
  "fkIdRoute": 7,
  "estimatedMinutes": 45
}
```

**Response 200 OK:**

```json
{
  "id": 10,
  "fkIdTariff": 1,
  "fkIdRoute": 7,
  "estimatedMinutes": 45
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Duración registrada |
| 400 | Datos inválidos |

---

### GET /api/v1/tariffs/{driverId}/route-durations/{routeId}

Obtiene la duración estimada para un par conductor/ruta.

- **Rol requerido:** Público

**Parámetros de ruta:** `driverId` (int), `routeId` (int)

**Response 200 OK:** objeto `RouteDurationResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Duración encontrada |
| 404 | No encontrada |

---

## 5. Rutas (Routes)

Base path: `/api/routes`

---

### POST /api/routes

Crea una nueva ruta. Llama a OSRM para calcular distancia y geometría.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "frequency": 15,
  "price": 1.50,
  "duration": 40,
  "stopsIds": [1, 5, 8, 12],
  "schedules": [
    {
      "dayOfWeek": "Lunes",
      "startTime": "06:00",
      "endTime": "22:00",
      "enabled": true
    }
  ]
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `frequency` | `int` | Frecuencia en minutos |
| `price` | `double` | Precio del pasaje (S/.) |
| `duration` | `int` | Duración estimada en minutos |
| `stopsIds` | `int[]` | IDs de paraderos en orden |
| `schedules` | `array` | Horarios operativos |

**Response 200 OK:** objeto `RouteAggregateResource`.

```json
{
  "id": 1,
  "price": 1.50,
  "frequency": 15,
  "duration": 40,
  "isActive": true,
  "status": "Active",
  "distanceMeters": 12400.5,
  "durationSeconds": 2400,
  "geometry": "encodedPolylineString...",
  "stops": [
    {
      "id": 1,
      "name": "Paradero Central",
      "image_url": null,
      "address": "Av. Principal 100",
      "fk_driver_id": 3,
      "fk_district_id": 42,
      "latitude": -12.0464,
      "longitude": -77.0428
    }
  ],
  "schedules": [
    {
      "startTime": "06:00",
      "endTime": "22:00",
      "dayOfWeek": "Lunes",
      "enabled": true
    }
  ]
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Ruta creada |
| 400 | Datos inválidos |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 502 | OSRM no disponible |

---

### GET /api/routes

Lista todas las rutas.

- **Rol requerido:** Público

**Response 200 OK:** array de `RouteAggregateResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Rutas encontradas |
| 404 | Sin rutas registradas |

---

### GET /api/routes/{id}

Obtiene una ruta por ID.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `RouteAggregateResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Ruta encontrada |
| 404 | No encontrada |

---

### GET /api/routes/driver/{FkIdDriver}

Lista todas las rutas de un conductor.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDriver` (int)

**Response 200 OK:** array de `RouteAggregateResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Rutas encontradas |
| 404 | Sin rutas para ese conductor |

---

### GET /api/routes/district/{FkIdDistrict}

Lista todas las rutas de un distrito.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDistrict` (int)

**Response 200 OK:** array de `RouteAggregateResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Rutas encontradas |
| 404 | Sin rutas para ese distrito |

---

### PUT /api/routes/{id}

Actualiza una ruta existente. Recalcula geometría con OSRM.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "price": 2.00,
  "duration": 45,
  "frequency": 20,
  "stopsIds": [1, 5, 9, 12],
  "schedules": [
    { "startTime": "06:00", "endTime": "22:00", "dayOfWeek": "Lunes", "enabled": true }
  ]
}
```

**Response 200 OK:** objeto `RouteAggregateResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Ruta actualizada |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrada |
| 502 | OSRM no disponible |

---

### DELETE /api/routes/{id}

Elimina una ruta.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Eliminada |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrada |

---

### PATCH /api/routes/{id}/toggle-availability

Activa o desactiva una ruta.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `RouteAggregateResource` con `isActive` invertido.

| Código | Descripción |
|--------|-------------|
| 200 | Disponibilidad actualizada |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrada |

---

### POST /api/routes/preview

Calcula distancia y geometría para un conjunto de coordenadas sin persistir.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "coordinates": [
    { "latitude": -12.046374, "longitude": -77.042793 },
    { "latitude": -12.052374, "longitude": -77.033793 }
  ]
}
```

**Response 200 OK:**

```json
{
  "distanceMeters": 1240.5,
  "durationSeconds": 180,
  "geometry": "encodedPolylineString..."
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Preview calculado |
| 400 | Se requieren al menos 2 coordenadas |
| 502 | OSRM no disponible |

---

### GET /api/routes/{id}/geometry

Devuelve únicamente la polyline codificada de una ruta.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:**

```json
{ "routeId": 1, "geometry": "encodedPolylineString..." }
```

| Código | Descripción |
|--------|-------------|
| 200 | Geometría obtenida |
| 404 | Ruta no encontrada |

---

### GET /api/routes/{id}/eta?lat={lat}&lng={lng}

Calcula el ETA desde una posición GPS hasta el último paradero de la ruta.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `lat` | `double` | Latitud actual |
| `lng` | `double` | Longitud actual |

**Response 200 OK:**

```json
{
  "routeId": 1,
  "etaSeconds": 720.0,
  "etaMinutes": 12.0
}
```

| Código | Descripción |
|--------|-------------|
| 200 | ETA calculado |
| 404 | Ruta no encontrada o sin coordenadas de destino |
| 502 | OSRM no disponible |

---

## 6. Paraderos (Stops)

Base path: `/api/stops`

---

### POST /api/stops

Crea un paradero con imagen opcional subida a Cloudinary.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: multipart/form-data`

**Form-data:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | `string` | Sí | Nombre del paradero |
| `address` | `string` | Sí | Dirección |
| `reference` | `string` | Sí | Referencia adicional |
| `fkIdDriver` | `int` | Sí | ID del conductor propietario |
| `fkIdDistrict` | `int` | Sí | ID del distrito |
| `googleMapsUrl` | `string` | No | URL de Google Maps |
| `imageFile` | `IFormFile` | No | Imagen del paradero |
| `latitude` | `double` | No | Latitud |
| `longitude` | `double` | No | Longitud |

**Response 201 Created:** objeto `StopResource`.

| Código | Descripción |
|--------|-------------|
| 201 | Paradero creado |
| 400 | Datos inválidos |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 500 | Error interno |

---

### GET /api/stops/{id}

Obtiene un paradero por ID.

- **Rol requerido:** Público

**Response 200 OK:**

```json
{
  "id": 1,
  "name": "Paradero Miraflores",
  "googleMapsUrl": "https://maps.google.com/?q=...",
  "imageUrl": "https://res.cloudinary.com/...",
  "fkIdDriver": 3,
  "address": "Av. Larco 123",
  "reference": "Frente al parque",
  "fkIdDistrict": 42,
  "latitude": -18.046374,
  "longitude": -70.042793
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Paradero encontrado |
| 404 | No encontrado |

---

### GET /api/stops

Lista todos los paraderos.

- **Rol requerido:** Público

**Response 200 OK:** array de `StopResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Paraderos encontrados |
| 404 | Sin paraderos |

---

### GET /api/stops/driver/{FkIdDriver}

Lista paraderos de un conductor.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDriver` (int)

**Response 200 OK:** array de `StopResource`.

---

### GET /api/stops/District/{FkIdDistrict}

Lista paraderos de un distrito.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDistrict` (int)

**Response 200 OK:** array de `StopResource`.

---

### GET /api/stops/district/{FkIdDistrict}/name/{Name}

Busca un paradero por distrito y nombre.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDistrict` (int), `Name` (string)

**Response 200 OK:** objeto `StopResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 404 | No encontrado |

---

### GET /api/stops/driver/{FkIdDriver}/name/{Name}

Busca un paradero por conductor y nombre.

- **Rol requerido:** Público

**Parámetros de ruta:** `FkIdDriver` (int), `Name` (string)

**Response 200 OK:** objeto `StopResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 404 | No encontrado |

---

### PUT /api/stops/{id}

Actualiza un paradero existente. El `id` del body debe coincidir con el de la ruta.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "id": 1,
  "name": "Paradero Miraflores Sur",
  "googleMapsUrl": "https://maps.google.com/?q=...",
  "imageUrl": "https://res.cloudinary.com/...",
  "fkIdDriver": 3,
  "address": "Av. Larco 456",
  "reference": "Cerca de la farmacia",
  "fkIdDistrict": 42,
  "latitude": -18.046374,
  "longitude": -70.042793
}
```

**Response 200 OK:** objeto `StopResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Actualizado |
| 400 | ID no coincide o datos inválidos |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrado |

---

### DELETE /api/stops/{id}

Elimina un paradero.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Eliminado |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrado |

---

## 7. Geografía

Base path: `/api/geographic`  
Sin autenticación requerida.

---

### GET /api/geographic/regions

Lista todas las regiones.

**Response 200 OK:**

```json
[{ "id": 1, "name": "Tacna" }, { "id": 2, "name": "Lima" }]
```

---

### GET /api/geographic/regions/{id}

Obtiene una región por ID.

**Response 200 OK:** `{ "id": 1, "name": "Tacna" }`

| Código | Descripción |
|--------|-------------|
| 200 | Encontrada |
| 404 | No encontrada |

---

### GET /api/geographic/provinces

Lista todas las provincias.

**Response 200 OK:** array de `ProvinceResource` (`id`, `name`, `fkIdRegion`).

---

### GET /api/geographic/provinces/{id}

Obtiene una provincia por ID.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrada |
| 404 | No encontrada |

---

### GET /api/geographic/provinces/region/{regionId}

Lista provincias de una región.

**Parámetros de ruta:** `regionId` (int)

**Response 200 OK:** array de `ProvinceResource`.

---

### GET /api/geographic/districts

Lista todos los distritos.

**Response 200 OK:** array de `DistrictResource` (`id`, `name`, `fkIdProvince`).

---

### GET /api/geographic/districts/{id}

Obtiene un distrito por ID.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 404 | No encontrado |

---

### GET /api/geographic/districts/province/{provinceId}

Lista distritos de una provincia.

**Parámetros de ruta:** `provinceId` (int)

**Response 200 OK:** array de `DistrictResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrados |
| 404 | Sin distritos para esa provincia |

---

## 8. Viajes (Trips)

Base path: `/api/trips`

---

### POST /api/trips

Registra un viaje. Solo pasajeros o admins.

- **Rol requerido:** Traveller, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 1,
  "fkIdDriver": 3,
  "fkIdRoute": 7,
  "fkIdOriginStop": 1,
  "fkIdDestinationStop": 5,
  "price": 1.50,
  "availableSeats": 20
}
```

**Response 201 Created:** objeto `TripResource`.

```json
{
  "id": 10,
  "fkIdUser": 1,
  "fkIdDriver": 3,
  "fkIdRoute": 7,
  "fkIdOriginStop": 1,
  "fkIdDestinationStop": 5,
  "startTime": "2025-01-15T08:00:00Z",
  "endTime": null,
  "price": 1.50,
  "status": "Pending",
  "availableSeats": 20
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Viaje creado |
| 400 | Datos inválidos |
| 401 | No autenticado |
| 403 | Rol insuficiente |

---

### GET /api/trips/{id}

Obtiene un viaje por ID.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `TripResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 401 | No autenticado |
| 404 | No encontrado |

---

### GET /api/trips/user/{userId}

Lista viajes de un pasajero.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `TripResource`.

---

### GET /api/trips/user/{userId}/history

Historial enriquecido de un pasajero (con nombres resueltos).

- **Rol requerido:** Autenticado

**Response 200 OK:**

```json
[
  {
    "id": 10,
    "routeName": "Ruta Central",
    "originName": "Paradero A",
    "destinationName": "Paradero Z",
    "driverName": "Pedro García",
    "passengerName": "Juan López",
    "startTime": "2025-01-15T08:00:00Z",
    "endTime": "2025-01-15T08:45:00Z",
    "price": 1.50,
    "status": "Completed"
  }
]
```

---

### GET /api/trips/driver/{driverId}

Lista viajes de un conductor.

- **Rol requerido:** Autenticado

---

### GET /api/trips/driver/{driverId}/history

Historial enriquecido de un conductor.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `TripHistoryResource`.

---

### POST /api/trips/{id}/start

Inicia un viaje (cambia estado a `InProgress`).

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `TripResource` con `status: "InProgress"`.

| Código | Descripción |
|--------|-------------|
| 200 | Viaje iniciado |
| 400 | No se puede iniciar |
| 401 | No autenticado |
| 403 | Rol insuficiente |
| 404 | No encontrado |

---

### POST /api/trips/{id}/complete

Completa un viaje (cambia estado a `Completed`).

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `TripResource` con `status: "Completed"`.

| Código | Descripción |
|--------|-------------|
| 200 | Completado |
| 400 | No se puede completar |
| 404 | No encontrado |

---

### POST /api/trips/{id}/cancel

Cancela un viaje.

- **Rol requerido:** Driver, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `TripResource` con `status: "Cancelled"`.

| Código | Descripción |
|--------|-------------|
| 200 | Cancelado |
| 400 | No se puede cancelar |
| 404 | No encontrado |

---

## 9. Reservas (Reservations)

Base path: `/api/v1/reservations`

---

### POST /api/v1/reservations

Crea una reserva. Descuenta asientos del Trip y crea un pago pendiente.

- **Rol requerido:** Traveller, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 1,
  "fkIdTrip": 10,
  "documentType": "Dni",
  "documentNumber": "12345678",
  "seats": 2,
  "paymentMethod": "Yape"
}
```

| Campo | Tipo | Valores |
|-------|------|---------|
| `paymentMethod` | `string` | `Yape`, `Plin`, `Card`, `Cash` |
| `documentType` | `string` | `Dni` |

**Response 201 Created:** objeto `ReservationResource`.

```json
{
  "id": 20,
  "fkIdUser": 1,
  "fkIdTrip": 10,
  "documentType": "Dni",
  "documentNumber": "12345678",
  "seats": 2,
  "status": "Pending",
  "fkIdPayment": 15,
  "reservedAt": "2025-01-15T09:00:00Z",
  "confirmedAt": null
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Reserva creada |
| 400 | Datos inválidos o asientos insuficientes |
| 401 | No autenticado |
| 403 | Rol insuficiente |

---

### POST /api/v1/reservations/{id}/confirm

Confirma una reserva tras validar el pago.

- **Rol requerido:** Traveller, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `ReservationResource` con `status: "Confirmed"`.

| Código | Descripción |
|--------|-------------|
| 200 | Confirmada |
| 400 | No se puede confirmar |
| 404 | No encontrada |

---

### POST /api/v1/reservations/{id}/cancel

Cancela una reserva y libera asientos. Registra reembolso si aplica.

- **Rol requerido:** Traveller, Admin
- **Headers:** `Authorization: Bearer {token}`

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `ReservationResource` con `status: "Cancelled"`.

| Código | Descripción |
|--------|-------------|
| 200 | Cancelada |
| 400 | No se puede cancelar |
| 404 | No encontrada |

---

### GET /api/v1/reservations/{id}

Obtiene una reserva por ID.

- **Rol requerido:** Autenticado

**Response 200 OK:** objeto `ReservationResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrada |
| 404 | No encontrada |

---

### GET /api/v1/reservations/by-user/{userId}

Lista reservas de un usuario, de más reciente a más antigua.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `ReservationResource`.

---

### GET /api/v1/reservations/by-trip/{tripId}

Lista reservas de un viaje.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `ReservationResource`.

---

### GET /api/v1/reservations/by-driver/{driverId}

Lista reservas de viajes asignados a un conductor.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `ReservationResource`.

---

## 10. Pagos (Payments)

Base path: `/api/v1/payments`  
Sin `[Authorize]` a nivel de controlador.

---

### POST /api/v1/payments

Crea un pago en estado `Pending`.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 1,
  "amount": 3.00,
  "currency": "PEN",
  "method": "Yape",
  "referenceType": "Reservation",
  "referenceId": 20
}
```

| Campo | Descripción |
|-------|-------------|
| `method` | `Yape`, `Plin`, `Card`, `Cash` |
| `referenceType` | `"Reservation"` o `"Subscription"` |
| `referenceId` | ID de la reserva o suscripción |

**Response 201 Created:** objeto `PaymentResource`.

| Código | Descripción |
|--------|-------------|
| 201 | Pago creado |
| 400 | Datos inválidos |

---

### POST /api/v1/payments/{id}/confirm

Confirma un pago y activa la reserva o suscripción asociada.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{ "externalReference": "YAPE-TXN-001" }
```

**Response 200 OK:** objeto `PaymentResource` con `status: "Completed"`.

| Código | Descripción |
|--------|-------------|
| 200 | Confirmado |
| 400 | No se puede confirmar |
| 404 | Pago no encontrado |

---

### POST /api/v1/payments/{id}/fail

Marca un pago como fallido.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `PaymentResource` con `status: "Failed"`.

---

### POST /api/v1/payments/{id}/refunds

Crea un reembolso para un pago.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{
  "amount": 3.00,
  "reason": "Reserva cancelada por el pasajero"
}
```

**Response 201 Created:** objeto `RefundResource`.

```json
{
  "id": 5,
  "fkIdPayment": 15,
  "amount": 3.00,
  "currency": "PEN",
  "reason": "Reserva cancelada por el pasajero",
  "status": "Pending",
  "createdAt": "2025-01-15T10:00:00Z",
  "confirmedAt": null
}
```

---

### POST /api/v1/refunds/{id}/confirm

Confirma un reembolso.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `RefundResource` con `status: "Completed"`.

---

### GET /api/v1/payments/{id}

Obtiene un pago por ID.

- **Rol requerido:** Público

**Response 200 OK:** objeto `PaymentResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 404 | No encontrado |

---

### GET /api/v1/payments/user/{userId}

Lista pagos de un usuario.

- **Rol requerido:** Público

**Response 200 OK:** array de `PaymentResource`.

---

### GET /api/v1/payments/{id}/refunds

Lista reembolsos de un pago.

- **Rol requerido:** Público

**Response 200 OK:** array de `RefundResource`.

---

## 11. PayU (Pasarela de Tarjetas)

Base path: `/api/v1/payments/payu`

---

### POST /api/v1/payments/payu/{paymentId}/charge

Carga una tarjeta a través de PayU para el pago indicado.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `paymentId` (int)

**Request body:**

```json
{
  "cardNumber": "4111111111111111",
  "cardSecurityCode": "123",
  "cardExpirationDate": "2026/12",
  "cardHolderName": "JUAN GARCIA",
  "payerFullName": "Juan García",
  "payerEmail": "juan@example.com",
  "payerDocumentNumber": "12345678",
  "paymentMethodBrand": "VISA",
  "deviceSessionId": "abc123sessionId",
  "payerIpAddress": null,
  "payerUserAgent": null,
  "payerCookie": null
}
```

**Response 202 Accepted:**

```json
{
  "paymentId": 15,
  "externalReference": "PAYU-TXN-XYZ",
  "message": "Payment approved"
}
```

| Código | Descripción |
|--------|-------------|
| 202 | Cargo procesado |
| 400 | Pago rechazado por PayU |
| 404 | Pago no encontrado |

---

### POST /api/v1/payments/payu/webhook

Webhook de confirmación automática de PayU. **No llamar manualmente.**

- **Rol requerido:** Público (llamado por PayU)
- **Headers:** `Content-Type: application/x-www-form-urlencoded`

**Form fields clave:** `sign`, `state_pol`, `reference_sale`, `value`, `currency`, `transaction_id`

**Response 200 OK** (o 401 si la firma MD5 es inválida)

---

## 12. Calificaciones (Ratings)

Base path: `/api/ratings`

---

### POST /api/ratings

Crea una calificación para un conductor tras un viaje.

- **Rol requerido:** Traveller, Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 1,
  "fkIdDriver": 3,
  "fkIdTrip": 10,
  "score": 4,
  "comment": "Buen servicio, puntual"
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `score` | `int` | 1 (peor) a 5 (mejor) |
| `comment` | `string?` | Opcional |

**Response 201 Created:**

```json
{
  "id": 30,
  "fkIdUser": 1,
  "fkIdDriver": 3,
  "fkIdTrip": 10,
  "score": 4,
  "comment": "Buen servicio, puntual",
  "createdAt": "2025-01-15T12:00:00Z"
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Calificación creada |
| 400 | Datos inválidos |
| 401 | No autenticado |
| 403 | Rol insuficiente |

---

### GET /api/ratings/driver/{driverId}

Lista todas las calificaciones de un conductor.

- **Rol requerido:** Público

**Response 200 OK:** array de `RatingResource`.

---

### GET /api/ratings/driver/{driverId}/summary

Resumen estadístico de calificaciones de un conductor.

- **Rol requerido:** Público

**Response 200 OK:**

```json
{
  "driverId": 3,
  "average": 4.35,
  "count": 42
}
```

---

### GET /api/ratings/user/{userId}

Lista calificaciones emitidas por un usuario.

- **Rol requerido:** Público

**Response 200 OK:** array de `RatingResource`.

---

## 13. Planes (Plans)

Base path: `/api/v1/plans`

---

### POST /api/v1/plans

Crea un nuevo plan de suscripción. Solo admins.

- **Rol requerido:** Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "name": "Premium Mensual",
  "planType": "Premium",
  "targetRole": "Traveller",
  "price": 9.90,
  "currency": "PEN",
  "billingCycle": "Monthly",
  "benefits": "Búsquedas ilimitadas, Asistente IA, Sin publicidad",
  "discoveryQuota": null
}
```

| Campo | Valores posibles |
|-------|-----------------|
| `planType` | `Free`, `Premium` |
| `targetRole` | `Traveller`, `Driver`, `Both` |
| `billingCycle` | `Monthly`, `Yearly` |
| `discoveryQuota` | `int` o `null` (ilimitado) |

**Response 201 Created:** objeto `PlanResource`.

| Código | Descripción |
|--------|-------------|
| 201 | Plan creado |
| 401 | No autenticado |
| 403 | Rol insuficiente |

---

### PATCH /api/v1/plans/{id}

Actualiza un plan existente.

- **Rol requerido:** Admin
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "price": 12.90,
  "benefits": "Beneficios actualizados",
  "discoveryQuota": null,
  "isActive": true
}
```

**Response 200 OK:** objeto `PlanResource` actualizado.

---

### GET /api/v1/plans

Lista todos los planes (activos e inactivos).

- **Rol requerido:** Público

**Response 200 OK:** array de `PlanResource`.

---

### GET /api/v1/plans/{id}

Obtiene un plan por ID.

- **Rol requerido:** Público

**Response 200 OK:** objeto `PlanResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrado |
| 404 | No encontrado |

---

### GET /api/v1/plans/by-target-role/{role}

Lista planes activos filtrados por rol objetivo.

- **Rol requerido:** Público

**Parámetros de ruta:**

| Parámetro | Valores |
|-----------|---------|
| `role` | `Traveller`, `Driver`, `Both` |

**Response 200 OK:** array de `PlanResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Planes encontrados |
| 400 | Rol inválido |

---

## 14. Suscripciones (Subscriptions)

Base path: `/api/v1/subscriptions`

---

### POST /api/v1/subscriptions

Suscribe a un usuario a un plan. Los planes Free se activan de inmediato; los Premium generan un pago pendiente.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "fkIdUser": 1,
  "fkIdPlan": 2,
  "autoRenew": true,
  "paymentMethod": "Yape"
}
```

**Response 201 Created:** objeto `SubscriptionResource`.

```json
{
  "id": 7,
  "fkIdUser": 1,
  "fkIdPlan": 2,
  "status": "PendingPayment",
  "startsAt": "2025-01-15T00:00:00Z",
  "endsAt": "2025-02-15T00:00:00Z",
  "autoRenew": true,
  "fkIdPayment": 16,
  "discoveryUsageInCycle": 0
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Suscripción creada |
| 400 | Datos inválidos o plan no disponible |

---

### POST /api/v1/subscriptions/{id}/cancel

Cancela una suscripción. Si es Premium y está dentro de los 7 días de activación, registra reembolso automático.

- **Rol requerido:** Público

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `SubscriptionResource` con `status: "Cancelled"`.

---

### POST /api/v1/subscriptions/{id}/renew

Renueva una suscripción. Los planes Premium generan un nuevo pago pendiente.

- **Rol requerido:** Público
- **Headers:** `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{ "paymentMethod": "Card" }
```

**Response 200 OK:** objeto `SubscriptionResource` renovado.

---

### GET /api/v1/subscriptions/active/by-user/{userId}

Obtiene la suscripción activa de un usuario.

- **Rol requerido:** Público

**Response 200 OK:** objeto `SubscriptionResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Encontrada |
| 404 | Sin suscripción activa |

---

### GET /api/v1/subscriptions/active/premium-status/by-user/{userId}

Verifica si un usuario tiene plan Premium activo.

- **Rol requerido:** Público

**Response 200 OK:**

```json
{ "isPremium": true }
```

---

### GET /api/v1/subscriptions/history/by-user/{userId}

Historial completo de suscripciones de un usuario.

- **Rol requerido:** Público

**Response 200 OK:** array de `SubscriptionResource`.

---

## 15. Colecciones (Collections)

Base path: `/api/collections`  
**Requiere token** en todos los endpoints.

---

### POST /api/collections

Crea una colección de rutas favoritas.

- **Rol requerido:** Autenticado
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Request body:**

```json
{
  "name": "Mis rutas al trabajo",
  "fkIdUser": 1
}
```

**Response 201 Created:**

```json
{
  "id": 3,
  "name": "Mis rutas al trabajo",
  "fkIdUser": 1,
  "createdAt": "2025-01-15T14:00:00Z",
  "itemCount": 0
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Colección creada |
| 400 | Datos inválidos |
| 401 | No autenticado |

---

### GET /api/collections/user/{userId}

Lista colecciones de un usuario.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `CollectionResource`.

---

### PUT /api/collections/{id}

Renombra una colección.

- **Rol requerido:** Autenticado
- **Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`

**Parámetros de ruta:** `id` (int)

**Request body:**

```json
{ "name": "Rutas casa-trabajo" }
```

**Response 200 OK:** objeto `CollectionResource` actualizado.

| Código | Descripción |
|--------|-------------|
| 200 | Actualizada |
| 401 | No autenticado |
| 404 | No encontrada |

---

### DELETE /api/collections/{id}

Elimina una colección.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Eliminada |
| 401 | No autenticado |
| 404 | No encontrada |

---

### POST /api/collections/{id}/routes/{routeId}

Agrega una ruta a una colección.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int), `routeId` (int)

**Response 201 Created:**

```json
{
  "id": 15,
  "fkIdCollection": 3,
  "fkIdRoute": 7,
  "addedAt": "2025-01-15T14:05:00Z"
}
```

| Código | Descripción |
|--------|-------------|
| 201 | Ruta agregada |
| 400 | No se pudo agregar |
| 401 | No autenticado |

---

### DELETE /api/collections/{id}/routes/{routeId}

Elimina una ruta de una colección.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int), `routeId` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Ruta eliminada |
| 401 | No autenticado |
| 404 | No encontrada |

---

### GET /api/collections/{id}/routes

Lista las rutas guardadas en una colección.

- **Rol requerido:** Autenticado

**Response 200 OK:** array de `CollectionItemResource` (`id`, `fkIdCollection`, `fkIdRoute`, `addedAt`).

---

## 16. Notificaciones (Notifications)

Base path: `/api/notifications`  
**Requiere token** en todos los endpoints.

---

### GET /api/notifications/user/{userId}

Lista notificaciones de un usuario.

- **Rol requerido:** Autenticado

**Response 200 OK:**

```json
[
  {
    "id": 1,
    "fkIdUser": 1,
    "title": "Reserva confirmada",
    "message": "Tu reserva #20 fue confirmada.",
    "type": "Reservation",
    "isRead": false,
    "createdAt": "2025-01-15T09:05:00Z"
  }
]
```

---

### PUT /api/notifications/{id}/read

Marca una notificación como leída.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int)

**Response 200 OK:** objeto `NotificationResource` con `isRead: true`.

| Código | Descripción |
|--------|-------------|
| 200 | Marcada como leída |
| 401 | No autenticado |
| 404 | No encontrada |

---

### DELETE /api/notifications/{id}

Elimina una notificación.

- **Rol requerido:** Autenticado

**Parámetros de ruta:** `id` (int)

**Response 204 No Content**

| Código | Descripción |
|--------|-------------|
| 204 | Eliminada |
| 401 | No autenticado |
| 404 | No encontrada |

---

## 17. Discovery (Búsqueda inteligente)

Base path: `/api/discovery`  
Sin `[Authorize]` a nivel de clase. Todos los endpoints consumen cuota Discovery según el plan del usuario.

---

### GET /api/discovery/search

Busca rutas por origen y/o destino. Incluye estimaciones OSRM cuando se proveen ambas coordenadas de texto. El plan Free tiene cuota limitada; el Premium es ilimitado.

- **Rol requerido:** Público

**Query params:**

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `userId` | `int` | Sí | ID del usuario (para cuota) |
| `origin` | `string` | No | Nombre/texto del origen |
| `destination` | `string` | No | Nombre/texto del destino |
| `date` | `string` | No | Fecha del viaje |

**Response 200 OK:**

```json
[
  {
    "route": { "id": 7, "price": 1.5, "frequency": 15, "duration": 40, "isActive": true, "status": "Active", "stops": [...], "schedules": [...] },
    "estimatedDistanceMeters": 12400,
    "estimatedDurationSeconds": 2400
  }
]
```

| Código | Descripción |
|--------|-------------|
| 200 | Resultados encontrados |
| 403 | Cuota Discovery agotada (plan Free) |

---

### GET /api/discovery/nearby

Encuentra paraderos cercanos a coordenadas GPS.

- **Rol requerido:** Público

**Query params:**

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `userId` | `int` | — | ID del usuario (requerido para cuota) |
| `lat` | `double` | — | Latitud |
| `lng` | `double` | — | Longitud |
| `radius` | `double` | `2.0` | Radio en km |
| `useRoadDistance` | `bool` | `false` | Usar distancia vial (OSRM) vs Haversine |

**Response 200 OK:**

```json
[
  {
    "id": 1,
    "name": "Paradero Central",
    "address": "Av. Principal 100",
    "latitude": -12.046374,
    "longitude": -77.042793,
    "fkIdDriver": 3,
    "fkIdDistrict": 42
  }
]
```

| Código | Descripción |
|--------|-------------|
| 200 | Paraderos encontrados |
| 403 | Cuota agotada |

---

### GET /api/discovery/popular

Lista rutas populares ordenadas por cantidad de viajes.

- **Rol requerido:** Público

**Query params:**

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `userId` | `int` | — | ID del usuario (requerido) |
| `limit` | `int` | `10` | Máximo de resultados |

**Response 200 OK:** array de `RouteAggregateResource`.

| Código | Descripción |
|--------|-------------|
| 200 | Rutas populares |
| 403 | Cuota agotada |

---

### GET /api/discovery/analytics/demand

Analítica de demanda agrupada por hora y día de semana.

- **Rol requerido:** Público

**Query params:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `userId` | `int` | ID del usuario (requerido) |
| `districtId` | `int?` | Filtrar por distrito |
| `period` | `string?` | Período de análisis |

**Response 200 OK:** objeto con datos agrupados por hora y día.

| Código | Descripción |
|--------|-------------|
| 200 | Analítica obtenida |
| 403 | Cuota agotada |

---

### POST /api/discovery/assistant

**Exclusivo plan Premium.** Asistente IA de viajes multi-tramo. Recibe una consulta en lenguaje natural y devuelve itinerarios con transbordos.

- **Rol requerido:** Público (Premium activo validado internamente)
- **Headers:** `Content-Type: application/json`

**Request body:**

```json
{
  "userId": 1,
  "message": "¿Cómo llego desde el centro de Tacna hasta la playa Boca del Río?"
}
```

**Response 200 OK:**

```json
{
  "reply": "Para llegar a Boca del Río desde el centro puedes tomar la Ruta 3...",
  "itineraries": [
    {
      "legs": [...]
    }
  ]
}
```

| Código | Descripción |
|--------|-------------|
| 200 | Respuesta del asistente |
| 403 | Plan Premium requerido |

---

## 18. Configuración (Config)

Base path: `/api/config`

---

### GET /api/config/map

Devuelve la configuración del mapa para inicializar el frontend (tiles OSM, zoom, bounding box de Perú).

- **Rol requerido:** Público

**Response 200 OK:**

```json
{
  "tilesUrl": "http://localhost:8088/tile/{z}/{x}/{y}.png",
  "attribution": "© OpenStreetMap contributors",
  "minZoom": 5,
  "maxZoom": 19,
  "boundingBox": {
    "minLat": -18.35,
    "maxLat": -17.5,
    "minLng": -71.0,
    "maxLng": -69.5
  }
}
```

---

## 19. Health

Base path: `/health`

---

### GET /health

Estado general de la aplicación.

**Response 200 OK (Healthy) / 503 (Unhealthy):**

```json
{
  "status": "Healthy",
  "checks": [
    {
      "name": "mysql",
      "status": "Healthy",
      "description": null,
      "duration": 12.5
    }
  ],
  "totalDuration": 15.2
}
```

---

### GET /health/ready

Verifica solo los checks marcados como `ready` (incluye MySQL).

**Response 200 OK:** `{ "status": "ready" }`  
**Response 503:** `{ "status": "not ready" }`

---

## Relaciones entre entidades

```
User (1) ──────────── (0..1) Driver
User (1) ──────────── (*) Trip       [como pasajero]
User (1) ──────────── (*) Reservation
User (1) ──────────── (*) Payment
User (1) ──────────── (*) Subscription
User (1) ──────────── (*) Rating
User (1) ──────────── (*) Collection
User (1) ──────────── (*) Notification

Driver (1) ─────────── (*) Route
Driver (1) ─────────── (*) Stop
Driver (1) ─────────── (0..1) Tariff
Driver (1) ─────────── (*) Trip      [como conductor]
Tariff (1) ─────────── (*) RouteDuration

Route (1) ──────────── (*) Stop      [via RouteStop]
Route (1) ──────────── (*) Schedule
Route (1) ──────────── (*) Trip
Route (1) ──────────── (*) CollectionItem

Trip (1) ────────────── (*) Reservation
Reservation (1) ──────── (0..1) Payment

Payment (1) ─────────── (*) Refund
Subscription (1) ──────── (0..1) Payment
Plan (1) ────────────── (*) Subscription

Stop (N) ─────────────── (1) District
District (N) ──────────── (1) Province
Province (N) ─────────── (1) Region

Rating → Driver + Trip
CollectionItem → Collection + Route
```

---

## Flujos principales

### 1. Registro de conductor
```
1. POST /api/authentication/sign-up  (role: 2)
2. POST /api/authentication/sign-in  → obtener token JWT
3. POST /api/v1/drivers              → crear perfil de conductor
4. POST /api/v1/drivers/{id}/photo  → subir foto de perfil
5. POST /api/v1/tariffs             → configurar tarifa
6. POST /api/stops                  → registrar paraderos
7. POST /api/routes                 → crear rutas
```

### 2. Reserva de pasajero
```
1. POST /api/authentication/sign-in  → token JWT
2. GET  /api/discovery/search        → buscar ruta
3. GET  /api/discovery/nearby        → paraderos cercanos
4. GET  /api/routes/{id}             → detalle de la ruta
5. POST /api/trips                   → iniciar un viaje
6. POST /api/v1/reservations         → crear reserva (genera pago Pending)
7. POST /api/v1/payments/{id}/confirm → confirmar pago
   (o POST /api/v1/payments/payu/{id}/charge para tarjeta)
8. GET  /api/v1/reservations/{id}    → verificar estado
```

### 3. Ciclo de vida de un viaje
```
Driver: POST /api/trips/{id}/start    → status: InProgress
Driver: POST /api/trips/{id}/complete → status: Completed
Pasajero: POST /api/ratings           → calificar al conductor
```

### 4. Cancelación con reembolso
```
1. POST /api/v1/reservations/{id}/cancel
   → libera asientos + crea Refund si el pago estaba Completed
2. POST /api/v1/refunds/{id}/confirm
   → Refund status: Completed
```

### 5. Suscripción Premium
```
1. GET  /api/v1/plans/by-target-role/Traveller  → listar planes
2. POST /api/v1/subscriptions                   → suscribirse (genera pago Pending)
3. POST /api/v1/payments/{id}/confirm           → activar suscripción
4. GET  /api/v1/subscriptions/active/premium-status/by-user/{userId}
   → verificar { isPremium: true }
5. POST /api/discovery/assistant               → usar asistente IA (solo Premium)
```

---

## Endpoints pendientes (Fase 2 — no implementados)

Estos endpoints existen en el código y responden `501 Not Implemented`:

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/discovery/pois` | POIs cercanos via Overpass API (OSM) |
| GET | `/api/discovery/pois/along-route` | POIs a lo largo de una ruta via Overpass |
| POST | `/api/routes/suggest-stops` | Sugerencia de paraderos via Overpass + OSRM |
