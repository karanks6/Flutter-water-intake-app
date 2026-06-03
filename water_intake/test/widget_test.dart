import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_intake/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  setUp(() {
    // Mock the SharedPreferences local storage values for test compatibility
    SharedPreferences.setMockInitialValues({});
    
    // Initialize the platform interface instance to avoid LateInitializationError
    FlutterLocalNotificationsPlatform.instance = AndroidFlutterLocalNotificationsPlugin();
  });

  testWidgets('Water Intake app launches splash screen and transitions to main shell', (WidgetTester tester) async {
    // Mock the native platform channel for flutter_timezone
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getLocalTimezone') {
          return 'America/New_York';
        }
        return null;
      },
    );

    // Mock the native platform channel for permission_handler
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        return <int, int>{};
      },
    );

    // Mock the native platform channel for flutter_local_notifications
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dexterous.com/flutter/local_notifications'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'initialize') {
          return true;
        }
        if (methodCall.method == 'pendingNotificationRequests') {
          return <Map<String, dynamic>>[];
        }
        return true;
      },
    );

    // 1. Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // 2. Verify that the SplashScreen is rendered first with custom logos
    expect(find.text("AQUA LOG"), findsOneWidget);
    expect(find.text("Your Hydration Assistant"), findsOneWidget);

    // 3. Move fake time forward by 3 seconds to let the splash animation run and complete
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // Flush microtasks to trigger navigation

    // 4. Pump with a specific duration to settle the Route Transition (700ms).
    await tester.pump(const Duration(milliseconds: 1000));

    // 5. Verify that we successfully transition to the MainShell / HomeScreen
    // We use skipOffstage: false to bypass transient rendering states during active route transitions.
    expect(find.textContaining("Hydration", skipOffstage: false), findsAtLeastNWidgets(1));
    expect(find.text("Quick Add", skipOffstage: false), findsOneWidget);
    expect(find.text("Weekly Progress", skipOffstage: false), findsOneWidget);
  });
}
