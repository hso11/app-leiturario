import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../domain/entities/book.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';

class PriceSearchCard extends StatelessWidget {
  final Book book;
  const PriceSearchCard({super.key, required this.book});

  Future<void> _openMercadoLivre() async {
    final query = Uri.encodeComponent('${book.title.trim()} ${book.author.trim()}');
    await launchUrl(
      Uri.parse('https://lista.mercadolivre.com.br/livros-revistas-comics/$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openAmazon() async {
    final query = Uri.encodeQueryComponent('${book.title.trim()} ${book.author.trim()}');
    await launchUrl(
      Uri.parse('https://www.amazon.com.br/s?k=$query'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openMercadoLivre,
                icon: const Icon(Icons.open_in_new),
                label: const Text(AppStrings.mlSearchButton),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openAmazon,
                icon: const Icon(Icons.open_in_new),
                label: const Text(AppStrings.amazonSearchButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
