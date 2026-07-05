part of 'subscription_cubit.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();
}

final class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
  @override
  List<Object?> get props => [];
}

final class SubscriptionFree extends SubscriptionState {
  const SubscriptionFree();
  @override
  List<Object?> get props => [];
}

final class SubscriptionPremium extends SubscriptionState {
  const SubscriptionPremium();
  @override
  List<Object?> get props => [];
}

final class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}
