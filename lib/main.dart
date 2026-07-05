import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/notification_service.dart';
import 'data/services/onboarding_service.dart';
import 'data/services/subscription_service.dart';
import 'injection.dart';
import 'presentation/app.dart';
import 'presentation/blocs/subscription/subscription_cubit.dart';

// Substitua pelos valores do seu projeto Supabase em
// https://supabase.com/dashboard/project/<seu-projeto>/settings/api
const _supabaseUrl = 'https://liusarieisbuslzbftet.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxpdXNhcmllaXNidXNsemJmdGV0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMjMzMjEsImV4cCI6MjA5NjU5OTMyMX0.PT-VTCia_UlW3EH-zyPkZftwVCqog5FVn7QDM6ImIcE';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );
  await configureDependencies();
  await getIt<NotificationService>().initialize();
  await getIt<SubscriptionService>().initialize();
  await getIt<OnboardingService>().initialize();
  getIt<SubscriptionCubit>().initialize();
  runApp(const BookTrackerApp());
}
