import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lang_state.dart';

class LangCubit extends Cubit<LangState> {
  static const String _langKey = 'app_lang';

  LangCubit() : super(LangInitial()) {
    _loadSavedLang();
  }

  Future<void> _loadSavedLang() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_langKey) ?? 'en';
    emit(LangLoaded(Locale(savedLang)));
  }

  Future<void> changeLang(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
    emit(LangLoaded(Locale(langCode)));
  }

  Future<void> toggleLang() async {
    final current = state;
    if (current is LangLoaded) {
      final newLang = current.locale.languageCode == 'en' ? 'ar' : 'en';
      await changeLang(newLang);
    }
  }
}
