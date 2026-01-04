# Guía de Prueba - Módulo de Adelantos

## Prerequisitos

1. El backend debe estar corriendo con los modelos, rutas y controladores de adelantos implementados
2. La base de datos debe estar sincronizada con los modelos
3. El usuario debe estar autenticado como administrador
4. Debe haber al menos un chofer registrado en la base de datos

## Pasos para Probar

### 1. Acceso al Módulo

- [ ] Inicia la aplicación Flutter
- [ ] Autentícate como administrador
- [ ] Navega a la pestaña "Administración" (última pestaña del bottom navigation)
- [ ] Verifica que aparece la opción "Cargar Adelanto"
- [ ] Presiona "Cargar Adelanto"

### 2. Cargar un Nuevo Adelanto

#### Caso de Éxito

1. [ ] La página carga correctamente con el FutureBuilder
2. [ ] El desplegable de choferes se llena con datos del backend
3. [ ] Selecciona un chofer del desplegable
4. [ ] Presiona en el campo de fecha y selecciona una fecha pasada
5. [ ] Ingresa un importe válido (ej: 1500.50)
6. [ ] Presiona "Cargar adelanto"
7. [ ] Verifica que aparece un SnackBar verde con "Adelanto cargado correctamente"
8. [ ] Verifica que la página se cierra automáticamente

#### Validaciones

1. [ ] **Sin chofer**: Presiona "Cargar adelanto" sin seleccionar chofer → Error naranja
2. [ ] **Sin fecha**: Presiona sin seleccionar fecha → Error naranja
3. [ ] **Sin importe**: Presiona sin ingresar importe → Error naranja
4. [ ] **Importe inválido**: Ingresa texto no numérico → Error naranja
5. [ ] **Importe negativo**: Ingresa -100 → Error naranja
6. [ ] **Importe cero**: Ingresa 0 → Error naranja
7. [ ] **Fecha futura**: Intenta seleccionar una fecha futura → No debe permitir
8. [ ] **Formato de importe**: Ingresa "1.500,50" → Debe funcionar con coma decimal

### 3. Editar un Adelanto (Cuando esté implementado el listado)

1. [ ] Desde el listado de adelantos, presiona editar en un adelanto
2. [ ] La página se abre con los datos precargados
3. [ ] Modifica el chofer
4. [ ] Modifica la fecha
5. [ ] Modifica el importe
6. [ ] Presiona "Guardar cambios"
7. [ ] Verifica que aparece un SnackBar verde con "Adelanto actualizado correctamente"
8. [ ] Verifica que la página se cierra

### 4. Manejo de Errores de Conexión

1. [ ] Detén el servidor backend
2. [ ] Intenta cargar un adelanto
3. [ ] Verifica que aparece un mensaje de error de conexión
4. [ ] Presiona el botón "Reintentar" (si el servidor sigue desconectado)
5. [ ] El FutureBuilder debe intentar recargar los choferes

### 5. Integración con Backend

1. [ ] Carga un adelanto desde la app
2. [ ] Verifica en la base de datos que el registro se creó correctamente
3. [ ] Verifica que `admin_id` está correctamente establecido
4. [ ] Verifica que `driver_id` es el del chofer seleccionado
5. [ ] Verifica que la `date` es la seleccionada
6. [ ] Verifica que `amount` es el valor ingresado

## Checklist de Funcionalidad

### Frontend

- [ ] Modelo `AdvancePaymentData` implementado
- [ ] Imports en `api_service.dart`
- [ ] Métodos en `ApiService`:
  - [ ] `getAdvancePayments()`
  - [ ] `getAdvancePayment()`
  - [ ] `createAdvancePayment()`
  - [ ] `updateAdvancePayment()`
  - [ ] `deleteAdvancePayment()`
- [ ] Página `load_advance.dart` completa
  - [ ] Carga lista de choferes del backend
  - [ ] Selector de fecha
  - [ ] Campo de importe
  - [ ] Validaciones
  - [ ] Llamada a API
- [ ] Página `edit_advance.dart` completa
  - [ ] Recibe parámetros correctamente
  - [ ] Precarga datos
  - [ ] Validaciones
  - [ ] Actualización en backend
- [ ] Integración en `administration.dart`
  - [ ] Botón visible
  - [ ] Navegación funciona
  - [ ] Ícono correcto

### Backend (Verificar que existe)

- [ ] Modelo `AdvancePayment` en `models/advance_payment.py`
- [ ] Schema en `schemas/advance_payment.py`
- [ ] Controlador en `controllers/advance_payment.py`
- [ ] Rutas en `routes/advance_payment.py`
- [ ] Blueprint registrado en `__init__.py` principal

## Notas de Desarrollo

### Localización de Números

- Actualmente usa punto (.) como separador decimal
- Se acepta coma (,) como separador decimal (se reemplaza)
- Formatos válidos: `1500`, `1500.50`, `1500,50`

### Fechas

- Se usa `intl` package con formato `dd/MM/yyyy`
- El límite máximo es la fecha actual (no permite fechas futuras)
- El límite mínimo es 5 años en el pasado

### Usuario Actual

- El `admin_id` se obtiene automáticamente del token
- Se envía al backend sin que el usuario lo seleccione manualmente
- Verifica que `TokenStorage.user` contiene el ID del usuario

## Problemas Comunes y Soluciones

| Problema                           | Causa                    | Solución                           |
| ---------------------------------- | ------------------------ | ---------------------------------- |
| Desplegable de choferes vacío      | Tabla `driver` sin datos | Seed la BD con choferes            |
| Error "No autenticado"             | Token expirado/inválido  | Re-autentica el usuario            |
| Importe no se guarda correctamente | Tipo de dato incorrecto  | Verifica que se convierte a double |
| Error de validación en backend     | Schema marshmallow       | Verifica campos requeridos         |
| Fecha se guarda incorrectamente    | Formato de fecha         | Verifica formato ISO 8601          |

## Archivos Modificados

```
lib/
├── models/
│   └── advance_payment_data.dart          ✓ Nuevo
├── pages/
│   └── admin/
│       ├── load_advance.dart              ✓ Completado
│       ├── edit_advance.dart              ✓ Completado
│       └── administration.dart            ✓ Actualizado
└── services/
    └── api_service.dart                   ✓ Actualizado (import + métodos)
```

## Próximos Pasos Recomendados

1. Implementar pantalla de listado de adelantos
2. Agregar funcionalidad de eliminar adelantos
3. Implementar carga de comprobantes
4. Agregar filtros y búsqueda en listado
5. Crear reportes de adelantos
