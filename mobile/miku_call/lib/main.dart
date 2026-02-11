import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/call_screen.dart';
import 'services/call_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications
  print('Background message received: ${message.notification?.title}');
}

bool _firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (gracefully handle missing config)
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _firebaseInitialized = true;
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase not configured, skipping: $e');
  }
  
  // Initialize call service
  await CallService.instance.initialize();
  
  runApp(const MikuCallApp());
}

class MikuCallApp extends StatelessWidget {
  const MikuCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miku Call',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final callService = CallService.instance;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    if (_firebaseInitialized) {
      _setupFirebase();
      _listenForIncomingCalls();
    }
  }

  Future<void> _setupFirebase() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
      });
      print('FCM Token: $token');
    } catch (e) {
      print('⚠️ FCM token error: $e');
    }
  }

  void _listenForIncomingCalls() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Incoming call notification: ${message.notification?.title}');
      
      if (message.data['type'] == 'incoming_call') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CallScreen(isIncoming: true),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miku Call 🎵'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Waiting for Miku to call...',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            if (_fcmToken != null) ...[
              const Text('Device registered'),
              const SizedBox(height: 10),
              Text(
                'Token: ${_fcmToken!.substring(0, 20)}...',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // Test call (manual trigger)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CallScreen(isIncoming: false),
                  ),
                );
              },
              icon: const Icon(Icons.call),
              label: const Text('Test Call'),
            ),
          ],
        ),
      ),
    );
  }
}
