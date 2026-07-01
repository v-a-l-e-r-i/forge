import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/task.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Використовуємо DefaultTabController для двох вкладок: Вільні та Мої
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Quest Board'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Available Quests'),
                  Tab(text: 'My Active Quests'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _AvailableTasksTab(user: user),
                _MyTasksTab(user: user),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Вкладка з доступними завданнями
class _AvailableTasksTab extends StatelessWidget {
  const _AvailableTasksTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final taskService = context.read<TaskService>();

    return StreamBuilder<List<Task>>(
      stream: taskService.watchAvailableTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Center(
            child: Text('No available quests right now. Come back later!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              actionButton: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () => _takeTask(context, task),
                child: const Text('Accept Quest'),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _takeTask(BuildContext context, Task task) async {
    final taskService = context.read<TaskService>();
    try {
      // Припускаємо, що AppUser має поле id. Якщо воно називається інакше (напр. uid), замініть тут.
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
}

/// Вкладка з активними завданнями поточного користувача
class _MyTasksTab extends StatelessWidget {
  const _MyTasksTab({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final taskService = context.read<TaskService>();

    return StreamBuilder<List<Task>>(
      stream: taskService.watchUserTasks(user.id), // Передаємо ID користувача
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data ?? [];

        // Фільтруємо лише незавершені таски для цієї вкладки
        final activeTasks = tasks.where((t) => !t.isCompleted).toList();

        if (activeTasks.isEmpty) {
          return const Center(
            child: Text('You have no active quests.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeTasks.length,
          itemBuilder: (context, index) {
            final task = activeTasks[index];
            return TaskCard(
              task: task,
              actionButton: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                onPressed: () => _completeTask(context, task),
                child: const Text('Complete Quest'),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _completeTask(BuildContext context, Task task) async {
    final taskService = context.read<TaskService>();
    try {
      // Передаємо всі необхідні дані для нарахування XP
      await taskService.completeTask(
        taskId: task.id,
        userId: user.id,
        points: task.points,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quest completed! Earned ${task.points} XP'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete quest.')),
        );
      }
    }
  }
}

/// Універсальна картка завдання (використовує стилістику з Source 1)
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
    final theme = Theme.of(context);
    final softLinen = theme.colorScheme.secondary;
    final amethyst = theme.colorScheme.primary;

    return Card(
      color: theme.colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0, // Flat-дизайн як у профілі
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок та нагорода
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: amethyst.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.diamond, color: amethyst, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${task.points} XP',
                        style: TextStyle(
                          color: amethyst,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Бейдж складності
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(task.difficulty).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                task.difficulty.toUpperCase(),
                style: TextStyle(
                  color: _getDifficultyColor(task.difficulty),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: softLinen.withValues(alpha: 0.2), height: 1),
            ),

            // Опис завдання
            Text(
              task.description,
              style: TextStyle(
                color: softLinen,
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка дії (Взяти або Завершити)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: actionButton,
            ),
          ],
        ),
      ),
    );
  }
}