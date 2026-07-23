import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../../../setting_drawer.dart';
import '../../nav_bar/nav_bar_cubit/nav_bar_cubit.dart';
import '../../notification/widgets/adhan_card.dart';
import '../../notification/widgets/adhkar_card.dart';
import '../../notification/widgets/notify_header_delegate.dart';
import '../../notification/widgets/salawat_card.dart';
import '../../notification/widgets/section_title.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _minHeaderHeight = 56.0;

  /// initial state

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final double height = MediaQuery.of(context).size.height;
    final double maxHeaderHeight = height * 0.36;

    final isDark = context.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const SettingDrawer(),
        body: Stack(
          children: [
            NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final cubit = context.read<NavBarCubit>();
                if (notification.direction == ScrollDirection.forward) {
                  cubit.show();
                } else if (notification.direction == ScrollDirection.reverse) {
                  cubit.hide();
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: NotifyHeaderDelegate(
                      maxHeight: maxHeaderHeight,
                      minHeight: statusBarHeight + _minHeaderHeight,
                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SectionTitle(
                          icon: Icons.access_time_filled_rounded,
                          title: S.of(context).azanMainTitle,
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

                        const SizedBox(height: 12),
                        SectionTitle(
                          icon: Icons.mosque_rounded,
                          title: S.of(context).prophetMainTitle,
                          subtitle: S.of(context).prophetSubTitle,
                        ),
                        const SizedBox(height: 12),
                        SalawatCard(),
                        BlocBuilder<NavBarCubit, bool>(
                          builder: (context, isVisible) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              height: isVisible ? 56 : 0,
                            );
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
