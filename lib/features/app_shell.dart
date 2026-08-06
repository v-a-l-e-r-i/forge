import 'package:flutter/material.dart';
import 'package:forge/features/theme/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/notification_model.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../services/push_notification_service.dart';
import '../../widgets/forge_brand_card.dart';
import '../../widgets/forge_logo.dart';
import 'pages/heroes_page.dart';
import 'pages/home_page.dart';
import 'pages/notifications_page.dart';
import 'pages/tasks_page.dart';
import 'theme/theme_provider.dart';

/// Брейкпоінт, з якого показуємо постійний sidebar замість Drawer —
/// той самий поріг (900px), що й в адмінському Command Center.
const double _desktopBreakpoint = 900;

class _NavItem {
  const _NavItem({
    required this.pageIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Індекс у `_pages` (не в списку самих nav items — профіль доступний
  /// через картку зверху сайдбару, а не через окремий пункт списку).
  final int pageIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _pageTitles = ['Профіль', 'Quest Board', 'Сповіщення', 'Герої'];

const _navItems = [
  _NavItem(pageIndex: 1, icon: Icons.task_outlined, selectedIcon: Icons.task, label: 'Quest Board'),
  _NavItem(
    pageIndex: 2,
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
    label: 'Сповіщення',
  ),
  _NavItem(
    pageIndex: 3,
    icon: Icons.groups_outlined,
    selectedIcon: Icons.groups,
    label: 'Герої',
  ),
];

/// Єдина точка входу після логіну. Структура один-в-один з адмінським
/// AdminShell: власна верхня панель з назвою розділу (без стандартного
/// Scaffold.appBar), sidebar на широких екранах / Drawer на вузьких, і
/// клікабельна картка профілю зверху сайдбару, що веде на таб "Профіль".
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _pages = [HomeBody(), QuestsBody(), NotificationsBody(), HeroesBody()];

  void _selectIndex(int index) {
    setState(() => _selectedIndex = index);
    // Якщо викликано з Drawer — закриваємо його після вибору пункту
    // (Scaffold реєструє відкритий Drawer як локальний запис історії,
    // тож pop() коректно закриє саме його, а не весь застосунок).
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTitle = _pageTitles[_selectedIndex];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: _SidebarNav(
                    selectedIndex: _selectedIndex,
                    onSelect: _selectIndex,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(title: currentTitle),
                      Expanded(
                        child: IndexedStack(index: _selectedIndex, children: _pages),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: _SidebarNav(
              selectedIndex: _selectedIndex,
              onSelect: _selectIndex,
            ),
          ),
          body: Column(
            children: [
              _TopBar(
                title: currentTitle,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: _pages),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Верхня панель контентної частини — лише назва поточного розділу (+
/// гамбургер на вузьких екранах). Аналог DashboardTopBar в адмінці: сам
/// бренд і дії (тема/вихід) живуть у sidebar, не тут.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.onMenuPressed});

  final String title;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.secondary.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          children: [
            if (onMenuPressed != null)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuPressed,
              )
            else
              const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Вміст sidebar/Drawer: бренд, клікабельна картка профілю (веде на таб
/// "Профіль"), список решти розділів, і внизу — тема/вихід.
class _SidebarNav extends StatelessWidget {
  const _SidebarNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authService = context.read<AuthService>();

    return Container(
      color: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  ForgeLogo(size: 28, onTap: () => showForgeBrandCard(context)),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => showForgeBrandCard(context),
                    child: Text(
                      'FORGE',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<AppUser?>(
              stream: authService.watchCurrentAppUser(),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return _ProfileCard(
                  user: user,
                  isSelected: selectedIndex == 0,
                  onTap: () => onSelect(0),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final item in _navItems)
                    _NavTile(
                      item: item,
                      isSelected: selectedIndex == item.pageIndex,
                      onTap: () => onSelect(item.pageIndex),
                      trailing: item.pageIndex == 2 ? const _UnreadNavBadge() : null,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            _BottomActionsRow(authService: authService),
          ],
        ),
      ),
    );
  }
}

/// Клікабельна картка профілю зверху sidebar — тап переносить на таб
/// "Профіль" (HomeBody), так само, як клік на власний нік в адмінці.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final AppUser? user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final nickname = user?.nickname ?? '';
    final initial = nickname.isNotEmpty ? nickname[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.primary,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname.isEmpty ? '...' : '@$nickname',
                        style: TextStyle(
                          color: isSelected ? colors.primary : colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user != null)
                        Text(
                          user!.role.label,
                          style: TextStyle(
                            color: colors.secondary.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? colors.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  size: 20,
                  color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? colors.primary : colors.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Бейдж непрочитаних сповіщень у пункті навігації "Сповіщення".
class _UnreadNavBadge extends StatelessWidget {
  const _UnreadNavBadge();

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final notificationService = context.read<NotificationService>();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) return const SizedBox();

        return StreamBuilder<List<ForgeNotification>>(
          stream: notificationService.watchMyNotifications(
            userId: user.id,
            teamId: user.teamId,
          ),
          builder: (context, snapshot) {
            final unread =
                snapshot.data?.where((n) => !n.isReadBy(user.id)).length ?? 0;
            if (unread == 0) return const SizedBox();
            return _UnreadPill(count: unread);
          },
        );
      },
    );
  }
}

class _UnreadPill extends StatelessWidget {
  const _UnreadPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: colors.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Тема + вихід — внизу sidebar, там само, де в адмінці onSignOut.
class _BottomActionsRow extends StatelessWidget {
  const _BottomActionsRow({required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: () => context.read<ThemeProvider>().toggleTheme(!themeProvider.isDarkMode),
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 18),
              label: Text(themeProvider.isDarkMode ? 'Світла тема' : 'Темна тема'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              final uid = authService.currentUser?.uid;
              await PushNotificationService.instance
                  .unregisterForCurrentDevice(previousUid: uid);
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}