import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/book_list/book_list_cubit.dart';
import '../../../../core/constants/app_colors.dart';

class ListsTab extends StatelessWidget {
  const ListsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookListCubit, BookListState>(
      builder: (context, state) {
        if (state is BookListLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BookListsLoaded) {
          if (state.lists.isEmpty) {
            return const Center(
              child: Text('Nenhuma lista criada ainda.',
                  style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.lists.length,
            itemBuilder: (context, i) {
              final list = state.lists[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.playlist_play,
                      color: AppColors.primary),
                  title: Text(list.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${list.bookIds.length} livros'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: () =>
                        context.read<BookListCubit>().delete(list.id),
                  ),
                  onTap: () => context.push('/list/${list.id}'),
                ),
              );
            },
          );
        }
        if (state is BookListError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }

}
