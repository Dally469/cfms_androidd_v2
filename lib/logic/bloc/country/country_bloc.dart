import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/country_repository.dart';
import 'country_event.dart';
import 'country_state.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  final CountryRepository repository;

  CountryBloc({required this.repository}) : super(CountryInitial()) {
    on<FetchCountries>(_onFetchCountries);
  }

  Future<void> _onFetchCountries(
    FetchCountries event,
    Emitter<CountryState> emit,
  ) async {
    emit(CountryLoading());
    try {
      final countries = await repository.getCountrySuggestions(event.query);
      emit(CountryLoaded(countries));
    } catch (e) {
      emit(CountryError('Failed to fetch countries: ${e.toString()}'));
    }
  }
}
