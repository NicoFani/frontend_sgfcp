import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:intl/intl.dart';

class NotificationsPageAdmin extends StatelessWidget {
  const NotificationsPageAdmin({super.key});

  static const String routeName = '/admin/notifications';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationsPageAdmin());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Obtener notificaciones reales del backend
    final notifications = [
      _NotificationData(
        title: 'Psicofísico vencido',
        subtitle: 'Se venció el examen psicofísico de Fernando Alonso.',
        time: '10:36',
        icon: Symbols.medical_information,
        isRead: false,
      ),
      _NotificationData(
        title: 'Viaje iniciado',
        subtitle: 'Alexander Albon inició un viaje de Arias a Rosario.',
        time: 'Ayer',
        icon: Symbols.route,
        isRead: false,
      ),
      _NotificationData(
        title: 'Viaje finalizado',
        subtitle: 'Carlos Sainz finalizó el viaje de Arias a Rosario.',
        time: '15/09/2025',
        icon: Symbols.location_on,
        isRead: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Symbols.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPageAdmin(),
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _NotificationListItem(notification: notifications[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.notifications_off,
            size: 64,
            color: colors.onSurfaceVariant,
          ),
          gap16,
          Text(
            'No hay notificaciones',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de notificación
class _NotificationListItem extends StatelessWidget {
  final _NotificationData notification;

  const _NotificationListItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          notification.icon,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        notification.title,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gap4,
          Text(
            notification.subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        notification.time,
        style: textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      onTap: () {
        // TODO: Marcar como leída y navegar a detalles
      },
    );
  }
}

/// Pantalla de configuración de notificaciones
class NotificationSettingsPageAdmin extends StatefulWidget {
  const NotificationSettingsPageAdmin({super.key});

  static const String routeName = '/admin/notifications/settings';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const NotificationSettingsPageAdmin(),
    );
  }

  @override
  State<NotificationSettingsPageAdmin> createState() =>
      _NotificationSettingsPageAdminState();
}

class _NotificationSettingsPageAdminState
    extends State<NotificationSettingsPageAdmin> {
  // Estado de los switches
  bool _tripStarted = true;
  bool _tripFinished = true;
  bool _expirations = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _NotificationSettingItem(
            icon: Symbols.route,
            title: 'Viaje iniciado',
            value: _tripStarted,
            onChanged: (value) {
              setState(() {
                _tripStarted = value;
              });
            },
          ),
          _NotificationSettingItem(
            icon: Symbols.location_on,
            title: 'Viaje finalizado',
            value: _tripFinished,
            onChanged: (value) {
              setState(() {
                _tripFinished = value;
              });
            },
          ),
          _NotificationSettingItem(
            icon: Symbols.event_busy,
            title: 'Vencimientos',
            value: _expirations,
            onChanged: (value) {
              setState(() {
                _expirations = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

/// Item de configuración de notificación
class _NotificationSettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSettingItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: textTheme.bodyLarge,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

// Modelo de datos
class _NotificationData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final bool isRead;

  _NotificationData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    this.isRead = false,
  });
}
