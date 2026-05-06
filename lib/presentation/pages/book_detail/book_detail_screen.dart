import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../blocs/book/book_bloc.dart';
import '../../blocs/note/note_bloc.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/note.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/image_capture.dart';
import '../../../injection.dart';
import '../../blocs/book_list/book_list_cubit.dart';
import 'widgets/book_share_card.dart';
import 'widgets/price_search_card.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<BookBloc>()),
        BlocProvider.value(
            value: getIt<NoteBloc>()..add(NoteLoadByBookRequested(bookId))),
        BlocProvider(
            create: (_) => getIt<BookListCubit>()..load()),
      ],
      child: _BookDetailView(bookId: bookId),
    );
  }
}

class _BookDetailView extends StatelessWidget {
  final String bookId;
  const _BookDetailView({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is! BooksLoaded) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final book = state.books.cast<Book?>().firstWhere(
              (b) => b?.id == bookId,
              orElse: () => null,
            );

        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Livro')),
            body: const Center(child: Text('Livro não encontrado')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleAction(context, value, book),
                itemBuilder: (_) => _buildMenuItems(book, context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _BookInfoCard(book: book),
                if (book.status == BookStatus.wantToRead)
                  PriceSearchCard(book: book),
                if (book.status == BookStatus.read && (book.rating != null || (book.review != null && book.review!.isNotEmpty)))
                  _RatingReviewCard(book: book),
                const Divider(),
                _NotesList(bookId: bookId),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddNoteDialog(context, bookId),
            tooltip: AppStrings.newNote,
            child: const Icon(Icons.note_add),
          ),
        );
      },
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(Book book, BuildContext context) {
    final items = <PopupMenuEntry<String>>[];
    if (book.status == BookStatus.wantToRead) {
      items.add(const PopupMenuItem(
        value: 'start',
        child: Row(children: [
          Icon(Icons.play_arrow),
          SizedBox(width: 8),
          Text(AppStrings.startReading),
        ]),
      ));
    }
    if (book.status == BookStatus.reading) {
      items.add(const PopupMenuItem(
        value: 'mark_read',
        child: Row(children: [
          Icon(Icons.check_circle),
          SizedBox(width: 8),
          Text(AppStrings.markAsRead),
        ]),
      ));
      items.add(const PopupMenuItem(
        value: 'move_to_want_to_read',
        child: Row(children: [
          Icon(Icons.undo),
          SizedBox(width: 8),
          Text(AppStrings.moveToWantToRead),
        ]),
      ));
    }
    // Export notes item — injected via note state
    items.add(const PopupMenuItem(
      value: 'add_to_list',
      child: Row(children: [
        Icon(Icons.playlist_add),
        SizedBox(width: 8),
        Text('Adicionar à lista...'),
      ]),
    ));
    if (book.status == BookStatus.read || book.status == BookStatus.reading)
      items.add(const PopupMenuItem(
        value: 'edit_dates',
        child: Row(children: [
          Icon(Icons.edit_calendar),
          SizedBox(width: 8),
          Text('Editar datas'),
        ]),
      ));
    if (book.status == BookStatus.read)
      items.add(const PopupMenuItem(
        value: 'share',
        child: Row(children: [
          Icon(Icons.share),
          SizedBox(width: 8),
          Text('Compartilhar conquista 🎉'),
        ]),
      ));
    items.add(const PopupMenuItem(
      value: 'calendar',
      child: Row(children: [
        Icon(Icons.calendar_month),
        SizedBox(width: 8),
        Text('Calendário de Leitura'),
      ]),
    ));
    items.add(const PopupMenuItem(
      value: 'export_notes',
      child: Row(children: [
        Icon(Icons.ios_share),
        SizedBox(width: 8),
        Text(AppStrings.exportNotes),
      ]),
    ));
    items.add(const PopupMenuItem(
      value: 'delete',
      child: Row(children: [
        Icon(Icons.delete, color: AppColors.error),
        SizedBox(width: 8),
        Text(AppStrings.delete,
            style: TextStyle(color: AppColors.error)),
      ]),
    ));
    return items;
  }

