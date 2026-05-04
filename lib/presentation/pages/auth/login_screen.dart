import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  AppStrings.loginTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SignInButton(
                          label: AppStrings.loginGoogle,
                          icon: Icons.g_mobiledata,
                          color: Colors.red,
                          onTap: () => context
                              .read<AuthBloc>()
                              .add(AuthGoogleSignInRequested()),
                        ),
                        const SizedBox(height: 16),
                        _SignInButton(
                          label: AppStrings.loginMicrosoft,
                          icon: Icons.window,
                          color: Colors.blue,
                          onTap: () => context
                              .read<AuthBloc>()
                              .add(AuthMicrosoftSignInRequested()),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: Text(
                            AppStrings.continueOffline,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (context.watch<AuthBloc>().state is AuthError)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      (context.read<AuthBloc>().state as AuthError).message,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SignInButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 2,
      ),
    );
  }
}
