import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const String routeName = '/admin/notifications';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationsPage());
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
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: notifications.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Divider(height: 1),
                ),
                itemBuilder: (context, index) {
                  return _NotificationListItem(notification: notifications[index]);
                },
              ),
        ),
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
      leading: Icon(
        notification.icon,
        size: 20,
        color: colors.onSurfaceVariant,
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
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  static const String routeName = '/admin/notifications/settings';

  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const NotificationSettingsPage(),
    );
  }

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends State<NotificationSettingsPage> {
  // Estado de los switches
  bool _tripStarted = true;
  bool _tripFinished = true;
  bool _expirations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: 3,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _NotificationSettingItem(
                    icon: Symbols.route,
                    title: 'Viaje iniciado',
                    value: _tripStarted,
                    onChanged: (value) {
                      setState(() {
                        _tripStarted = value;
                      });
                    },
                  );
                case 1:
                  return _NotificationSettingItem(
                    icon: Symbols.location_on,
                    title: 'Viaje finalizado',
                    value: _tripFinished,
                    onChanged: (value) {
                      setState(() {
                        _tripFinished = value;
                      });
                    },
                  );
                case 2:
                default:
                  return _NotificationSettingItem(
                    icon: Symbols.event_busy,
                    title: 'Vencimientos',
                    value: _expirations,
                    onChanged: (value) {
                      setState(() {
                        _expirations = value;
                      });
                    },
                  );
              }
            },
          ),
        ),
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
      leading: Icon(
        icon,
        size: 20,
        color: colors.onSurfaceVariant,
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
