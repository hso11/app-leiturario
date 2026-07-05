import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/services/subscription_service.dart';

part 'subscription_state.dart';

@lazySingleton
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionService _service;
  StreamSubscription<bool>? _premiumSub;

  SubscriptionCubit(this._service) : super(const SubscriptionLoading()) {
    // Recebe atualizações assíncronas da Play Store (compra, restore)
    _premiumSub = _service.premiumStream.listen((isPremium) {
      emit(isPremium ? const SubscriptionPremium() : const SubscriptionFree());
    });
  }

  /// Sincroniza estado com o cache local (chamado em main.dart após initialize()).
  void initialize() {
    emit(_service.isPremium
        ? const SubscriptionPremium()
        : const SubscriptionFree());
  }

  bool get isPremium => state is SubscriptionPremium;

  /// Preço formatado vindo da Play Store (ex: "R$ 29,90"). Null enquanto carrega.
  String? get premiumPrice => _service.premiumPrice;

  /// Abre o popup de compra única da Play Store.
  Future<void> purchasePremium() async {
    emit(const SubscriptionLoading());
    try {
      final ok = await _service.purchase();
      // Se ok == false (produto não encontrado), volta para free
      // Se ok == true, o estado virá via premiumStream quando a Play Store confirmar
      if (!ok) emit(const SubscriptionFree());
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  /// Restaura compra feita anteriormente (reinstalação / troca de celular).
  Future<void> restorePurchases() async {
    emit(const SubscriptionLoading());
    try {
      await _service.restorePurchases();
      // O resultado virá via premiumStream; se não vier em 5s, assume free
      await Future.delayed(const Duration(seconds: 5));
      if (state is SubscriptionLoading) {
        emit(const SubscriptionFree());
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _premiumSub?.cancel();
    return super.close();
  }
}
