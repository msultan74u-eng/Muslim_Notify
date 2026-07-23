import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/theme_cubit/theme_cubit.dart';
import '../../../generated/l10n.dart';
import '../../language/logic/lang_cubit/lang_cubit.dart';
import '../../nav_bar/nav_bar_cubit/nav_bar_cubit.dart';
import '../../notification/widgets/notify_header_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // static const double _maxHeaderHeight = 280.0;
  static const double _minHeaderHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height;
    double maxHeaderHeight = height * 0.36;

    return Scaffold(
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
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ListTile(
                      title: Text('${S.of(context).item} → ${(index + 1)}'),
                    ),
                    childCount: 15,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          ),
          BlocBuilder<NavBarCubit, bool>(
            builder: (context, isVisible) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(bottom: isVisible ? 56 : 0),
                child: Align(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
