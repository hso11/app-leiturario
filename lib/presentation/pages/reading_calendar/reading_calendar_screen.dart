import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/reading_session.dart';
import '../../blocs/book/book_bloc.dart';
import '../../blocs/reading_calendar/reading_calendar_cubit.dart';
import '../../../injection.dart';

class ReadingCalendarScreen extends StatelessWidget {
  final String bookId;
  const ReadingCalendarScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookBloc, BookState>(
      builder: (context, bookState) {
        final book = bookState is BooksLoaded
            ? bookState.books.cast<Book?>().firstWhere(
                (b) => b?.id == bookId,
                orElse: () => null,
              )
            : null;

        return BlocProvider(
          create: (_) =>
              getIt<ReadingCalendarCubit>()..load(bookId),
          child: _CalendarView(book: book, bookId: bookId),
        );
      },
    );
  }
}

class _CalendarView extends StatefulWidget {
  final Book? book;
  final String bookId;
  const _CalendarView({required this.book, required this.bookId});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  DateTime get _firstDay {
    if (widget.book?.startDate != null) {
      return ReadingSession.normalizeDate(widget.book!.startDate!);
    }
    return DateTime(2020, 1, 1);
  }

  DateTime get _lastDay {
    final end = widget.book?.endDate;
    if (end != null && end.isAfter(DateTime.now())) return end;
    return DateTime.now().add(const Duration(days: 1));
  }

  List<ReadingSession> _eventLoader(
      DateTime day, Map<DateTime, ReadingSession> sessions) {
    final key = ReadingSession.normalizeDate(day);
    final session = sessions[key];
    return session != null ? [session] : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book != null
            ? 'Calendário — ${widget.book!.title}'
            : 'Calendário de Leitura'),
      ),
      body: BlocConsumer<ReadingCalendarCubit, ReadingCalendarState>(
        listener: (context, state) {
          if (state is ReadingCalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ReadingCalendarLoading ||
              state is ReadingCalendarInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = state is ReadingCalendarLoaded
              ? state.sessions
              : <DateTime, ReadingSession>{};
          final totalPages = state is ReadingCalendarLoaded
              ? state.totalPages
              : 0;

          return Column(
            children: [
              TableCalendar<ReadingSession>(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                locale: 'pt_BR',
                selectedDayPredicate: (day) =>
                    _selectedDay != null &&
                    isSameDay(_selectedDay, day),
                eventLoader: (day) => _eventLoader(day, sessions),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showSessionSheet(context, selectedDay, sessions);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final session = events.first;
                    return Positioned(
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${session.pagesRead}p',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              _SummaryBar(sessions: sessions, totalPages: totalPages),
              const Divider(height: 1),
              Expanded(
                child: _SessionList(
                  sessions: sessions,
                  onTap: (date, session) =>
                      _showSessionSheet(context, date, sessions),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSessionSheet(
    BuildContext context,
    DateTime date,
    Map<DateTime, ReadingSession> sessions,
  ) {
    final normalized = ReadingSession.normalizeDate(date);
    final existing = sessions[normalized];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ReadingCalendarCubit>(),
        child: _SessionSheet(
          bookId: widget.bookId,
          date: normalized,
          existing: existing,
        ),
      ),
    );
  }
}

// ─── Summary bar ────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final Map<DateTime, ReadingSession> sessions;
  final int totalPages;
  const _SummaryBar({required this.sessions, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Dias de leitura', value: sessions.length.toString()),
          _Stat(label: 'Total de páginas', value: totalPages.toString()),
          _Stat(
            label: 'Média/dia',
            value: sessions.isEmpty
                ? '—'
                : (totalPages / sessions.length).toStringAsFixed(1),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Session list ────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final Map<DateTime, ReadingSession> sessions;
  final void Function(DateTime date, ReadingSession session) onTap;
  const _SessionList({required this.sessions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma sessão registrada.\nToque em um dia para registrar páginas lidas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final sorted = sessions.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final entry = sorted[i];
        return ListTile(
          leading: const Icon(Icons.menu_book_outlined,
              color: AppColors.secondary),
          title: Text(AppDateUtils.formatDate(entry.key)),
          trailing: Text(
            '${entry.value.pagesRead} páginas',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          onTap: () => onTap(entry.key, entry.value),
        );
      },
    );
  }
}

// ─── Session sheet ───────────────────────────────────────────────────────────

class _SessionSheet extends StatefulWidget {
  final String bookId;
  final DateTime date;
  final ReadingSession? existing;
  const _SessionSheet(
      {required this.bookId, required this.date, this.existing});

  @override
  State<_SessionSheet> createState() => _SessionSheetState();
}

class _SessionSheetState extends State<_SessionSheet> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _ctrl.text = widget.existing!.pagesRead.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.formatDate(widget.date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Páginas lidas',
                border: OutlineInputBorder(),
                suffixText: 'páginas',
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) {
                  return 'Informe um número maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (isEdit) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    label: const Text('Remover',
                        style: TextStyle(color: AppColors.error)),
                    onPressed: _saving ? null : _delete,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(isEdit ? 'Atualizar' : 'Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final pages = int.parse(_ctrl.text);
    await context.read<ReadingCalendarCubit>().upsert(
          bookId: widget.bookId,
          date: widget.date,
          pagesRead: pages,
          existingId: widget.existing?.id,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    setState(() => _saving = true);
    await context
        .read<ReadingCalendarCubit>()
        .deleteSession(widget.existing!.id, widget.bookId);
    if (mounted) Navigator.pop(context);
  }
}
