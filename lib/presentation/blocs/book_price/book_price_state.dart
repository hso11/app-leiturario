part of 'book_price_cubit.dart';

abstract class BookPriceState {}

class BookPriceInitial extends BookPriceState {}

class BookPriceLoading extends BookPriceState {}

class BookPriceLoaded extends BookPriceState {
  final List<BookPrice> prices;
  BookPriceLoaded(this.prices);
}

class BookPriceError extends BookPriceState {
  final String message;
  BookPriceError(this.message);
}
