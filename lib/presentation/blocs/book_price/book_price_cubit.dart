import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/services/mercado_livre_service.dart';
import '../../../domain/entities/book_price.dart';

part 'book_price_state.dart';

@injectable
class BookPriceCubit extends Cubit<BookPriceState> {
  final MercadoLivreService _mlService;

  BookPriceCubit(this._mlService) : super(BookPriceInitial());

  Future<void> search(String title, String author) async {
    emit(BookPriceLoading());
    try {
      final prices = await _mlService.search(title, author);
      emit(BookPriceLoaded(prices));
    } catch (e) {
      emit(BookPriceError(e.toString()));
    }
  }
}
