# Módulo de Adelantos a Choferes

## Descripción General

El módulo de adelantos permite a los administradores cargar y gestionar adelantos de dinero asignados a los choferes. Los adelantos no están asociados a viajes específicos, solo a choferes.

## Características Implementadas

### 1. Modelo de Datos

- **Clase**: `AdvancePaymentData` (lib/models/advance_payment_data.dart)
- **Campos**:
  - `id`: Identificador único del adelanto
  - `adminId`: ID del administrador que cargó el adelanto
  - `driverId`: ID del chofer que recibe el adelanto
  - `date`: Fecha del adelanto
  - `amount`: Importe del adelanto
  - `receipt`: Campo opcional para almacenar comprobante

### 2. Servicio API

Se han agregado los siguientes métodos al `ApiService`:

- `getAdvancePayments()`: Obtiene todos los adelantos
- `getAdvancePayment(advancePaymentId)`: Obtiene un adelanto específico
- `createAdvancePayment(driverId, date, amount)`: Crea un nuevo adelanto
- `updateAdvancePayment(advancePaymentId, driverId, date, amount)`: Actualiza un adelanto
- `deleteAdvancePayment(advancePaymentId)`: Elimina un adelanto

### 3. Interfaz de Usuario

#### Cargar Adelanto (`load_advance.dart`)

- **Ruta**: `/admin/load-advance`
- **Acceso**: Menú de Administración > "Cargar Adelanto"
- **Campos**:
  - Desplegable con lista de choferes (obtenida del backend en tiempo real)
  - Selector de fecha (máximo la fecha actual)
  - Campo de importe (validado como número decimal positivo)
  - Botón para adjuntar comprobante (funcionalidad futura)
- **Validaciones**:
  - Chofer requerido
  - Fecha requerida y no futura
  - Importe requerido y > 0
  - Número válido en importe

#### Editar Adelanto (`edit_advance.dart`)

- **Ruta**: `/admin/edit-advance`
- **Parámetros**: `advancePaymentId`, `driverId`, `driverName`, `date`, `amount`
- **Funcionalidad**:
  - Precarga los datos existentes del adelanto
  - Permite cambiar el chofer, fecha e importe
  - Incluye las mismas validaciones que la carga
  - Botón para cambiar comprobante (funcionalidad futura)

### 4. Integración en Administración

Se agregó un nuevo menú en `administration.dart`:

- Icono: Dinero (`Symbols.attach_money`)
- Etiqueta: "Cargar Adelanto"
- Navegación a la pantalla de carga de adelantos

## Flujo de Uso

### Cargar un Adelanto

1. Admin navega a: Administración > "Cargar Adelanto"
2. Selecciona un chofer del desplegable
3. Selecciona una fecha
4. Ingresa el importe
5. (Opcional) Adjunta un comprobante
6. Presiona "Cargar adelanto"
7. Se guarda en el backend y muestra confirmación

### Editar un Adelanto

1. Admin abre la pantalla de edición (navegación desde lista de adelantos - por implementar)
2. Los datos se precarga automáticamente
3. Modifica los campos según sea necesario
4. Presiona "Guardar cambios"
5. Se actualiza en el backend

## Validaciones Implementadas

### Frontend

- Validación de campos requeridos
- Validación de formato de número (importe)
- Validación de rango de fecha (no futura)
- Validación de importe positivo

### Backend (existente)

- Validación de `admin_id` (requerido)
- Validación de `driver_id` (requerido)
- Validación de `date` (requerido)
- Validación de `amount` >= 0 (requerido)
- Validación de `receipt` (máximo 75 caracteres)

## Manejo de Errores

- Conexión a servidor: Mensaje de error con opción de reintentar
- Validación de datos: Mensajes específicos por campo
- Operaciones fallidas: Mensaje de error desde el servidor

## Funcionalidades Futuras

- [ ] Adjuntar/cambiar comprobantes (subida de archivos)
- [ ] Listado de adelantos con opción de editar/eliminar
- [ ] Filtros por chofer, rango de fechas
- [ ] Reportes de adelantos por mes/chofer
- [ ] Asociación de adelantos con viajes para descuentos

## Estructura de Carpetas

```
lib/
├── models/
│   └── advance_payment_data.dart      (Nuevo)
├── pages/
│   └── admin/
│       ├── load_advance.dart          (Completado)
│       ├── edit_advance.dart          (Completado)
│       └── administration.dart        (Actualizado)
└── services/
    └── api_service.dart               (Actualizado)
```

## Endpoints Utilizados

- `GET /advance-payments/` - Obtener todos los adelantos
- `GET /advance-payments/<id>` - Obtener un adelanto
- `POST /advance-payments/` - Crear adelanto
- `PUT /advance-payments/<id>` - Actualizar adelanto
- `DELETE /advance-payments/<id>` - Eliminar adelanto
