import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'app_locale';

  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<LoadStoredLocale>(_onLoadStoredLocale);
    on<ChangeLocale>(_onChangeLocale);
  }

  Future<void> _onLoadStoredLocale(
    LoadStoredLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey) ?? 'en';
    emit(LocaleState(Locale(code)));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, event.localeCode);
    emit(LocaleState(Locale(event.localeCode)));
  }
}
