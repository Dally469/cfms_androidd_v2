

import '../../../models/country_model.dart';

abstract class CountryState {}

class CountryInitial extends CountryState {}

class CountryLoading extends CountryState {}

class CountryLoaded extends CountryState {
  final List<CountryModel> countries;
  CountryLoaded({required this.countries});
}

class CountryError extends CountryState {
  final String errorMessage; // Add error message to state
  CountryError({required this.errorMessage});
}
