import 'package:flutter/material.dart';
import 'package:forge/widgets/forge_logo.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

/// Standalone-варіант із власним AppBar — використовується для прямої
/// навігації (наприклад, з натискання push-сповіщення поза AppShell).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сповіщення')),
      body: const NotificationsBody(),
    );
  }
}

/// Вміст сторінки сповіщень — без Scaffold/AppBar, щоб вбудовуватись як
/// таб у AppShell так само, як окремою сторінкою.
class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  void _openNotification(
      BuildContext context,
      ForgeNotification notification,
      String userId,
      ) {
    if (!notification.isReadBy(userId)) {
      context
          .read<NotificationService>()
          .markAsRead(notificationId: notification.id, userId: userId);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NotificationDetailsSheet(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final notificationService = context.read<NotificationService>();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<ForgeNotification>>(
          stream: notificationService.watchMyNotifications(
            userId: user.id,
            teamId: user.teamId,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Не вдалося завантажити сповіщення.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(child: Text('Поки що немає сповіщень'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = items[index];
                return _NotificationCard(
                  notification: notification,
                  isUnread: !notification.isReadBy(user.id),
                  onTap: () => _openNotification(context, notification, user.id),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Форматує дату сповіщення так само, як стрічки сповіщень у більшості
/// застосунків: "Щойно" / "12 хв тому" / час сьогодні / "Учора, HH:mm" /
/// повна дата для старіших.
String _relativeLabel(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inSeconds < 60) return 'Щойно';
  if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';

  final isToday = now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day;
  if (isToday) return DateFormat('HH:mm').format(dateTime);

  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = yesterday.year == dateTime.year &&
      yesterday.month == dateTime.month &&
      yesterday.day == dateTime.day;
  if (isYesterday) return 'Учора, ${DateFormat('HH:mm').format(dateTime)}';

  return DateFormat('dd.MM.yyyy').format(dateTime);
}

class _ForgeBadge extends StatelessWidget {
  const _ForgeBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ForgeLogo(size: 24, onTap: () => {}),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isUnread,
    required this.onTap,
  });

  final ForgeNotification notification;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      elevation: isUnread ? 1.5 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Акцентна смужка — видно лише для непрочитаних.
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isUnread ? colors.primary : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const _ForgeBadge(),
                          const SizedBox(width: 10),
                          Text(
                            'Forge',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _relativeLabel(notification.createdAt),
                            style: TextStyle(
                              color: colors.secondary.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.onSurface.withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailsSheet extends StatelessWidget {
  const _NotificationDetailsSheet({required this.notification});

  final ForgeNotification notification;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _ForgeBadge(),
                const SizedBox(width: 10),
                Text(
                  'Forge',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _relativeLabel(notification.createdAt),
                  style: TextStyle(
                    color: colors.secondary.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(notification.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(notification.body, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Дзвіночок з бейджем непрочитаних — використовується в AppBar HomePage.
class NotificationBellIcon extends StatelessWidget {
  const NotificationBellIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final notificationService = context.read<NotificationService>();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) {
          return IconButton(
            onPressed: null,
            icon: const Icon(Icons.notifications_outlined),
          );
        }

        return StreamBuilder<List<ForgeNotification>>(
          stream: notificationService.watchMyNotifications(
            userId: user.id,
            teamId: user.teamId,
          ),
          builder: (context, snapshot) {
            final unreadCount =
                snapshot.data?.where((n) => !n.isReadBy(user.id)).length ?? 0;

            return IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              ),
              icon: Badge(
                label: Text('$unreadCount'),
                isLabelVisible: unreadCount > 0,
                child: const Icon(Icons.notifications_outlined),
              ),
            );
          },
        );
      },
    );
  }
}