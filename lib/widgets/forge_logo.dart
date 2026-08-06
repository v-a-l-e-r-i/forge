import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Який асет рендерити. SVG — типовий варіант (чітко масштабується під
/// будь-який розмір); PNG — фолбек, якщо колись виникнуть проблеми з SVG.
enum ForgeLogoVariant { svg, png }

/// Спільний логотип Forge. Використовується на сплеш-екрані, логіні та
/// в картках/бейджах на кшталт того, що в NotificationsPage, щоб знак
/// виглядав однаково всюди.
///
/// Передай [onTap], щоб зробити лого клікабельним (наприклад, для показу
/// бренд-картки через showForgeBrandCard()). Якщо [onTap] — null, лого
/// рендериться як звичайне нективне зображення.
class ForgeLogo extends StatelessWidget {
  const ForgeLogo({
    super.key,
    this.size = 64,
    this.variant = ForgeLogoVariant.svg,
    this.fit = BoxFit.contain,
    this.onTap,
  });

  final double size;
  final ForgeLogoVariant variant;
  final BoxFit fit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = variant == ForgeLogoVariant.svg
        ? SvgPicture.asset(
      'assets/images/logo_forge.svg',
      width: size,
      height: size,
      fit: fit,
    )
        : Image.asset(
      'assets/images/logo_forge.png',
      width: size,
      height: size,
      fit: fit,
    );

    if (onTap == null) return image;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: image,
      ),
    );
  }
}