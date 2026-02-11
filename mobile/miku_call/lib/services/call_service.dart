import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class CallService {
  static final CallService instance = CallService._();
  CallService._();

  // WebSocket
  WebSocketChannel? _channel;
  bool _isConnected = false;
  
  // Audio recording
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isMuted = false;
  
  // Audio playback
  final _audioPlayer = AudioPlayer();
  
  // Server URL - Mac's local IP on the network
  static const String _serverUrl = 'ws://192.168.1.13:8080/call/connect';
  
  Future<void> initialize() async {
    // Request microphone permission
    await Permission.microphone.request();
  }

  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      // Connect WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      
      // Listen for messages from server
      _channel!.stream.listen(
        _handleServerMessage,
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket closed');
          _isConnected = false;
        },
      );
      
      _isConnected = true;
      
      // Start recording after connection
      await _startRecording();
      
    } catch (e) {
      print('Connection error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _stopRecording();
    await _channel?.sink.close();
    _isConnected = false;
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    
    try {
      // Check permission
      if (await _audioRecorder.hasPermission()) {
        // Start recording (stream mode for real-time)
        final stream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        
        _isRecording = true;
        
        // Send audio chunks to server
        stream.listen((audioData) {
          if (!_isMuted && _isConnected) {
            _sendAudioToServer(audioData);
          }
        });
      }
    } catch (e) {
      print('Recording error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    
    await _audioRecorder.stop();
    _isRecording = false;
  }

  void _sendAudioToServer(Uint8List audioData) {
    if (_channel == null || !_isConnected) return;
    
    try {
      // Encode audio as base64 and send to server
      final message = jsonEncode({
        'type': 'audio',
        'data': base64Encode(audioData),
      });
      
      _channel!.sink.add(message);
    } catch (e) {
      print('Send audio error: $e');
    }
  }

  void _handleServerMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      switch (data['type']) {
        case 'connected':
          print('Server connected: ${data['message']}');
          break;
        
        case 'audio':
          // Received audio response from Miku
          final audioBase64 = data['data'] as String;
          final audioBytes = base64Decode(audioBase64);
          _playAudio(audioBytes);
          break;
        
        case 'error':
          print('Server error: ${data['message']}');
          break;
        
        default:
          print('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('Message handling error: $e');
    }
  }

  Future<void> _playAudio(Uint8List audioData) async {
    try {
      print('Received audio from Miku: ${audioData.length} bytes');
      
      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await tempFile.writeAsBytes(audioData);
      
      // Play using just_audio
      await _audioPlayer.setFilePath(tempFile.path);
      await _audioPlayer.play();
      
      // Clean up after playing
      _audioPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          tempFile.delete().catchError((e) => print('Temp file cleanup error: $e'));
        }
      });
    } catch (e) {
      print('Audio playback error: $e');
    }
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  bool get isConnected => _isConnected;
}
