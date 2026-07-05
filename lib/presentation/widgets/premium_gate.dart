import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/subscription/subscription_cubit.dart';
import '../pages/paywall/paywall_screen.dart';
import '../../core/constants/app_colors.dart';

/// Exibe [child] apenas para usuários premium.
/// Caso contrário, exibe um placeholder com CTA de upgrade.
class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final Widget? lockedPlaceholder;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.lockedPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionPremium) return child;
        return lockedPlaceholder ??
            _LockedView(featureName: featureName);
      },
    );
  }
}

class _LockedView extends StatelessWidget {
  final String featureName;
  const _LockedView({required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.secondary),
            const SizedBox(height: 12),
            Text(
              featureName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Disponível no Leiturário Premium',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => PaywallScreen.show(context),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Ver planos Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mostra um bottom sheet de upgrade premium inline (sem navegar para o paywall).
void showPremiumBottomSheet(BuildContext context, String featureName) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<SubscriptionCubit>(),
      child: _PremiumBottomSheet(featureName: featureName),
    ),
  );
}

class _PremiumBottomSheet extends StatelessWidget {
  final String featureName;
  const _PremiumBottomSheet({required this.featureName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.lock_outline, size: 40, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(
            featureName,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Disponível no Leiturário Premium',
            style: TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                PaywallScreen.show(context);
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Ver planos Premium'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Agora não'),
          ),
        ],
      ),
    );
  }
}
