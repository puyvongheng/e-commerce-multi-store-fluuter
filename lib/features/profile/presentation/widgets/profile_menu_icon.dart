import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenuIcon extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String label;
  final Color? color;
  final double? width;
  final VoidCallback? onTap;

  const ProfileMenuIcon({
    super.key,
    this.icon,
    this.svgPath,
    required this.label,
    this.color,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width ?? 60,
        child: Column(
          children: [
            Container(
              height: 26,
              width: 26,
              alignment: Alignment.center,
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath!,
                      width: 26,
                      height: 26,
                      colorFilter: color != null
                          ? ColorFilter.mode(color!, BlendMode.srcIn)
                          : null,
                    )
                  : Icon(icon, color: color, size: 26),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
