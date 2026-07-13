import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/theme_cubit/theme_cubit.dart';
import '../../../generated/l10n.dart';
import '../../../main.dart';
import '../../language/logic/lang_cubit/lang_cubit.dart';
import '../../notification/data/services/local_notification_services.dart';
import '../../notification/views/notification_page.dart';
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
          CustomScrollView(
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
    );
  }
}

