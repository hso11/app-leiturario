import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../blocs/book/book_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/services/google_books_service.dart';
import '../../../../domain/entities/book_search_result.dart';
import '../../../../injection.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final Set<String> _selectedGenres = {};
  String? _coverUrl;
  bool _alreadyRead = false;
  bool _startedReading = false;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_alreadyRead && _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe a data de conclusão')),
        );
        return;
      }
      context.read<BookBloc>().add(BookAddRequested(
            title: _titleController.text.trim(),
            author: _authorController.text.trim(),
            totalPages: int.parse(_pagesController.text.trim()),
            genres: _selectedGenres.toList(),
            coverUrl: _coverUrl,
            startDate: (_alreadyRead || _startedReading) ? _startDate : null,
            endDate: _alreadyRead ? _endDate : null,
          ));
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final initial = isEnd
        ? (_endDate ?? _startDate ?? DateTime.now())
        : (_startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isEnd) {
          _endDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _showSearchSheet() async {
    final result = await showModalBottomSheet<BookSearchResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BookSearchSheet(
        booksService: getIt<GoogleBooksService>(),
      ),
    );
    if (result != null) {
      setState(() {
        _titleController.text = result.title;
        _authorController.text = result.author;
        if (result.pageCount != null) {
          _pagesController.text = result.pageCount.toString();
        }
        _coverUrl = result.coverUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.newBook),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: AppStrings.bookTitle),
                      validator: (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Campo obrigatório'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showSearchSheet,
                    icon: const Icon(Icons.search),
                    tooltip: 'Buscar no Google Books',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _authorController,
                decoration:
                    const InputDecoration(labelText: AppStrings.bookAuthor),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _pagesController,
                decoration:
                    const InputDecoration(labelText: AppStrings.totalPages),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
                  if (int.tryParse(v.trim()) == null) return 'Número inválido';
                  return null;
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já comecei a ler'),
                value: _startedReading,
                onChanged: (v) => setState(() {
                  _startedReading = v;
                  if (v) {
                    _alreadyRead = false;
                    _endDate = null;
                  } else {
                    _startDate = null;
                  }
                }),
              ),
              if (_startedReading)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de início (opcional)'),
                  subtitle: Text(
                    _startDate != null
                        ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
                        : 'Não informada',
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () => _pickDate(isEnd: false),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Já li este livro'),
                value: _alreadyRead,
                onChanged: (v) => setState(() {
                  _alreadyRead = v;
                  if (v) {
                    _startedReading = false;
                  } else {
                    _startDate = null;
                    _endDate = null;
                  }
                }),
              ),
              if (_alreadyRead) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de início (opcional)'),
                  subtitle: Text(
                    _startDate != null
                        ? '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}/${_startDate!.year}'
                        : 'Não informada',
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () => _pickDate(isEnd: false),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data de conclusão *'),
                  subtitle: Text(
                    _endDate != null
                        ? '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}/${_endDate!.year}'
                        : 'Não informada',
                  ),
                  trailing: const Icon(Icons.calendar_today, size: 20),
                  onTap: () => _pickDate(isEnd: true),
                ),
              ],
              if (_coverUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: _coverUrl!,
                        height: 48,
                        width: 32,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Capa encontrada',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _coverUrl = null),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Text(AppStrings.genre,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: AppStrings.predefinedGenres.map((genre) {
                  final selected = _selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    selectedColor: AppColors.primary.withValues(alpha:0.2),
                    checkmarkColor: AppColors.primary,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedGenres.add(genre);
                        } else {
                          _selectedGenres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

class _BookSearchSheet extends StatefulWidget {
  final GoogleBooksService booksService;
  const _BookSearchSheet({required this.booksService});

  @override
  State<_BookSearchSheet> createState() => _BookSearchSheetState();
}

class _BookSearchSheetState extends State<_BookSearchSheet> {
  final _queryController = TextEditingController();
  List<BookSearchResult> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _queryController.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final results = await widget.booksService.search(q);
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Buscar título...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _search,
                    child: const Text('Buscar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const CircularProgressIndicator()
              else
                Expanded(
                  child: _results.isEmpty
                      ? const Center(
                          child: Text('Nenhum resultado.',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _results.length,
                          itemBuilder: (_, i) =>
                              _SearchResultTile(
                                result: _results[i],
                                onTap: () => Navigator.pop(context, _results[i]),
                              ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final BookSearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: result.coverUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: result.coverUrl!,
                width: 36,
                height: 50,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.book, size: 36),
              ),
            )
          : const Icon(Icons.book, size: 36),
      title: Text(result.title, style: const TextStyle(fontSize: 13)),
      subtitle: Text(result.author,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: result.pageCount != null
          ? Text('${result.pageCount}p',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))
          : null,
      onTap: onTap,
    );
  }
}
