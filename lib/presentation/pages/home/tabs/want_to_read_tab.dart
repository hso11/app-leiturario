import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/book.dart';
import '../widgets/book_grid_card.dart';

class WantToReadTab extends StatefulWidget {
  const WantToReadTab({super.key});

  @override
  State<WantToReadTab> createState() => _WantToReadTabState();
}

class _WantToReadTabState extends State<WantToReadTab> {
  List<Book>? _dragOrder;
  List<Book> _lastKnownBooks = [];

  void _handleHover(Book dragged, Book target) {
    final current = List<Book>.from(_dragOrder ?? _lastKnownBooks);
    current.removeWhere((b) => b.id == dragged.id);
    final targetIdx = current.indexWhere((b) => b.id == target.id);
    if (targetIdx == -1) return;
    current.insert(targetIdx, dragged);
    setState(() => _dragOrder = current);
  }

  void _handleDrop(Book dragged, Book target) {
    final finalOrder = _dragOrder ?? _lastKnownBooks;
    context.read<BookBloc>().add(
          BookReorderRequested(finalOrder.map((b) => b.id).toList()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BooksLoaded && _dragOrder != null) {
          setState(() => _dragOrder = null);
        }
      },
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksLoaded) {
          _lastKnownBooks = state.wantToRead;
          final books = _dragOrder ?? _lastKnownBooks;
          return Column(
            children: [
              _DropZone(books: books),
              Expanded(
                child: books.isEmpty
                    ? const Center(
                        child: Text('Nenhum livro na lista.',
                            style: TextStyle(color: AppColors.textSecondary)),
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
                        itemBuilder: (context, index) => _DraggableBookCard(
                          key: ValueKey(books[index].id),
                          book: books[index],
                          onHover: _handleHover,
                          onDrop: _handleDrop,
                        ),
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
        final book = details.data;
        final bloc = context.read<BookBloc>();
        showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Começar a ler?'),
            content: Text('Mover "${book.title}" para Lendo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(AppStrings.confirm),
              ),
            ],
          ),
        ).then((confirmed) {
          if (confirmed == true && mounted) {
            bloc.add(BookMoveToReadingRequested(book.id));
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.reading.withValues(alpha:0.3)
                : AppColors.reading.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovering
                  ? AppColors.reading
                  : AppColors.reading.withValues(alpha:0.4),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow,
                  color:
                      _isHovering ? AppColors.reading : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                AppStrings.dragToRead,
                style: TextStyle(
                  color:
                      _isHovering ? AppColors.reading : AppColors.textSecondary,
                  fontWeight:
                      _isHovering ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DraggableBookCard extends StatefulWidget {
  final Book book;
  final void Function(Book dragged, Book target) onHover;
  final void Function(Book dragged, Book target) onDrop;

  const _DraggableBookCard({
    super.key,
    required this.book,
    required this.onHover,
    required this.onDrop,
  });

  @override
  State<_DraggableBookCard> createState() => _DraggableBookCardState();
}

class _DraggableBookCardState extends State<_DraggableBookCard> {
  bool _isDropTarget = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Book>(
      onWillAcceptWithDetails: (details) {
        if (details.data.id == widget.book.id) return false;
        setState(() => _isDropTarget = true);
        widget.onHover(details.data, widget.book);
        return true;
      },
      onLeave: (_) => setState(() => _isDropTarget = false),
      onAcceptWithDetails: (details) {
        setState(() => _isDropTarget = false);
        widget.onDrop(details.data, widget.book);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<Book>(
          data: widget.book,
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
              child: Text(widget.book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          childWhenDragging:
              Opacity(opacity: 0.3, child: BookGridCard(book: widget.book)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: _isDropTarget
                ? BoxDecoration(
                    border:
                        Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: BookGridCard(book: widget.book),
          ),
        );
      },
    );
  }
}
