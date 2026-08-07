import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/character.dart';
import '../../models/team.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

/// Standalone-варіант з власним AppBar — використовується лише якщо
/// сторінка відкривається напряму, поза AppShell (наприклад deep-link).
class HeroesPage extends StatelessWidget {
  const HeroesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Герої'),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        bottomOpacity: 0,
      ),
      body: const HeroesBody(),
    );
  }
}

enum _HeroFilter { all, myTeam }

/// Вміст сторінки "Герої" — без Scaffold/AppBar, щоб вбудовуватись як таб
/// у AppShell так само, як окремою сторінкою.
class HeroesBody extends StatefulWidget {
  const HeroesBody({super.key});

  @override
  State<HeroesBody> createState() => _HeroesBodyState();
}

class _HeroesBodyState extends State<HeroesBody> {
  _HeroFilter _filter = _HeroFilter.all;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userService = context.read<UserService>();
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<AppUser?>(
      stream: authService.watchCurrentAppUser(),
      builder: (context, meSnapshot) {
        final me = meSnapshot.data;
        if (me == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return StreamBuilder<List<AppUser>>(
          stream: userService.watchAllUsers(),
          builder: (context, usersSnapshot) {
            if (!usersSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var heroes = usersSnapshot.data!;

            if (_filter == _HeroFilter.myTeam) {
              heroes = heroes.where((h) => h.teamId != null && h.teamId == me.teamId).toList();
            }
            if (_query.isNotEmpty) {
              heroes = heroes
                  .where((h) =>
              h.nickname.toLowerCase().contains(_query) ||
                  h.name.toLowerCase().contains(_query))
                  .toList();
            }
            heroes.sort((a, b) => b.xp.compareTo(a.xp));

            return StreamBuilder<Map<String, Character>>(
              stream: userService.watchAllCharacters(),
              builder: (context, charSnapshot) {
                final charactersByUid = charSnapshot.data ?? const {};

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _FilterButton(
                                label: 'Усі',
                                count: _filter == _HeroFilter.all ? heroes.length : null,
                                isSelected: _filter == _HeroFilter.all,
                                onTap: () => setState(() => _filter = _HeroFilter.all),
                              ),
                              const SizedBox(width: 8),
                              _FilterButton(
                                label: 'Моя команда',
                                count: _filter == _HeroFilter.myTeam ? heroes.length : null,
                                isSelected: _filter == _HeroFilter.myTeam,
                                onTap: () => setState(() => _filter = _HeroFilter.myTeam),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value.trim().toLowerCase()),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Пошук за ніком або іменем',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: heroes.isEmpty
                          ? Center(
                        child: Text(
                          _filter == _HeroFilter.myTeam && me.teamId == null
                              ? 'Ти поки не в команді'
                              : 'Нікого не знайдено',
                          style: TextStyle(color: colors.secondary.withValues(alpha: 0.6)),
                        ),
                      )
                          : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            itemCount: heroes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final hero = heroes[index];
                              return _HeroListTile(
                                hero: hero,
                                character: charactersByUid[hero.id],
                                isMe: hero.id == me.id,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colors.primary.withValues(alpha: 0.14) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.6)
                  : colors.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            count == null ? label : '$label ($count)',
            style: TextStyle(
              color: isSelected ? colors.primary : colors.onSurface,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroListTile extends StatelessWidget {
  const _HeroListTile({required this.hero, required this.character, required this.isMe});

  final AppUser hero;
  final Character? character;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatarUrl = character?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.startsWith('http');

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _HeroDetailSheet.show(context, hero, character),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colors.primary,
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Text(
                  hero.nickname.isNotEmpty ? hero.nickname[0].toUpperCase() : '?',
                  style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '@${hero.nickname}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'ти',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${hero.role.label} · Lv. ${hero.level} · ${hero.xp} XP',
                      style: TextStyle(
                        color: colors.secondary.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: colors.secondary.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroDetailSheet extends StatelessWidget {
  const _HeroDetailSheet({required this.hero, required this.character});

  final AppUser hero;
  final Character? character;


  static Future<void> show(BuildContext context, AppUser hero, Character? character) {
    return showDialog(
      context: context,
      builder: (_) => _HeroDetailSheet(hero: hero, character: character),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatarUrl = character?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final userService = context.read<UserService>();

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 380;
            if (character == null) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.inverseSurface),
                ),
                child: const Center(
                  child: Text('Дані персонажа відсутні'),
                ),
              );
            }
            return _buildCharacterCard(context, character!, isNarrow: isNarrow);
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              StreamBuilder<Team?>(
                stream:
                hero.teamId != null ? userService.watchTeam(hero.teamId!) : Stream.value(null),
                builder: (context, teamSnapshot) => _DetailRow(
                  label: 'Команда',
                  value: teamSnapshot.data?.name ?? '—',
                ),
              ),
              _DetailRow(label: 'Досвід', value: '${hero.xp} XP'),
              _DetailRow(label: 'Активні квести', value: '${hero.activeTaskCount}'),
              _DetailRow(
                label: 'Завершені квести',
                value: '${hero.completedTaskCount}',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );

    // insetPadding на mobile: 16 з кожного боку => 32 забирається від
    // ширини екрана. maxWidth рахуємо від цього, а не фіксованою половиною
    // екрана (був баг: screenSize.width / 2 обрізав картку вдвічі).
    final mobileInsetHorizontal = 16.0;
    final mobileMaxWidth = screenSize.width - (mobileInsetHorizontal * 2);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile
          ? EdgeInsets.symmetric(horizontal: mobileInsetHorizontal, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? mobileMaxWidth : 480,
          maxHeight: screenSize.height * 0.8,
        ),
        // SingleChildScrollView — щоб довгий слоган/багато abilities не
        // давали RenderFlex overflow на низьких мобільних екранах, а
        // просто скролились всередині картки.
        child: SingleChildScrollView(child: content),
      ),
    );
  }

  Widget _buildCharacterCard(BuildContext context, Character character, {required bool isNarrow}) {
    final avatarUrl = character.avatarUrl;
    final hasAvatar = avatarUrl.isNotEmpty;

    final colors = Theme.of(context).colorScheme;

    final image = hasAvatar
        ? Image.network(
      avatarUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: colors.surface,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: colors.surface,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: colors.onSurface,
          ),
        ),
      ),
    )
        : null;

    final infoContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        const SizedBox(height: 20),
        if (character.slogan.isNotEmpty)
          Text(
            '"${character.slogan}"',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: colors.onSurface,
            ),
          ),
        if (character.abilities.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final ability in character.abilities)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ability,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );

    // Вузько (телефон або вузьке вікно): фото зверху на всю ширину,
    // портретне співвідношення сторін (3:4), щоб персонаж було видно
    // повністю, а не тонкою смужкою.
    if (isNarrow || image == null) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.inverseSurface),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              AspectRatio(
                aspectRatio: 5/6,
                child: image,
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: infoContent,
            ),
          ],
        ),
      );
    }

    // Широко (десктоп/планшет): більше, чітко видиме фото зліва,
    // інфо праворуч.
    return Container(
      clipBehavior: Clip.antiAlias,
      height: 320,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.inverseSurface),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 170, child: image),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(child: infoContent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            '@${hero.nickname}',
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        Text(
          '${hero.role.label} · Lv. ${hero.level}',
          style: TextStyle(
            color: colors.secondary.withValues(alpha: 0.65),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.secondary.withValues(alpha: 0.65), fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}