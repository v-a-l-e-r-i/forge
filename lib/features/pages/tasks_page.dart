import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';

/// Похідні кольори дошки, побудовані з поточної ColorScheme (dark_mode.dart /
/// light_mode.dart), щоб дошка автоматично підхоплювала перемикання теми
/// через ThemeProvider — без жодного хардкоду кольорів.
class _BoardPalette {
  _BoardPalette._(this.theme)
      : background = theme.scaffoldBackgroundColor,
        columnSurface = theme.colorScheme.surface,
        cardSurface = Color.alphaBlend(
          theme.colorScheme.onSurface.withValues(alpha: theme.brightness == Brightness.dark ? 0.05 : 0.035),
          theme.colorScheme.surface,
        ),
        border = theme.colorScheme.onSurface.withValues(alpha: 0.10),
        textPrimary = theme.colorScheme.onSurface,
        textSecondary = theme.colorScheme.secondary, // Soft Linen (dark) / Graphite (light)
        accent = theme.colorScheme.primary; // Amethyst

  final ThemeData theme;
  final Color background;
  final Color columnSurface;
  final Color cardSurface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;

  // Кольори-індикатори колонок — не залежать від теми, лишаються впізнаваними
  // в обох режимах.
  static const newDot = Color(0xFF5B8DEF);
  static const inProgressDot = Color(0xFF29B6C6);
  static const pendingDot = Color(0xFFE8A33D);
  static const doneDot = Color(0xFF4CAF6D);

  Color get onAccent => Colors.white;

  static _BoardPalette of(BuildContext context) => _BoardPalette._(Theme.of(context));
}

/// Standalone-варіант з власним AppBar — використовується лише якщо
/// сторінка відкривається напряму, поза AppShell (наприклад deep-link).
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quest Board')),
      body: const QuestsBody(),
    );
  }
}

/// Вміст Quest Board — єдиний перемикач-кнопки (New / In Progress /
/// Pending Approval / Completed) зверху, під ним показується лише вибрана
/// секція. Однакова логіка і на мобільному, і на десктопі — різниця лише
/// в тому, скільки карток влазить у рядок (responsive grid), без окремих
/// gilок для двох платформ.
class QuestsBody extends StatefulWidget {
  const QuestsBody({super.key});

  @override
  State<QuestsBody> createState() => _QuestsBodyState();
}

class _QuestsBodyState extends State<QuestsBody> {
  int _selectedColumn = 0;

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final palette = _BoardPalette.of(context);

