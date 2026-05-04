import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/book.dart';
import '../widgets/book_grid_card.dart';

enum BookSortField { title, startDate, endDate, rating }

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final Set<String> _selectedGenres = {};
  BookSortField _sortField = BookSortField.endDate;
  bool _sortAscending = false;

  List<Book> _applySortAndFilter(List<Book> books) {
    var filtered = _selectedGenres.isEmpty
        ? books
        : books.where((b) => b.genres.any((g) => _selectedGenres.contains(g))).toList();

    filtered.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case BookSortField.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case BookSortField.startDate:
          if (a.startDate == null && b.startDate == null) {
            cmp = 0;
          } else if (a.startDate == null) {
            cmp = 1;
          } else if (b.startDate == null) {
            cmp = -1;
          } else {
            cmp = a.startDate!.compareTo(b.startDate!);
          }
        case BookSortField.endDate:
          if (a.endDate == null && b.endDate == null) {
            cmp = 0;
          } else if (a.endDate == null) {
            cmp = 1;
          } else if (b.endDate == null) {
            cmp = -1;
          } else {
            cmp = a.endDate!.compareTo(b.endDate!);
          }
        case BookSortField.rating:
          if (a.rating == null && b.rating == null) {
            cmp = 0;
          } else if (a.rating == null) {
            cmp = 1;
          } else if (b.rating == null) {
            cmp = -1;
          } else {
            cmp = a.rating!.compareTo(b.rating!);
          }
      }
      return _sortAscending ? cmp : -cmp;
    });

    return filtered;
  }

  Set<String> _allGenres(List<Book> books) {
    final genres = <String>{};
    for (final b in books) {
      genres.addAll(b.genres);
    }
    return genres;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is BookLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BooksLoaded) {
          final books = state.history;
          if (books.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Nenhum livro no histórico ainda.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          final allGenres = _allGenres(books);
          final displayBooks = _applySortAndFilter(books);

          return Column(
            children: [
              // Sort controls
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Text(AppStrings.sortBy,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<BookSortField>(
                        value: _sortField,
                        isExpanded: true,
                        isDense: true,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: BookSortField.title, child: Text(AppStrings.sortTitle)),
                          DropdownMenuItem(value: BookSortField.startDate, child: Text(AppStrings.sortStartDate)),
                          DropdownMenuItem(value: BookSortField.endDate, child: Text(AppStrings.sortEndDate)),
                          DropdownMenuItem(value: BookSortField.rating, child: Text(AppStrings.sortRating)),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _sortField = v);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 18,
                      ),
                      tooltip: _sortAscending ? 'Crescente' : 'Decrescente',
                      onPressed: () => setState(() => _sortAscending = !_sortAscending),
                    ),
                  ],
                ),
              ),
              // Genre filter chips
              if (allGenres.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: allGenres.map((genre) {
                      final selected = _selectedGenres.contains(genre);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(genre, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedGenres.add(genre);
                              } else {
                                _selectedGenres.remove(genre);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: displayBooks.length,
                  itemBuilder: (context, index) =>
                      BookGridCard(book: displayBooks[index]),
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

