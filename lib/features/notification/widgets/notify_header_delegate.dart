import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:muslim_notify/core/themes/app_colors.dart';

import '../../../core/themes/app_text_styles.dart';
import '../../../core/utils/app_functions.dart';

class NotifyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const NotifyHeaderDelegate({
    required this.maxHeight,
    required this.minHeight,
    this.onTap,
    this.onBack,
  });

  final double maxHeight; //  (Expanded) Header in open Mode
  final double minHeight; //  (Collapsed) Header in closed Mode
  final VoidCallback? onBack;
  final VoidCallback? onTap;

  ///  maxHeight = 280  ,  minHeight = 56
  // expandedAvatarSize = 280 * 0.66 = 184.8   →  avatarSize = 184.8 in Expanded Mode
  double get expandedAvatarSize => maxHeight * 0.64;

  // collapsedAvatarSize = 40.0  →  avatarSize = 40.0 in Expanded Mode
  static const double collapsedAvatarSize = 52.0;

  //  Sliver (SliverPersistentHeaderDelegate)
  //  → the max and min  height of the header should determined
  @override
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;

  // make Flutter rebuild if any of the values above changed
  @override
  bool shouldRebuild(covariant NotifyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        onBack != oldDelegate.onBack ||
        onTap != oldDelegate.onTap;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset, // مقدار انكماش
    bool overlapsContent,
  ) {
    // t = if value of shrink is (0.0) → open
    // value of shrink is (1.0) → closed
    // it use every lerp between opening value and closed value
    final double t = (shrinkOffset / (maxHeight - minHeight)).clamp(0.0, 1.0);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // ── image size ──
    final double avatarSize = lerpDouble(
      expandedAvatarSize,
      collapsedAvatarSize,
      t,
    )!;

    final double startRadius = avatarSize / 2;
    final double endRadius = avatarSize / 2;
    final double borderRadius = lerpDouble(startRadius, endRadius, t)!;

    final double expandedAvatarLeft = screenWidth / 2 - expandedAvatarSize / 2;
    final double expandedAvatarTop = statusBarHeight + 28;

    // ── مكان الصورة وهي Collapsed (على الشمال جنب الـ AppBar) ──
    final double collapsedAvatarLeft = 12.0;
    final double collapsedAvatarTop =
        statusBarHeight +
        (minHeight - statusBarHeight - collapsedAvatarSize) / 2;

    // احداثيات الصورة الفعلية = تدرج بين مكانها في الحالتين حسب t
    final double avatarLeft = lerpDouble(
      expandedAvatarLeft,
      collapsedAvatarLeft,
      t,
    )!;

    final double avatarTop = lerpDouble(
      expandedAvatarTop,
      collapsedAvatarTop,
      t,
    )!;

    // ── name text ──
    final String nameText = 'Muslim Notify';
    // حجم الخط بيصغر شوية وهو بيتقفل (من 18 لـ 15)
    final double nameFontSize = lerpDouble(18.0, 15.0, t)!;

    // مكان الاسم وهو Expanded = تحت الصورة الكبيرة
    final double expandedNameTop = expandedAvatarTop + expandedAvatarSize + 12;

    // مكان الاسم وهو Collapsed = جنب الصورة الصغيرة يمين شوية
    final double collapsedNameLeft =
        collapsedAvatarLeft + collapsedAvatarSize + 10;
    final double collapsedNameTop =
        statusBarHeight + (minHeight - statusBarHeight - nameFontSize) / 2;

    // بنستخدم TextPainter عشان نعرف عرض النص الفعلي (بحجم الخط الحالي)
    // عشان نقدر نتوسطه أفقيًا وهو Expanded بدون ما نستخدم Widget فعلي
    final textPainter = TextPainter(
      text: TextSpan(
        text: nameText,
        style: TextStyle(fontSize: nameFontSize, color: AppColors.primary_300),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    // نتوسط النص أفقيًا في الشاشة وهو Expanded بناءً على عرضه الحقيقي
    final double expandedNameLeft = (screenWidth - textPainter.width) / 2;

    // احداثيات الاسم الفعلية = تدرج بين الحالتين حسب t
    final double nameLeft = lerpDouble(expandedNameLeft, collapsedNameLeft, t)!;
    final double nameTop = lerpDouble(expandedNameTop, collapsedNameTop, t)!;

    // لون اسم ثابت حاليًا (onSurface في الحالتين)
    // ملحوظة: ممكن تتشال الـ lerp دي لو مش هتغير اللون فعليًا، لأنها بترجع نفس القيمة دايمًا
    final Color nameColor = Color.lerp(
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primary,
      t,
    )!;

    // ── bg color ──
    // خلفية الهيدر بتبدأ شفافة (Expanded) وتتحول لـ surface color وهي بتتقفل
    final Color bgColor = Color.lerp(
      Colors.transparent,
      Theme.of(context).colorScheme.surface,
      t,
    )!;

    return Stack(
      clipBehavior: Clip
          .none, // عشان الصورة لما تكون كبيرة متتقصش لو خرجت بره حدود الهيدر
      children: [
        // ── Gradient Background ──
        // جراديانت خفيف جدًا (شفافية 8% و5%) بيدي إحساس عمق بسيط في الخلفية
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.08),
                  Colors.blue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // الخلفية الأساسية اللي بتتحول تدريجيًا من شفافة لـ surface color وهي بتتقفل
        Positioned.fill(child: Container(color: bgColor)),

        // ── الصورة (Avatar) ──
        Positioned(
          top: avatarTop,
          left: isArabic() ? null : avatarLeft,
          right: isArabic() ? avatarLeft : null,
          child: Stack(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/muslim_notify.png'),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── الاسم (Name Text) ──
        Positioned(
          left: isArabic() ? null : nameLeft,
          right: isArabic() ? nameLeft : null,
          top: nameTop,
          child: Text(
            nameText,

            style: AppTextStyles.lSemiBold
                .copyWith(color: nameColor)
                .copyWith(color: nameColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        Positioned(
          top: collapsedNameTop,
          right: isArabic() ? null : 12,
          left: isArabic() ? 12 : null,
          child: Icon(Icons.menu),
        ),
      ],
    );
  }
}
