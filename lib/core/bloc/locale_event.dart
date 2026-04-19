part of 'locale_bloc.dart';

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object> get props => [];
}

class ChangeLocale extends LocaleEvent {
  final String localeCode;

  const ChangeLocale(this.localeCode);

  @override
  List<Object> get props => [localeCode];
}

class LoadStoredLocale extends LocaleEvent {}
