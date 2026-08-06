import 'package:flutter/material.dart';

import 'forge_logo.dart';

/// Окрема кольорова палітра для бренд-картки — навмисно не прив'язана до
/// теми застосунку (ForgeAdminColors тощо), щоб цей файл однаково працював
/// і в мобільному застосунку, і в адмінці без змін.
class ForgeBrandColors {
  static const background = Color(0xFF121317);
  static const accent = Color(0xFF9B4DEB);
  static const border = Color(0x4D9B4DEB); // accent @ ~30% opacity
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFA6A6B3);
}

/// Показує бренд-картку Forge як центрований оверлей. Вхід — "spin in":
/// обертання + збільшення + fade, з легким перебігом через
/// Curves.easeOutBack.
///
/// NOTE: текст тут захардкоджений українською (на відміну від Command
/// Center, де є AppLocalizations) — мобільний застосунок поки без l10n.
/// Якщо потрібна локалізація — скажи, підключимо той самий ARB-патерн.
Future<void> showForgeBrandCard(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Forge brand card',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const Center(child: _ForgeBrandCard());
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: (1 - curved.value) * -0.35,
          child: Transform.scale(
            scale: curved.value,
            child: child,
          ),
        ),
      );
    },
  );
}

class _ForgeBrandCard extends StatelessWidget {
  const _ForgeBrandCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 580),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ForgeBrandColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ForgeBrandColors.border),
          boxShadow: [
            BoxShadow(
              color: ForgeBrandColors.accent.withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  ForgeLogo(size: 40),
                  SizedBox(width: 12),
                  Text(
                    'Forge',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: ForgeBrandColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'ГЕЙМІФІКОВАНИЙ РОБОЧИЙ ПРОСТІР',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: ForgeBrandColors.accent,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: ForgeBrandColors.border, height: 1),
              const SizedBox(height: 20),
              const _InfoRow(
                icon: Icons.groups_outlined,
                title: 'ДЛЯ КОГО',
                description:
                'Для команд, які хочуть перетворити щоденні задачі на квести — з рівнями, XP та прогресом, який видно всім.',
              ),
              const SizedBox(height: 20),
              const Divider(color: ForgeBrandColors.border, height: 1),
              const SizedBox(height: 20),
              const _InfoRow(
                icon: Icons.code_rounded,
                title: 'ЩО ЦЕ',
                description:
                'Forge поєднує трекінг задач із ігровою механікою: герої виконують квести, отримують досвід і ростуть разом із командою.',
              ),
              const SizedBox(height: 24),
              const Divider(color: ForgeBrandColors.border, height: 1),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FeatureChip(
                    icon: Icons.rocket_launch_outlined,
                    title: 'ІННОВАЦІЙНО',
                    subtitle: 'Ігрова\nмеханіка',
                  ),
                  _FeatureChip(
                    icon: Icons.verified_user_outlined,
                    title: 'НАДІЙНО',
                    subtitle: 'Firebase\nу основі',
                  ),
                  _FeatureChip(
                    icon: Icons.trending_up_rounded,
                    title: 'ЕФЕКТИВНО',
                    subtitle: 'Видимий\nпрогрес',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ForgeBrandColors.border, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: ForgeBrandColors.accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: ForgeBrandColors.accent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: ForgeBrandColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: ForgeBrandColors.accent),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: ForgeBrandColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: ForgeBrandColors.textSecondary),
        ),
      ],
    );
  }
}