  void _handleAction(BuildContext context, String action, Book book) {
    switch (action) {
      case 'start':
        context.read<BookBloc>().add(BookMoveToReadingRequested(book.id));
        break;
      case 'move_to_want_to_read':
        context.read<BookBloc>().add(BookMoveToWantToReadRequested(book.id));
        break;
      case 'mark_read':
        _showMarkAsReadSheet(context, book);
        break;
      case 'add_to_list':
        _showAddToListSheet(context, book);
        break;
      case 'edit_dates':
        _showEditDatesSheet(context, book);
        break;
      case 'share':
        _showShareDialog(context, book);
        break;
      case 'calendar':
        context.push('/book/${book.id}/calendar');
        break;
      case 'export_notes':
        _exportNotes(context, book);
        break;
      case 'set_target':
        _pickTargetDate(context, book);
        break;
      case 'delete':
        _confirmDelete(context, book);
        break;
    }
  }

  void _showMarkAsReadSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BookBloc>(),
        child: _MarkAsReadSheet(book: book),
      ),
    );
  }

  void _exportNotes(BuildContext context, Book book) {
    final noteState = context.read<NoteBloc>().state;
    if (noteState is! NotesLoaded || noteState.notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma anotação para exportar.')),
      );
      return;
    }
    final buffer = StringBuffer();
    buffer.writeln('📚 ${book.title}');
    buffer.writeln('✍️ ${book.author}');
    buffer.writeln('─' * 30);
    buffer.writeln();
    for (final note in noteState.notes) {
      final dateStr = AppDateUtils.formatDateTime(note.createdAt);
      if (note.pageRef != null) {
        buffer.writeln('Pág. ${note.pageRef} — $dateStr:');
      } else {
        buffer.writeln('$dateStr:');
      }
      buffer.writeln(note.content);
      buffer.writeln();
    }
    _shareText(context, buffer.toString());
  }

  void _shareText(BuildContext context, String text) {
    Share.share(text);
  }

  Future<void> _pickTargetDate(BuildContext context, Book book) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: book.targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null && context.mounted) {
      context.read<BookBloc>().add(
            BookUpdateRequested(book.copyWith(targetDate: picked)),
          );
    }
  }

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: Text('Remover "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<BookBloc>().add(BookDeleteRequested(book.id));
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(AppStrings.delete,
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) => _ShareCardDialog(book: book),
    );
  }

  void _showEditDatesSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BookBloc>(),
        child: _EditDatesSheet(book: book),
      ),
    );
  }

  void _showAddToListSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<BookListCubit>(),
        child: _AddToListSheet(bookId: book.id),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, String bookId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<NoteBloc>(),
        child: _AddNoteSheet(bookId: bookId),
      ),
    );
  }
}

class _BookInfoCard extends StatelessWidget {
  final Book book;
  const _BookInfoCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (book.coverUrl != null && book.coverUrl!.isNotEmpty) ...[
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  height: 120,
                  fit: BoxFit.fitHeight,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(book.author,
              style: const TextStyle(
                  fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                  label: '${book.totalPages} páginas',
                  icon: Icons.pages),
              const SizedBox(width: 8),
              _InfoChip(
                  label: _statusLabel(book.status),
                  icon: Icons.bookmark,
                  color: _statusColor(book.status)),
            ],
          ),
          if (book.genres.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: book.genres.map((g) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(g,
                    style: const TextStyle(fontSize: 11, color: AppColors.primary)),
              )).toList(),
            ),
          ],
          if (book.startDate != null) ...[
            const SizedBox(height: 8),
            Text('Início: ${AppDateUtils.formatDate(book.startDate!)}',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if (book.endDate != null) ...[
            Text('Fim: ${AppDateUtils.formatDate(book.endDate!)}',
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
          // Progress section for books being read
          if (book.status == BookStatus.reading) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${book.currentPage} de ${book.totalPages} páginas',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                          if (book.readingProgress != null)
                            Text(
                              '${(book.readingProgress! * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.reading),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: book.readingProgress ?? 0,
                        backgroundColor: AppColors.reading.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.reading),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showUpdateProgressSheet(context, book),
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(AppStrings.updateProgress),
            ),
          ],
          if (book.status == BookStatus.reading ||
              book.status == BookStatus.wantToRead) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      book.targetDate ?? now.add(const Duration(days: 30)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 3650)),
                );
                if (picked != null && context.mounted) {
                  context.read<BookBloc>().add(
                        BookUpdateRequested(
                            book.copyWith(targetDate: picked)),
                      );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      book.targetDate != null
                          ? 'Meta: ${AppDateUtils.formatDate(book.targetDate!)}'
                          : 'Definir Meta',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: book.targetDate != null
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                    if (book.targetDate != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 13, color: AppColors.primary),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (book.pagesPerDayTarget != null) ...[
            const SizedBox(height: 2),
            Text(
              '${book.pagesPerDayTarget!.toStringAsFixed(1)} páginas/dia (meta)',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.reading
                      : AppColors.success),
            ),
          ],
          if (book.estimatedCompletionDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Conclusão estimada: ${DateFormat('d MMM', 'pt_BR').format(book.estimatedCompletionDate!)} · '
              '(${book.estimatedCompletionDate!.difference(DateTime.now()).inDays} dias)',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
          if (book.pagesPerDay != null) ...[
            const SizedBox(height: 8),
            Text(
              '${book.pagesPerDay!.toStringAsFixed(1)} páginas/dia',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpdateProgressSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BookBloc>(),
        child: _UpdateProgressSheet(book: book),
      ),
    );
  }

  String _statusLabel(BookStatus s) {
    switch (s) {
      case BookStatus.wantToRead:
        return 'Quero Ler';
      case BookStatus.reading:
        return 'Lendo';
      case BookStatus.read:
        return 'Lido';
    }
  }

  Color _statusColor(BookStatus s) {
    switch (s) {
      case BookStatus.wantToRead:
        return AppColors.wantToRead;
      case BookStatus.reading:
        return AppColors.reading;
      case BookStatus.read:
        return AppColors.read;
    }
  }
}

