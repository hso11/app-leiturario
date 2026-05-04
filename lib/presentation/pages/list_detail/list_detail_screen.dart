import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/book/book_bloc.dart';
import '../../blocs/book_list/book_list_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/book_list.dart';
import '../../../injection.dart';

class ListDetailScreen extends StatelessWidget {
  final String listId;
  const ListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<BookBloc>()),
        BlocProvider(create: (_) => getIt<BookListCubit>()..load()),
      ],
      child: _ListDetailView(listId: listId),
    );
  }
}

class _ListDetailView extends StatelessWidget {
  final String listId;
  const _ListDetailView({required this.listId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookListCubit, BookListState>(
      builder: (context, listState) {
        if (listState is! BookListsLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final list = listState.lists.cast<BookList?>().firstWhere(
              (l) => l?.id == listId,
              orElse: () => null,
            );

        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lista')),
            body: const Center(child: Text('Lista não encontrada')),
          );
        }

        return BlocBuilder<BookBloc, BookState>(
          builder: (context, bookState) {
            final allBooks =
                bookState is BooksLoaded ? bookState.books : <Book>[];
            final listBooks = allBooks
                .where((b) => list.bookIds.contains(b.id))
                .toList();

            return Scaffold(
              appBar: AppBar(
                title: Text(list.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Adicionar livro',
                    onPressed: () =>
                        _showAddBookSheet(context, list, allBooks),
                  ),
                ],
              ),
              body: listBooks.isEmpty
                  ? const Center(
                      child: Text('Nenhum livro nesta lista.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: listBooks.length,
                      itemBuilder: (context, i) {
                        final book = listBooks[i];
                        return Dismissible(
                          key: Key('${list.id}_${book.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: AppColors.error,
                            child: const Icon(Icons.remove_circle,
                                color: Colors.white),
                          ),
                          onDismissed: (_) {
                            context
                                .read<BookListCubit>()
                                .removeBook(list.id, book.id);
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: book.coverUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: CachedNetworkImage(
                                        imageUrl: book.coverUrl!,
                                        width: 36,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            _fallbackAvatar(book),
                                      ),
                                    )
                                  : _fallbackAvatar(book),
                              title: Text(book.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(book.author),
                              onTap: () => context.push('/book/${book.id}'),
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Widget _fallbackAvatar(Book book) => CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      );

  Future<void> _showAddBookSheet(
    BuildContext context,
    BookList list,
    List<Book> allBooks,
  ) async {
    final cubit = context.read<BookListCubit>();
    final available = allBooks
        .where((b) => !list.bookIds.contains(b.id))
        .toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os livros já estão na lista.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adicionar livro',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: available
                    .map((book) => ListTile(
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          onTap: () {
                            cubit.addBook(list.id, book.id);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
