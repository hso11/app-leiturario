import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/book.dart';
import '../widgets/book_grid_card.dart';

class WantToReadTab extends StatelessWidget {
  const WantToReadTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksLoaded) {
          final books = state.wantToRead;
          return Column(
            children: [
              _DropZone(books: books),
              Expanded(
                child: books.isEmpty
                    ? const Center(
                        child: Text('Nenhum livro na lista.',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) =>
                            _DraggableBookCard(book: books[index]),
                      ),
              ),
            ],
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

class _DropZone extends StatefulWidget {
  final List<Book> books;
  const _DropZone({required this.books});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Book>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _isHovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        context
            .read<BookBloc>()
            .add(BookMoveToReadingRequested(details.data.id));
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.reading.withOpacity(0.3)
                : AppColors.reading.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovering ? AppColors.reading : AppColors.reading.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow,
                  color: _isHovering ? AppColors.reading : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                AppStrings.dragToRead,
                style: TextStyle(
                  color: _isHovering ? AppColors.reading : AppColors.textSecondary,
                  fontWeight: _isHovering ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableBookCard extends StatelessWidget {
  final Book book;
  const _DraggableBookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Book>(
      data: book,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(book.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: BookGridCard(book: book)),
      child: BookGridCard(book: book),
    );
  }
}
