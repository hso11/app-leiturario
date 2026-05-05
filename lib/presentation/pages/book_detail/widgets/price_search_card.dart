import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/book.dart';
import '../../../../injection.dart';
import '../../../blocs/book_price/book_price_cubit.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';

class PriceSearchCard extends StatefulWidget {
  final Book book;
  const PriceSearchCard({super.key, required this.book});

  @override
  State<PriceSearchCard> createState() => _PriceSearchCardState();
}

class _PriceSearchCardState extends State<PriceSearchCard> {
  late final BookPriceCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<BookPriceCubit>();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<BookPriceCubit, BookPriceState>(
        builder: (context, state) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.mlPrices,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBody(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookPriceState state) {
    if (state is BookPriceInitial) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _cubit.search(widget.book.title, widget.book.author),
          icon: const Icon(Icons.search),
          label: const Text(AppStrings.mlSearchButton),
        ),
      );
    }

    if (state is BookPriceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BookPriceError) {
      return Column(
        children: [
          Text(
            AppStrings.mlError,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _cubit.search(widget.book.title, widget.book.author),
            child: const Text(AppStrings.mlRetry),
          ),
        ],
      );
    }

    if (state is BookPriceLoaded) {
      if (state.prices.isEmpty) {
        return Text(AppStrings.mlNoResults,
            style: Theme.of(context).textTheme.bodyMedium);
      }
      return Column(
        children: state.prices.map((price) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: price.thumbnail != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      price.thumbnail!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.book, size: 48),
                    ),
                  )
                : const Icon(Icons.book, size: 48),
            title: Text(
              price.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            subtitle: Text(
              _formatPrice(price.price, price.currencyId),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openUrl(price.url),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatPrice(double price, String currencyId) {
    final symbol = currencyId == 'BRL' ? 'R\$' : currencyId;
    return '$symbol ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
