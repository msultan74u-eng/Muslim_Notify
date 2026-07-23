import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';

class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key});

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _equalizerController;

  @override
  void initState() {
    super.initState();

    _equalizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _equalizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // كل عمود له إيقاع مختلف شوية عشان الحركة متبقاش متزامنة بشكل ممل
    const heightFactors = [0.4, 0.8, 1.0, 0.6, 0.9, 0.5];

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(heightFactors.length, (index) {
          return AnimatedBuilder(
            animation: _equalizerController,
            builder: (context, child) {
              final t = _equalizerController.value;
              final factor = heightFactors[index];

              // إزاحة بسيطة بين الأعمدة عشان تبان متموجة مش متزامنة
              final wave = (t + (index * 0.15)) % 1.0;
              final barHeight = 10 + (wave * 30 * factor);

              return Container(
                width: 5,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning_100,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}



