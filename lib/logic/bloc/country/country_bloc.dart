import 'package:cfms/models/country_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/country_repository.dart';
import 'country_event.dart';
import 'country_state.dart';

class CountryBloc extends Bloc<CountryEvent, CountryState> {
  final CountryRepository countryRepository;

  CountryBloc({required this.countryRepository}) : super(CountryInitial()) {
    on<FetchCountries>(_onFetchCountries); // Register the event handler
  }

  // Event handler for FetchCountries
  Future<void> _onFetchCountries(
      FetchCountries event, Emitter<CountryState> emit) async {
    try {
      emit(CountryLoading());
      final countries = await countryRepository.fetchCountries();
      emit(CountryLoaded(countries: countries));
    } catch (e) {
      emit(CountryError(
          errorMessage:
              'Failed to load countries: ${e.toString()}')); // Pass error message
    }
  }
}