class _RatingReviewCard extends StatelessWidget {
  final Book book;
  const _RatingReviewCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book.rating != null) ...[
                Row(
                  children: [
                    Text(AppStrings.rating,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < book.rating! ? Icons.star : Icons.star_border,
                          size: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (book.review != null && book.review!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(AppStrings.review,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(book.review!,
                    style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateProgressSheet extends StatefulWidget {
  final Book book;
  const _UpdateProgressSheet({required this.book});

  @override
  State<_UpdateProgressSheet> createState() => _UpdateProgressSheetState();
}

class _UpdateProgressSheetState extends State<_UpdateProgressSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.book.currentPage > 0
            ? widget.book.currentPage.toString()
            : '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0 || value > widget.book.totalPages) return;
    context.read<BookBloc>().add(BookUpdateProgressRequested(
          bookId: widget.book.id,
          currentPage: value,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.updateProgress,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppStrings.currentPage,
              border: const OutlineInputBorder(),
              helperText: 'Máximo: ${widget.book.totalPages}',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AddToListSheet extends StatelessWidget {
  final String bookId;
  const _AddToListSheet({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookListCubit, BookListState>(
      builder: (context, state) {
        final lists = state is BookListsLoaded ? state.lists : [];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar à lista',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (lists.isEmpty)
                const Text('Nenhuma lista criada ainda.',
                    style: TextStyle(color: AppColors.textSecondary))
              else
                ...lists.map((list) => ListTile(
                      leading: const Icon(Icons.playlist_add),
                      title: Text(list.name),
                      subtitle: Text('${list.bookIds.length} livros'),
                      onTap: () {
                        context.read<BookListCubit>().addBook(list.id, bookId);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Adicionado à lista "${list.name}"')),
                        );
                      },
                    )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _MarkAsReadSheet extends StatefulWidget {
  final Book book;
  const _MarkAsReadSheet({required this.book});

  @override
  State<_MarkAsReadSheet> createState() => _MarkAsReadSheetState();
}

class _MarkAsReadSheetState extends State<_MarkAsReadSheet> {
  int? _rating;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<BookBloc>().add(BookMarkAsReadRequested(
          widget.book.id,
          rating: _rating,
          review: _reviewController.text.trim().isEmpty
              ? null
              : _reviewController.text.trim(),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.markAsRead,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Text(AppStrings.rating,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final star = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = _rating == star ? null : star),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    (_rating != null && star <= _rating!)
                        ? Icons.star
                        : Icons.star_border,
                    size: 36,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: AppStrings.review,
              border: OutlineInputBorder(),
              hintText: 'O que você achou do livro? (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text(AppStrings.markAsRead),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _InfoChip({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color ?? AppColors.primary)),
        ],
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  final String bookId;
  const _NotesList({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is NotesLoaded) {
          if (state.notes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Nenhuma anotação ainda.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.notes.length,
            itemBuilder: (context, index) =>
                _NoteCard(note: state.notes[index]),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppDateUtils.formatDateTime(note.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                if (note.pageRef != null)
                  Text(
                    'Pág. ${note.pageRef}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(note.content),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.primary),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BlocProvider.value(
                      value: context.read<NoteBloc>(),
                      child: _EditNoteSheet(note: note),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.error),
                  onPressed: () => context
                      .read<NoteBloc>()
                      .add(NoteDeleteRequested(note.id, bookId: note.bookId)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  final String bookId;
  const _AddNoteSheet({required this.bookId});

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _ShareCardDialog extends StatefulWidget {
  final Book book;
  const _ShareCardDialog({required this.book});

  @override
  State<_ShareCardDialog> createState() => _ShareCardDialogState();
}

class _ShareCardDialogState extends State<_ShareCardDialog> {
  final _cardKey = GlobalKey();
  bool _capturing = false;

  Future<void> _share() async {
    setState(() => _capturing = true);
    final file = await captureWidgetToFile(_cardKey);
    setState(() => _capturing = false);
    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao gerar a imagem.')),
        );
      }
      return;
    }
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Terminei de ler: ${widget.book.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            key: _cardKey,
            child: BookShareCard(book: widget.book),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _capturing ? null : _share,
                icon: _capturing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.share),
                label: const Text('Compartilhar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EditNoteSheet extends StatefulWidget {
  final Note note;
  const _EditNoteSheet({required this.note});

  @override
  State<_EditNoteSheet> createState() => _EditNoteSheetState();
}

class _EditNoteSheetState extends State<_EditNoteSheet> {
  late final TextEditingController _contentController;
  late final TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _pageController = TextEditingController(
        text: widget.note.pageRef?.toString() ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    final pageText = _pageController.text.trim();
    final pageRef = int.tryParse(pageText);
    context.read<NoteBloc>().add(NoteUpdateRequested(
          widget.note.copyWith(
            content: content,
            pageRef: pageRef,
            clearPageRef: pageText.isEmpty,
          ),
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.edit,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: AppStrings.noteContent,
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            autofocus: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pageController,
            decoration: const InputDecoration(
              labelText: AppStrings.pageRef,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EditDatesSheet extends StatefulWidget {
  final Book book;
  const _EditDatesSheet({required this.book});

  @override
  State<_EditDatesSheet> createState() => _EditDatesSheetState();
}

class _EditDatesSheetState extends State<_EditDatesSheet> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.book.startDate;
    _endDate = widget.book.endDate;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  void _submit() {
    context.read<BookBloc>().add(
          BookUpdateRequested(widget.book.copyWith(
            startDate: _startDate,
            clearStartDate: _startDate == null,
            endDate: _endDate,
            clearEndDate: _endDate == null,
          )),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Editar Datas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_startDate != null
                ? 'Início: ${AppDateUtils.formatDate(_startDate!)}'
                : 'Data de início (não definida)'),
            onTap: _pickStartDate,
            trailing: _startDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _startDate = null),
                  )
                : null,
          ),
          if (widget.book.status == BookStatus.read)
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(_endDate != null
                  ? 'Conclusão: ${AppDateUtils.formatDate(_endDate!)}'
                  : 'Data de conclusão (não definida)'),
              onTap: _pickEndDate,
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : null,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _contentController = TextEditingController();
  final _pageController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndRecognize() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final inputImage = InputImage.fromFilePath(picked.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    if (result.text.isNotEmpty) {
      _contentController.text = result.text;
    }
  }

  void _submit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    final pageRef = int.tryParse(_pageController.text.trim());
    context.read<NoteBloc>().add(NoteAddRequested(
          bookId: widget.bookId,
          content: content,
          pageRef: pageRef,
        ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.newNote,
                  style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                tooltip: AppStrings.takePhoto,
                onPressed: _pickAndRecognize,
              ),
            ],
          ),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: AppStrings.noteContent,
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pageController,
            decoration: const InputDecoration(
              labelText: AppStrings.pageRef,
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
