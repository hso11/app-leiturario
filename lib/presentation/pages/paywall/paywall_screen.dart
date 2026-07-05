import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/subscription_constants.dart';
import '../../blocs/subscription/subscription_cubit.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SubscriptionCubit>(),
          child: const PaywallScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leiturário Premium'),
        backgroundColor: AppColors.secondary,
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionPremium) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Premium desbloqueado! Obrigado ✨'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SubscriptionLoading;
          final cubit = context.read<SubscriptionCubit>();
          final price = cubit.premiumPrice;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PremiumHeader(),
                const SizedBox(height: 28),
                const _FeaturesList(),
                const SizedBox(height: 32),

                // Botão principal de compra
                _PurchaseButton(
                  price: price,
                  isLoading: isLoading,
                  onTap: () => cubit.purchasePremium(),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => cubit.restorePurchases(),
                  child: const Text('Restaurar compra anterior'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Compra única — sem assinaturas, sem cobranças recorrentes.\n'
                  'Pagamento processado pela Google Play.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome,
              size: 52, color: AppColors.secondary),
        ),
        const SizedBox(height: 18),
        const Text(
          'Desbloqueie tudo, uma vez só',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Use o app de graça com até ${SubscriptionConstants.freeMaxBooks} livros. '
          'Pague uma vez para ter biblioteca ilimitada, para sempre.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList();

  static const _features = [
    (
      Icons.all_inclusive,
      'Biblioteca ilimitada — adicione mais de ${SubscriptionConstants.freeMaxBooks} livros'
    ),
    (Icons.lock_open, 'Todos os recursos do app continuam liberados'),
    (Icons.cloud_sync, 'Sync em nuvem em qualquer dispositivo'),
    (Icons.favorite, 'Apoie o desenvolvimento do Leiturário'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: _features
              .map(
                (f) => ListTile(
                  dense: true,
                  leading: Icon(f.$1, color: AppColors.secondary, size: 20),
                  title: Text(f.$2, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final String? price;
  final bool isLoading;
  final VoidCallback onTap;

  const _PurchaseButton({
    required this.price,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:
            const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            )
          : Text(price != null
              ? 'Desbloquear Premium — $price'
              : 'Desbloquear Premium'),
    );
  }
}
