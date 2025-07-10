import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/intake_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaterLoggerApp());
}

class WaterLoggerApp extends StatelessWidget {
  const WaterLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntakeProvider()..loadEntries(),
      child: MaterialApp(
        title: 'Water Intake Logger',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}