import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/services/notification_service.dart';
import 'injection.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await configureDependencies();
  await getIt<NotificationService>().initialize();
  runApp(const BookTrackerApp());
}
