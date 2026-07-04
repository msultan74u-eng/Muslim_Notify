import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../language/logic/lang_cubit/lang_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(S.of(context).appTitle),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  child: IconButton(
                    onPressed: () {
                      context.read<LangCubit>().toggleLang();
                    },
                    icon: const Icon(Icons.language, color: Colors.blue),
                  ),
                ),
                Text(
                  S.of(context).change,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(S.of(context).currentLang)],
        ),
      ),
    );
  }
}
