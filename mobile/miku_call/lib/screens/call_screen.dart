import 'package:flutter/material.dart';
import '../services/call_service.dart';

class CallScreen extends StatefulWidget {
  final bool isIncoming;
  
  const CallScreen({super.key, required this.isIncoming});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final callService = CallService.instance;
  bool _isConnected = false;
  bool _isMuted = false;
  String _callStatus = 'Connecting...';

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _startCall();
    }
  }

  Future<void> _startCall() async {
    try {
      await callService.connect();
      setState(() {
        _isConnected = true;
        _callStatus = 'Connected';
      });
    } catch (e) {
      setState(() {
        _callStatus = 'Connection failed';
      });
      print('Call connection error: $e');
    }
  }

  Future<void> _endCall() async {
    await callService.disconnect();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    callService.setMuted(_isMuted);
  }

  @override
  void dispose() {
    callService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section - caller info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.music_note,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Miku 🎵',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _callStatus,
                    style: TextStyle(
                      color: Colors.white.withAlpha(179),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(77),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Listening...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Bottom section - call controls
            Padding(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildCallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.white : Colors.grey[800]!,
                    iconColor: _isMuted ? Colors.red : Colors.white,
                    onPressed: _toggleMute,
                  ),
                  // End call button
                  _buildCallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    size: 70,
                    onPressed: _endCall,
                  ),
                  // Speaker button (placeholder)
                  _buildCallButton(
                    icon: Icons.volume_up,
                    color: Colors.grey[800]!,
                    iconColor: Colors.white,
                    onPressed: () {
                      // TODO: Toggle speaker
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        iconSize: size * 0.5,
        onPressed: onPressed,
      ),
    );
  }
}
