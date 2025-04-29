import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_address_list_usecase.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetAddressListUseCase getAddressListUseCase;

  AddressBloc({required this.getAddressListUseCase}) : super(AddressInitial()) {
    on<GetAddressListEvent>(_onGetAddressList);
  }

  Future<void> _onGetAddressList(
    GetAddressListEvent event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    try {
      final result = await getAddressListUseCase();

      result.fold(
        (failure) => emit(AddressError(message: failure.message)),
        (addresses) => emit(AddressLoaded(addresses: addresses)),
      );
    } catch (e) {
      emit(AddressError(message: e.toString()));
    }
  }
}