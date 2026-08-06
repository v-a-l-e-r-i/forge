import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../models/app_user.dart';
import '../../models/character.dart';
import '../../models/team.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

/// Вміст сторінки профілю — без Scaffold/AppBar, бо їх тепер надає
/// AppShell. Використовується як один із табів у shell.
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<Character?>(
          stream: authService.watchCurrentCharacter(),
          builder: (context, charSnapshot) {
            final character = charSnapshot.data;

            if (character == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return _ProfileBody(user: user, character: character);
          },
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.user,
    required this.character,
  });

  final AppUser user;
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final softLinen = theme.colorScheme.secondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Головна колекційна картка
              CharacterCard(user: user, character: character),
              const SizedBox(height: 24),

              // Картка статистики (використовує колір surface - Graphite)
              Card(
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0, // Чистий Flat-дизайн згідно з темою
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _ProfileRow(label: 'Real Name', value: user.name),
                      _ProfileRow(label: 'Experience', value: '${user.xp} XP'),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: softLinen.withValues(alpha: 0.2), height: 1),
                      ),

                      _ProfileRow(label: 'Active tasks', value: '${user.activeTaskCount}'),
                      _ProfileRow(label: 'Completed tasks', value: '${user.completedTaskCount}'),

                      if (character.abilities.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: softLinen.withValues(alpha: 0.2), height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            'Abilities',
                            style: TextStyle(
                              color: theme.colorScheme.primary, // Amethyst для підзаголовка
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        ...character.abilities.map(
                              (skill) => _ProfileRow(
                            label: skill,
                            value: "Active",
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

/// Віджет колекційної картки, адаптований під вашу палітру кольорів
class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.user,
    required this.character,
  });

  final AppUser user;
  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amethyst = theme.colorScheme.primary;
    final softLinen = theme.colorScheme.secondary;

    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Зображення персонажа (Аватар на весь фон картки)
              _buildAvatarImage(theme),

              // 3. Градієнт поверх картинки
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.surface.withValues(alpha: .03),
                          theme.colorScheme.surface.withValues(alpha: .08),
                          theme.colorScheme.surface.withValues(alpha: .25),
                          theme.colorScheme.surface.withValues(alpha: .55),
                          theme.colorScheme.surface.withValues(alpha: .82),
                        ],
                        stops: const [
                          0.00,
                          0.40,
                          0.58,
                          0.72,
                          0.84,
                          0.94,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Текстовий блок картки (Знизу)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Плашки: Команда (Amethyst) та Роль (Soft Linen)
                    Row(
                      children: [
                        if (user.teamId != null && user.teamId!.isNotEmpty)
                          StreamBuilder<Team?>(
                            stream: context.read<UserService>().watchTeam(user.teamId!),
                            builder: (context, teamSnapshot) {
                              final teamName = teamSnapshot.data?.name;
                              if (teamName == null || teamName.isEmpty) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: amethyst,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    teamName.toUpperCase(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role.label.toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface, // Текст на Linen робимо темним
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Заголовок: Назва/Ім'я персонажа
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            character.name.isEmpty ? 'Unknown Hero' : character.name,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        // П'ять декоративних зірочок (Soft Linen) з оригінального дизайну
                        Row(
                          children: List.generate(
                            character.level,
                                (index) => Icon(
                                    Icons.star,
                                    color: amethyst,
                                    size: 16
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Опис: Слоган персонажа
                    Text(
                      character.slogan.isEmpty
                          ? 'He wanders where history serves no memory. Investigating the arcane and forgotten.'
                          : character.slogan,
                      style: TextStyle(
                        color: softLinen,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),

                    // Тонкий лінійний розділювач кольору палітри
                    Container(
                      height: 1,
                      color: softLinen,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),

                    // Нижній колонтитул картки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '@${user.nickname}',
                          style: TextStyle(color: softLinen, fontSize: 11),
                        ),
                        Icon(Icons.diamond_outlined, color: amethyst, size: 14),
                        Text(
                          '©${user.createdAt.year} FORGE',
                          style: TextStyle(color: softLinen, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage(ThemeData theme) {
    final url = character.avatarUrl.trim();

    if (url.isEmpty) {
      return _buildPlaceholder(theme);
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),
      );
    }

    if (!kIsWeb) {
      final file = File(url);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(theme),);
      }
    }
    return _buildPlaceholder(theme);
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: theme.colorScheme.secondary.withValues(alpha: 0.7)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}