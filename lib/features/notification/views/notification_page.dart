import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/theme_cubit/theme_cubit.dart';
import '../../../generated/l10n.dart';
import '../../language/logic/lang_cubit/lang_cubit.dart';
import '../../notification/widgets/adhan_card.dart';
import '../../notification/widgets/adhkar_card.dart';
import '../../notification/widgets/dhikr_card.dart';
import '../../notification/widgets/notify_header_delegate.dart';
import '../../notification/widgets/salawat_card.dart';
import '../../notification/widgets/section_title.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const double _minHeaderHeight = 56.0;

  /// initial state

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double height = MediaQuery.of(context).size.height;
    final double maxHeaderHeight = height * 0.36;

    // ── لون أيقونات status bar حسب الثيم الحالي ──
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // مهم عشان مفيش خط/فجوة لون تاني
        statusBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark, // Android
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: NotifyHeaderDelegate(
                    maxHeight: maxHeaderHeight,
                    minHeight: statusBarHeight + _minHeaderHeight,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),

                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SectionTitle(
                        icon: Icons.access_time_filled_rounded,
                        // title: 'مواعيد الأذان',
                        title:S.of(context).azanMainTitle,
                        subtitle: S.of(context).azanSubTitle,
                      ),
                      const SizedBox(height: 12),
                      AdhanCard(),
                      const SizedBox(height: 12),
                      SectionTitle(
                        icon: Icons.wb_twilight_rounded,
                        title: S.of(context).azkarMainTitle,
                        subtitle: S.of(context).azkarSubTitle,
                      ),
                      const SizedBox(height: 12),
                      AdhkarCard(),
                      // const SizedBox(height: 12),
                      // SectionTitle(
                      //   icon: Icons.favorite_rounded,
                      //   title: S.of(context).dhikrMainTitle,
                      //   subtitle: S.of(context).dhikrSubTitle,
                      // ),
                      // const SizedBox(height: 12),
                      // DhikrCard(),
                      const SizedBox(height: 12),
                      SectionTitle(
                        icon: Icons.mosque_rounded,
                        title: S.of(context).prophetMainTitle,
                        subtitle: S.of(context).prophetSubTitle,
                      ),
                      const SizedBox(height: 12),
                      SalawatCard(),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final themeCubit = context.read<ThemeCubit>();
                          if (themeCubit.state == ThemeMode.dark) {
                            themeCubit.updateTheme(ThemeMode.light);
                          } else {
                            themeCubit.updateTheme(ThemeMode.dark);
                          }
                        },
                        child: const Text('Change Theme'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<LangCubit>().toggleLang();
                        },
                        child: Text(S.of(context).change),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
