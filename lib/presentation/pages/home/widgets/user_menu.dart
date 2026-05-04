import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../../core/constants/app_strings.dart';

class UserMenu extends StatelessWidget {
  const UserMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(AuthSignOutRequested());
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  state.userEmail ?? state.provider,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text(AppStrings.logout),
                  ],
                ),
              ),
            ],
          );
        }
        return IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
          tooltip: 'Login',
          onPressed: () {
            // Navigate to login
          },
        );
      },
    );
  }
}
