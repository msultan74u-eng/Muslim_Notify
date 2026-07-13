// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Muslim Notify`
  String get appTitle {
    return Intl.message('Muslim Notify', name: 'appTitle', desc: '', args: []);
  }

  /// `English`
  String get change {
    return Intl.message('English', name: 'change', desc: '', args: []);
  }

  /// `Current language: Arabic`
  String get currentLang {
    return Intl.message(
      'Current language: Arabic',
      name: 'currentLang',
      desc: '',
      args: [],
    );
  }

  /// `Item`
  String get item {
    return Intl.message('Item', name: 'item', desc: '', args: []);
  }

  /// `Prayer Times`
  String get azanMainTitle {
    return Intl.message(
      'Prayer Times',
      name: 'azanMainTitle',
      desc: '',
      args: [],
    );
  }

  /// `Customize each prayer individually`
  String get azanSubTitle {
    return Intl.message(
      'Customize each prayer individually',
      name: 'azanSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Makkah Adhan`
  String get haramAzan {
    return Intl.message('Makkah Adhan', name: 'haramAzan', desc: '', args: []);
  }

  /// `The sound of the call to prayer`
  String get adhanVoice {
    return Intl.message(
      'The sound of the call to prayer',
      name: 'adhanVoice',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Before Adhan`
  String get rememberAzam {
    return Intl.message(
      'Reminder Before Adhan',
      name: 'rememberAzam',
      desc: '',
      args: [],
    );
  }

  /// `Fajr`
  String get fajr {
    return Intl.message('Fajr', name: 'fajr', desc: '', args: []);
  }

  /// `Dhuhr`
  String get dhuhr {
    return Intl.message('Dhuhr', name: 'dhuhr', desc: '', args: []);
  }

  /// `Asr`
  String get asr {
    return Intl.message('Asr', name: 'asr', desc: '', args: []);
  }

  /// `Maghrib`
  String get maghrib {
    return Intl.message('Maghrib', name: 'maghrib', desc: '', args: []);
  }

  /// `Isha`
  String get ishaa {
    return Intl.message('Isha', name: 'ishaa', desc: '', args: []);
  }

  /// `Daily Adhkar`
  String get azkarMainTitle {
    return Intl.message(
      'Daily Adhkar',
      name: 'azkarMainTitle',
      desc: '',
      args: [],
    );
  }

  /// `Daily reminder at a fixed time`
  String get azkarSubTitle {
    return Intl.message(
      'Daily reminder at a fixed time',
      name: 'azkarSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `AM`
  String get am {
    return Intl.message('AM', name: 'am', desc: '', args: []);
  }

  /// `PM`
  String get pm {
    return Intl.message('PM', name: 'pm', desc: '', args: []);
  }

  /// `Morning Adhkar`
  String get azkarMorning {
    return Intl.message(
      'Morning Adhkar',
      name: 'azkarMorning',
      desc: '',
      args: [],
    );
  }

  /// `Evening Adhkar`
  String get azkarEvening {
    return Intl.message(
      'Evening Adhkar',
      name: 'azkarEvening',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Adhkar`
  String get azkarSleeping {
    return Intl.message(
      'Sleep Adhkar',
      name: 'azkarSleeping',
      desc: '',
      args: [],
    );
  }

  /// `Dhikr Reminder`
  String get dhikrMainTitle {
    return Intl.message(
      'Dhikr Reminder',
      name: 'dhikrMainTitle',
      desc: '',
      args: [],
    );
  }

  /// `Subhan Allah, Alhamdulillah, La ilaha illallah`
  String get dhikrSubTitle {
    return Intl.message(
      'Subhan Allah, Alhamdulillah, La ilaha illallah',
      name: 'dhikrSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enable Dhikr Reminder`
  String get dhikrEnable {
    return Intl.message(
      'Enable Dhikr Reminder',
      name: 'dhikrEnable',
      desc: '',
      args: [],
    );
  }

  /// `How often?`
  String get howOften {
    return Intl.message('How often?', name: 'howOften', desc: '', args: []);
  }

  /// `Repeat every`
  String get repeatEvery {
    return Intl.message(
      'Repeat every',
      name: 'repeatEvery',
      desc: '',
      args: [],
    );
  }

  /// `15 mins`
  String get every15Minutes {
    return Intl.message('15 mins', name: 'every15Minutes', desc: '', args: []);
  }

  /// `20 mins`
  String get every20Minutes {
    return Intl.message('20 mins', name: 'every20Minutes', desc: '', args: []);
  }

  /// `30 mins`
  String get every30Minutes {
    return Intl.message('30 mins', name: 'every30Minutes', desc: '', args: []);
  }

  /// `1 hour`
  String get every1Hour {
    return Intl.message('1 hour', name: 'every1Hour', desc: '', args: []);
  }

  /// `2 hours`
  String get every2Hours {
    return Intl.message('2 hours', name: 'every2Hours', desc: '', args: []);
  }

  /// `3 hours`
  String get every3Hours {
    return Intl.message('3 hours', name: 'every3Hours', desc: '', args: []);
  }

  /// `Do not disturb from 11 PM to 5 AM`
  String get doNotDisturb {
    return Intl.message(
      'Do not disturb from 11 PM to 5 AM',
      name: 'doNotDisturb',
      desc: '',
      args: [],
    );
  }

  /// `Prayers upon the Prophet ﷺ`
  String get prophetMainTitle {
    return Intl.message(
      'Prayers upon the Prophet ﷺ',
      name: 'prophetMainTitle',
      desc: '',
      args: [],
    );
  }

  /// `Periodic reminder, and it increases on Fridays`
  String get prophetSubTitle {
    return Intl.message(
      'Periodic reminder, and it increases on Fridays',
      name: 'prophetSubTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enable Prayers upon the Prophet`
  String get prophetEnable {
    return Intl.message(
      'Enable Prayers upon the Prophet',
      name: 'prophetEnable',
      desc: '',
      args: [],
    );
  }

  /// `Every`
  String get every {
    return Intl.message('Every', name: 'every', desc: '', args: []);
  }

  /// `Hour`
  String get hour {
    return Intl.message('Hour', name: 'hour', desc: '', args: []);
  }

  /// `Hours`
  String get hours {
    return Intl.message('Hours', name: 'hours', desc: '', args: []);
  }

  /// `Minutes`
  String get minutes {
    return Intl.message('Minutes', name: 'minutes', desc: '', args: []);
  }

  /// `Increase reminders on Friday`
  String get fridayBoost {
    return Intl.message(
      'Increase reminders on Friday',
      name: 'fridayBoost',
      desc: '',
      args: [],
    );
  }

  /// `It is Sunnah to send many blessings upon the Prophet ﷺ on Friday`
  String get fridayBoostDesc {
    return Intl.message(
      'It is Sunnah to send many blessings upon the Prophet ﷺ on Friday',
      name: 'fridayBoostDesc',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
