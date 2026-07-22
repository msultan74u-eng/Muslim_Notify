import 'package:flutter/material.dart';

import 'card_shell.dart';

class LoadingCard extends StatefulWidget {
  const LoadingCard({super.key, required this.isDark, required this.height});

  final bool isDark;
  final double height;

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.40,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      isDark: widget.isDark,
      child: SizedBox(
        height: widget.height,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Image.asset(
              'assets/images/muslim_notify.png',
              width: 120,
              height: 120,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingCardMain extends StatefulWidget {
  const LoadingCardMain({
    super.key,
    required this.isDark,
    required this.height,
  });

  final bool isDark;
  final double height;

  @override
  State<LoadingCardMain> createState() => _LoadingCardMainState();
}

class _LoadingCardMainState extends State<LoadingCardMain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  static const double _logoSize = 120;
  static const double _haloMaxSize = 160;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Logo: gentle pulse in place.
    _logoScale = Tween<double>(
      begin: 0.92,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Halo: grows while it fades — reads as a "ring" breathing outward
    // from behind the logo rather than a flat circle scaling in sync.
    _haloScale = Tween<double>(
      begin: 0.85,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _haloOpacity = Tween<double>(
      begin: 0.28,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SizedBox(
              width: _haloMaxSize,
              height: _haloMaxSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing halo ring behind the logo.
                  Opacity(
                    opacity: _haloOpacity.value,
                    child: Transform.scale(
                      scale: _haloScale.value,
                      child: Container(
                        width: _haloMaxSize,
                        height: _haloMaxSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(
                            0xFF2E8B57,
                          ), // swap for AppColors.primary_300
                        ),
                      ),
                    ),
                  ),

                  // Logo, clipped to a circle, pulsing on its own.
                  Transform.scale(
                    scale: _logoScale.value,
                    child: ClipOval(
                      child: Container(
                        width: _logoSize,
                        height: _logoSize,
                        color: widget.isDark
                            ? Colors.white
                            : Colors.transparent,
                        child: Image.asset(
                          'assets/images/muslim_notify.png',
                          width: _logoSize,
                          height: _logoSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