    return Container(
      color: palette.background,
      child: StreamBuilder<AppUser?>(
        stream: authService.watchCurrentAppUser(),
        builder: (context, userSnapshot) {
          final user = userSnapshot.data;

          if (user == null) {
            return Center(child: CircularProgressIndicator(color: palette.accent));
          }

          return _TaskStreams(
            user: user,
            builder: (context, available, inProgress, pending, completed, loading) {
              if (loading) {
                return Center(child: CircularProgressIndicator(color: palette.accent));
              }

              final columns = [
                _ColumnData(
                  label: 'New',
                  dotColor: _BoardPalette.newDot,
                  tasks: available,
                  emptyText: 'No available quests right now.',
                  cardBuilder: (task) => TaskCard(
                    task: task,
                    actionButton: _AcceptButton(user: user, task: task),
                  ),
                ),
                _ColumnData(
                  label: 'In Progress',
                  dotColor: _BoardPalette.inProgressDot,
                  tasks: inProgress,
                  emptyText: 'Nothing in progress yet.',
                  cardBuilder: (task) => TaskCard(
                    task: task,
                    actionButton: _SubmitButton(task: task),
                  ),
                ),
                _ColumnData(
                  label: 'Pending Approval',
                  dotColor: _BoardPalette.pendingDot,
                  tasks: pending,
                  emptyText: 'Nothing waiting on admin review.',
                  cardBuilder: (task) => TaskCard(
                    task: task,
                    actionButton: const _PendingApprovalBadge(),
                  ),
                ),
                _ColumnData(
                  label: 'Completed',
                  dotColor: _BoardPalette.doneDot,
                  tasks: completed,
                  emptyText: 'No completed quests yet.',
                  cardBuilder: (task) => TaskCard(
                    task: task,
                    actionButton: const _CompletedBadge(),
                  ),
                ),
              ];

              final safeIndex = _selectedColumn.clamp(0, columns.length - 1);

              return Column(
                children: [
                  _ColumnTabBar(
                    columns: columns,
                    selectedIndex: safeIndex,
                    onSelect: (i) => setState(() => _selectedColumn = i),
                  ),
                  Expanded(child: _ColumnList(column: columns[safeIndex])),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ColumnData {
  const _ColumnData({
    required this.label,
    required this.dotColor,
    required this.tasks,
    required this.emptyText,
    required this.cardBuilder,
  });

  final String label;
  final Color dotColor;
  final List<Task> tasks;
  final String emptyText;
  final Widget Function(Task task) cardBuilder;
}

/// Ряд кнопок-перемикачів колонок — той самий вигляд і на мобільному, і на
/// десктопі. Скролиться горизонтально, якщо не влазить у вузький екран.
class _ColumnTabBar extends StatelessWidget {
  const _ColumnTabBar({
    required this.columns,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_ColumnData> columns;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);

    return Container(
      decoration: BoxDecoration(
        color: palette.columnSurface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ColumnTabButton(
                  column: columns[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onSelect(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ColumnTabButton extends StatelessWidget {
  const _ColumnTabButton({
    required this.column,
    required this.isSelected,
    required this.onTap,
  });

  final _ColumnData column;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);

    return Material(
      color: isSelected ? column.dotColor.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? column.dotColor.withValues(alpha: 0.6) : palette.border,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: column.dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                column.label,
                style: TextStyle(
                  color: isSelected ? column.dotColor : palette.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? column.dotColor.withValues(alpha: 0.22)
                      : palette.cardSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${column.tasks.length}',
                  style: TextStyle(
                    color: isSelected ? column.dotColor : palette.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

/// Список карток вибраної секції — одна картка в рядку, висота підлаштовується
/// під власний вміст картки (без порожнього місця під кнопкою, як було з
/// фіксованою mainAxisExtent). На широких екранах список центрується й
/// обмежується по ширині, щоб не розтягувався на весь екран.
class _ColumnList extends StatelessWidget {
  const _ColumnList({required this.column});

  final _ColumnData column;

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);

    if (column.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            column.emptyText,
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: column.tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: column.cardBuilder(column.tasks[index]),
        ),
      ),
    );
  }
}

/// Об'єднує обидва Firestore-стріми (доступні завдання + завдання юзера)
/// в один builder і ділить завдання юзера на "в роботі" / "на перевірці" /
/// "завершено", щоб не дублювати StreamBuilder-и на десктопі й мобільному.
class _TaskStreams extends StatelessWidget {
  const _TaskStreams({required this.user, required this.builder});

  final AppUser user;
  final Widget Function(
      BuildContext context,
      List<Task> available,
      List<Task> inProgress,
      List<Task> pendingApproval,
      List<Task> completed,
      bool loading,
      ) builder;

  @override
  Widget build(BuildContext context) {
    final taskService = context.read<TaskService>();

    return StreamBuilder<List<Task>>(
      stream: taskService.watchAvailableTasks(),
      builder: (context, availableSnap) {
        return StreamBuilder<List<Task>>(
          stream: taskService.watchUserTasks(user.id),
          builder: (context, userSnap) {
            final loading =
                availableSnap.connectionState == ConnectionState.waiting ||
                    userSnap.connectionState == ConnectionState.waiting;

            final available = availableSnap.data ?? const <Task>[];
            final userTasks = userSnap.data ?? const <Task>[];
            final inProgress =
            userTasks.where((t) => !t.isCompleted && !t.pendingApproval).toList();
            final pending = userTasks.where((t) => t.pendingApproval).toList();
            final completed = userTasks.where((t) => t.isCompleted).toList();

            return builder(context, available, inProgress, pending, completed, loading);
          },
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// Дії з завданнями (спільні для десктопу й мобільного)
/// ---------------------------------------------------------------------
Future<void> _takeTask(BuildContext context, AppUser user, Task task) async {
  final taskService = context.read<TaskService>();
  try {
    await taskService.assignTask(taskId: task.id, userId: user.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quest "${task.title}" accepted!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to accept quest.')),
      );
    }
  }
}

Future<void> _submitTask(BuildContext context, Task task) async {
  final taskService = context.read<TaskService>();
  try {
    await taskService.submitForApproval(task.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quest "${task.title}" sent for admin review.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit quest for review.')),
      );
    }
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.user, required this.task});

  final AppUser user;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _takeTask(context, user, task),
      child: const Text('Accept Quest', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Замінює колишню "Complete Quest" — герой лише здає таск на перевірку,
/// а не завершує його самостійно. XP нараховується тільки після
/// підтвердження адміном.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.accent,
        side: BorderSide(color: palette.accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => _submitTask(context, task),
      child: const Text('Submit for Review', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _PendingApprovalBadge extends StatelessWidget {
  const _PendingApprovalBadge();

  @override
  Widget build(BuildContext context) {
    const pendingColor = _BoardPalette.pendingDot;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: pendingColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: pendingColor.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_top, color: pendingColor, size: 16),
          SizedBox(width: 6),
          Text(
            'Awaiting approval',
            style: TextStyle(color: pendingColor, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    const doneColor = _BoardPalette.doneDot;
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: doneColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: doneColor.withValues(alpha: 0.4)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: doneColor, size: 16),
          SizedBox(width: 6),
          Text(
            'Completed',
            style: TextStyle(color: doneColor, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Картка завдання — стиль дошки, кольори беруться з поточної теми
/// (Amethyst / Graphite / Soft Linen / Black), тож картка виглядає коректно
/// і в dark_mode.dart, і в light_mode.dart.
/// Сигнатура (task + actionButton) лишилась як у попередній версії, щоб не
/// ламати місця, де TaskCard міг використовуватись напряму.
/// ---------------------------------------------------------------------
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.actionButton,
  });

  final Task task;
  final Widget actionButton;

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'hard':
        return Colors.red.shade400;
      case 'epic':
        return Colors.deepPurpleAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.of(context);
    final difficultyColor = _getDifficultyColor(task.difficulty);

    return Container(
      decoration: BoxDecoration(
        color: palette.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Складність + XP в одному рядку, по краях
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: difficultyColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond, color: palette.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${task.points} XP',
                      style: TextStyle(
                        color: palette.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Заголовок
            Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),

            // Опис
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: palette.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),

            // Кнопка дії
            SizedBox(
              width: double.infinity,
              height: 40,
              child: actionButton,
            ),
          ],
        ),
      ),
    );
  }
}