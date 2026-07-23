import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class PulsingRippleIcon extends StatefulWidget {
  const PulsingRippleIcon({
    super.key,
    this.size = 240,
    this.imagePath = 'assets/images/muslim_notify.png',
    this.imageSize = 62,
  });

  /// المساحة الكلية اللي هتاخدها الويدجت (الدوائر بتتحرك جواها)
  final double size;

  /// مسار الصورة اللي هتظهر في النص
  final String imagePath;

  final double imageSize;

  @override
  State<PulsingRippleIcon> createState() => _PulsingRippleIconState();
}

class _PulsingRippleIconState extends State<PulsingRippleIcon>
    with TickerProviderStateMixin {
  // كنترولر الدوائر المتموجة (Ripple) اللي بتتحرك من حوالين الأيقونة
  // عشان توحي إن الصوت شغال وبينتشر
  late final AnimationController _rippleController;

  // كنترولر توهج خفيف حوالين الأيقونة (Glow pulsing)
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3 دوائر متموجة بتتحرك للخارج بشكل متتابع
          ..._buildRipples(),

          // توهج خفيف حوالين الأيقونة
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final glow = 0.4 + (_glowController.value * 0.4);
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(glow * 0.6),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Image.asset(
              widget.imagePath,
              width: widget.imageSize,
              height: widget.imageSize,
            ),
          ),
        ],
      ),
    );
  }

  /// بيبني 3 دوائر بتتوسع وتختفي بالتتابع، بشكل مستمر، حوالين الأيقونة
  List<Widget> _buildRipples() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          // كل دايرة بتبدأ حركتها متأخرة شوية عن اللي قبلها
          final delay = index * 0.33;
          var progress = (_rippleController.value - delay) % 1.0;
          if (progress < 0) progress += 1.0;

          final size = 100 + (progress * 140);
          final opacity = (1.0 - progress).clamp(0.0, 1.0);

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary_25.withOpacity(opacity * 0.5),
                width: 1.5,
              ),
            ),
          );
        },
      );
    });
  }
}
