import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/book_grid_card.dart';

class ReadingTab extends StatelessWidget {
  const ReadingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksLoaded) {
          final books = state.reading;
          if (books.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Nenhum livro em leitura.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('Arraste um livro de "A ler" para começar.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) => BookGridCard(book: books[index]),
          );
        }
        if (state is BookError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
