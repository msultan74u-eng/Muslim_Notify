import 'dart:ui';

sealed class LangState {}

final class LangInitial extends LangState {}

final class LangLoaded extends LangState {
  final Locale locale;

  LangLoaded(this.locale);
}
