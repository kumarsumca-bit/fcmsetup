import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FCMService _fcmService = FCMService();
  String _fcmToken = 'Loading...';
  final TextEditingController _topicController = TextEditingController();
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() {
      _fcmToken = _fcmService.fcmToken ?? 'No token available';
    });
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != 'Loading...' && _fcmToken != 'No token available') {
      Clipboard.setData(ClipboardData(text: _fcmToken));
      _showMessage('Token copied to clipboard!');
    }
  }

  void _showMessage(String message) {
    setState(() {
      _statusMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _subscribeToTopic() async {
    if (_topicController.text.isNotEmpty) {
      await _fcmService.subscribeToTopic(_topicController.text);
      _showMessage('Subscribed to topic: ${_topicController.text}');
      _topicController.clear();
    }
  }

  Future<void> _unsubscribeFromTopic() async {
    if (_topicController.text.isNotEmpty) {
      await _fcmService.unsubscribeFromTopic(_topicController.text);
      _showMessage('Unsubscribed from topic: ${_topicController.text}');
      _topicController.clear();
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FCM Setup Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FCM Token',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _fcmToken,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _copyTokenToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Token'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Topic Subscription',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic Name',
                        hintText: 'e.g., news, updates',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _subscribeToTopic,
                            icon: const Icon(Icons.add),
                            label: const Text('Subscribe'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _unsubscribeFromTopic,
                            icon: const Icon(Icons.remove),
                            label: const Text('Unsubscribe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Copy the FCM token above\n'
                      '2. Go to Firebase Console\n'
                      '3. Navigate to Cloud Messaging\n'
                      '4. Send a test notification using the token\n'
                      '5. Test foreground, background, and terminated states',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}