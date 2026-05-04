import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/book/book_bloc.dart';
import '../../blocs/note/note_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/note.dart';
import '../../../injection.dart';

class NotesFeedScreen extends StatelessWidget {
  const NotesFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NoteBloc>()..add(NoteLoadAllRequested()),
      child: const _NotesFeedView(),
    );
  }
}

class _NotesFeedView extends StatefulWidget {
  const _NotesFeedView();

  @override
  State<_NotesFeedView> createState() => _NotesFeedViewState();
}

class _NotesFeedViewState extends State<_NotesFeedView> {
  String? _selectedBookId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notes),
      ),
      body: Column(
        children: [
          _BookFilter(
            selectedBookId: _selectedBookId,
            onSelected: (id) {
              setState(() => _selectedBookId = id);
              if (id == null) {
                context.read<NoteBloc>().add(NoteLoadAllRequested());
              } else {
                context.read<NoteBloc>().add(NoteLoadByBookRequested(id));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar anotações...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),
          Expanded(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                if (state is NoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NotesLoaded) {
                  final notes = _searchQuery.isEmpty
                      ? state.notes
                      : state.notes.where((n) {
                          final q = _searchQuery.toLowerCase();
                          final matchContent =
                              n.content.toLowerCase().contains(q);
                          final matchPage = n.pageRef != null &&
                              n.pageRef.toString().contains(q);
                          return matchContent || matchPage;
                        }).toList();

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Nenhuma anotação.'
                            : 'Nenhum resultado para "$_searchQuery".',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) =>
                        _GlobalNoteCard(note: notes[index]),
                  );
                }
                if (state is NoteError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookFilter extends StatelessWidget {
  final String? selectedBookId;
  final void Function(String?) onSelected;

  const _BookFilter({required this.selectedBookId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is! BooksLoaded) return const SizedBox();
        final books = state.books;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text(AppStrings.allBooks),
                selected: selectedBookId == null,
                onSelected: (_) => onSelected(null),
              ),
              ...books.map((b) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(b.title),
                      selected: selectedBookId == b.id,
                      onSelected: (_) => onSelected(b.id),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _GlobalNoteCard extends StatelessWidget {
  final Note note;
  const _GlobalNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final bookTitle = _findBookTitle(context, note.bookId);
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
                if (bookTitle != null)
                  Text(
                    bookTitle,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                Text(
                  AppDateUtils.formatDateTime(note.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(note.content),
            if (note.pageRef != null)
              Text(
                'Pág. ${note.pageRef}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
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
            ),
          ],
        ),
      ),
    );
  }

  String? _findBookTitle(BuildContext context, String bookId) {
    final state = context.watch<BookBloc>().state;
    if (state is BooksLoaded) {
      final book = state.books.cast<Book?>().firstWhere(
            (b) => b?.id == bookId,
            orElse: () => null,
          );
      return book?.title;
    }
    return null;
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
    _pageController =
        TextEditingController(text: widget.note.pageRef?.toString() ?? '');
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
          Text('Editar Anotação',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Conteúdo da anotação',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            autofocus: true,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pageController,
            decoration: const InputDecoration(
              labelText: 'Página (opcional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Salvar'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
