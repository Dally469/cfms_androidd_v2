import 'package:equatable/equatable.dart';

abstract class CountryEvent extends Equatable {
  const CountryEvent();

  @override
  List<Object> get props => [];
}

class FetchCountries extends CountryEvent {
  final String query;

  const FetchCountries({this.query = ""});

  @override
  List<Object> get props => [query];
}
