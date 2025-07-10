import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_intake_logger/providers/intake_provider.dart';
import 'package:water_intake_logger/screens/home_screen.dart';
import 'package:water_intake_logger/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // Initialize notification service
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IntakeProvider(),
      child: MaterialApp(
        title: 'Water Intake Logger',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}