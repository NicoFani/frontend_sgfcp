import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:frontend_sgfcp/theme/spacing.dart';
import 'package:frontend_sgfcp/models/notification_data.dart';
import 'package:frontend_sgfcp/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const String routeName = '/admin/notifications';

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const NotificationsPage());
  }

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationData>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = NotificationService.getNotifications();
    });
  }

  Future<void> _refresh() async {
    _loadNotifications();
    await _notificationsFuture;
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'trip_started':
        return Symbols.route;
      case 'trip_finished':
        return Symbols.location_on;
      case 'trip_assigned':
        return Symbols.add_road;
      case 'advance_payment':
        return Symbols.payments;
      case 'document_expired':
        return Symbols.event_busy;
      case 'document_expiring':
      default:
        return Symbols.event_upcoming;
    }
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (date == today) {
      return DateFormat('HH:mm').format(createdAt);
    }

    if (date == today.subtract(const Duration(days: 1))) {
      return 'Ayer';
    }

    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<NotificationData>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState(context);
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(height: 1),
                  ),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationListItem(
                      notification: notification,
                      timeLabel: _formatTime(notification.createdAt),
                      icon: _iconForType(notification.type),
                      onTap: () async {
                        if (!notification.isRead) {
                          await NotificationService.markAsRead(notification.id);
                          await _refresh();
                        }
                      },
                    );
                  },
                ),
              );
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

  Widget _buildErrorState(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          gap16,
          Text(
            'No se pudieron cargar las notificaciones',
            style: textTheme.bodyMedium,
          ),
          gap16,
          FilledButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Item de notificación
class _NotificationListItem extends StatelessWidget {
  final NotificationData notification;
  final String timeLabel;
  final IconData icon;
  final VoidCallback onTap;

  const _NotificationListItem({
    required this.notification,
    required this.timeLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, size: 20, color: colors.onSurfaceVariant),
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
            notification.message,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        timeLabel,
        style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
      ),
      onTap: onTap,
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

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Estado de los switches
  bool _tripStarted = true;
  bool _tripFinished = true;
  bool _expirations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
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
      leading: Icon(icon, size: 20, color: colors.onSurfaceVariant),
      title: Text(title, style: textTheme.bodyLarge),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

// Modelo de datos
