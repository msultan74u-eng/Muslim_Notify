import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/themes/theme_cubit/theme_cubit.dart';
import 'features/language/logic/lang_cubit/lang_cubit.dart';
import 'generated/l10n.dart';

class SettingDrawer extends StatelessWidget {
  const SettingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select<ThemeCubit, bool>(
      (cubit) => cubit.state == ThemeMode.dark,
    );
    final s = S.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                  s.settings,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: Text(isDarkMode ? s.darkMode : s.lightMode),
                    value: isDarkMode,
                    onChanged: (value) {
                      context.read<ThemeCubit>().updateTheme(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(s.change),
                    onTap: () {
                      context.read<LangCubit>().toggleLang();
                      Navigator.pop(context);
                    },
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
