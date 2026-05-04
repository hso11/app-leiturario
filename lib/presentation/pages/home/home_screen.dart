import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/book/book_bloc.dart';
import '../../blocs/book_list/book_list_cubit.dart';
import '../../blocs/goal/goal_cubit.dart';
import '../../blocs/streak/streak_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../../core/constants/app_strings.dart';
import '../../../injection.dart';
import 'tabs/history_tab.dart';
import 'tabs/lists_tab.dart';
import 'tabs/reading_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/want_to_read_tab.dart';
import 'widgets/add_book_dialog.dart';
import 'widgets/annual_goal_widget.dart';
import 'widgets/streak_widget.dart';
import 'widgets/sync_indicator.dart';
import 'widgets/user_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<BookBloc>()..add(BookLoadRequested())),
        BlocProvider.value(value: getIt<GoalCubit>()..load()),
        BlocProvider.value(value: getIt<StreakCubit>()..load()),
        BlocProvider.value(value: getIt<BookListCubit>()..load()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  bool _syncingFromPage = false;

  static const int _wantToReadIndex = 0;
  static const int _listsIndex = 4;

  bool _searchActive = false;
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();
    _tabController.addListener(_syncPageFromTab);
    _tabController.addListener(() => setState(() {}));
  }

  void _syncPageFromTab() {
    if (_syncingFromPage) return;
    if (_tabController.indexIsChanging && _pageController.hasClients) {
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_tabController.index != index) {
      _syncingFromPage = true;
      _tabController.animateTo(index);
      Future.delayed(const Duration(milliseconds: 420), () {
        _syncingFromPage = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_syncPageFromTab);
    _tabController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _activateSearch() => setState(() {
        _searchActive = true;
        _query = '';
        _searchController.clear();
      });

  void _deactivateSearch() => setState(() {
        _searchActive = false;
        _query = '';
        _searchController.clear();
      });

  Widget _buildBookPage(int index, Widget child) {
    return AnimatedBuilder(
      animation: _pageController,
      child: child,
      builder: (context, child) {
        double offset = 0;
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          offset = (_pageController.page ?? index.toDouble()) - index;
        }
        final angle = offset.clamp(-1.0, 1.0) * (pi * 0.14);
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          alignment:
              offset > 0 ? Alignment.centerLeft : Alignment.centerRight,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookBloc, BookState>(
      listener: (context, state) {
        if (state is BookAchievementUnlocked) {
          for (final a in state.newAchievements) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${a.emoji} Conquista desbloqueada: ${a.title}!'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
        if (state is BooksLoaded) {
          context.read<GoalCubit>().updateBooksRead(state.books);
        }
      },
      child: Scaffold(
            appBar: AppBar(
              title: _searchActive
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: AppStrings.search,
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    )
                  : const Text(AppStrings.appName),
              actions: [
                if (!_searchActive) ...[
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _activateSearch,
                  ),
                  const UserMenu(),
                ] else
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _deactivateSearch,
                  ),
              ],
              bottom: _searchActive
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(88),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SyncIndicator(),
                                IconButton(
                                  icon: const Icon(Icons.emoji_events,
                                      color: Colors.white70, size: 20),
                                  tooltip: 'Conquistas',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      context.push('/achievements'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.settings,
                                      color: Colors.white70, size: 20),
                                  tooltip: 'Configurações',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => context.push('/settings'),
                                ),
                                BlocBuilder<ThemeCubit, ThemeMode>(
                                  builder: (context, themeMode) {
                                    final isDark = themeMode == ThemeMode.dark ||
                                        (themeMode == ThemeMode.system &&
                                            MediaQuery.platformBrightnessOf(
                                                    context) ==
                                                Brightness.dark);
                                    return IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      tooltip: isDark
                                          ? AppStrings.lightMode
                                          : AppStrings.darkMode,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => context
                                          .read<ThemeCubit>()
                                          .toggleTheme(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            tabs: const [
                              Tab(text: AppStrings.wantToRead),
                              Tab(text: AppStrings.reading),
                              Tab(text: AppStrings.history),
                              Tab(text: AppStrings.statistics),
                              Tab(text: 'Listas'),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
            body: _searchActive
                ? _SearchResults(query: _query)
                : Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: Row(
                          children: [
                            Expanded(child: AnnualGoalWidget()),
                            SizedBox(width: 8),
                            StreakWidget(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          children: [
                            _buildBookPage(0, const WantToReadTab()),
                            _buildBookPage(1, const ReadingTab()),
                            _buildBookPage(2, const HistoryTab()),
                            _buildBookPage(3, const StatsTab()),
                            _buildBookPage(4, const ListsTab()),
                          ],
                        ),
                      ),
                    ],
                  ),
            floatingActionButton: _searchActive
                ? null
                : _tabController.index == _listsIndex
                    ? FloatingActionButton.extended(
                        heroTag: 'add_list',
                        onPressed: () => _showCreateListDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Nova lista'),
                      )
                    : FloatingActionButton.extended(
                        heroTag: 'add_book',
                        onPressed: () => _showAddBookDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text(AppStrings.newBook),
                      ),
            bottomNavigationBar: _searchActive
                ? null
                : BottomNavigationBar(
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_books),
                        label: 'Biblioteca',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.notes),
                        label: 'Anotações',
                      ),
                    ],
                    onTap: (index) {
                      if (index == 1) context.push('/notes');
                    },
                  ),
          ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context) async {
    final controller = TextEditingController();
    final cubit = context.read<BookListCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova lista'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da lista',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                cubit.create(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  Future<void> _showAddBookDialog(BuildContext context) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<BookBloc>(),
        child: const AddBookDialog(),
      ),
    );
    if (added == true) {
      _tabController.animateTo(_wantToReadIndex);
    }
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(AppStrings.search,
            style: TextStyle(color: Colors.grey)),
      );
    }

    final q = query.trim().toLowerCase();

    return BlocBuilder<BookBloc, BookState>(
      builder: (context, state) {
        if (state is! BooksLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final matchedBooks = state.books
            .where((b) =>
                b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q))
            .toList();

        if (matchedBooks.isEmpty) {
          return const Center(
            child: Text('Nenhum resultado encontrado.',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Livros (${matchedBooks.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            ...matchedBooks.map((book) => ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () => context.push('/book/${book.id}'),
                )),
          ],
        );
      },
    );
  }
}
