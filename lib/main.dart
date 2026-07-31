import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mishra_milk_cash/core/theme/app_theme.dart';
import 'package:mishra_milk_cash/providers/counter_provider.dart';
import 'package:mishra_milk_cash/providers/history_provider.dart';
import 'package:mishra_milk_cash/screens/home/home_screen.dart';
import 'package:mishra_milk_cash/services/hive_service.dart';
import 'package:mishra_milk_cash/update/providers/update_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait up only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Enable full-screen immersive mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Hive
  await HiveService.init();

  runApp(const MishraMilkCashApp());
}

class MishraMilkCashApp extends StatelessWidget {
  const MishraMilkCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadTransactions()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()),
      ],
      child: MaterialApp(
        title: 'Mishra Milk Cash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
