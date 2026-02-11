import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  
  // Audio buffer for accumulating PCM chunks before sending
  final List<int> _audioBuffer = [];
  Timer? _sendTimer;
  static const int _sendIntervalMs = 2000; // Send every 2 seconds
  static const int _sampleRate = 16000;
  static const int _numChannels = 1;
  static const int _bitsPerSample = 16;
  
  // Server URL - Mac's local IP on the network
  static const String _serverUrl = 'ws://192.168.1.13:8000/call/connect';
  
  Future<void> initialize() async {
    // Request microphone permission
    await Permission.microphone.request();
  }

  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
      await _channel!.ready;
      
      _channel!.stream.listen(
        _handleServerMessage,
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket closed');
          _isConnected = false;
          _stopSendTimer();
        },
      );
      
      _isConnected = true;
      await _startRecording();
      _startSendTimer();
      
    } catch (e) {
      print('Connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  Future<void> disconnect() async {
    _stopSendTimer();
    _audioBuffer.clear();
    await _stopRecording();
    await _channel?.sink.close();
    _isConnected = false;
  }

  void _startSendTimer() {
    _sendTimer = Timer.periodic(
      const Duration(milliseconds: _sendIntervalMs),
      (_) => _flushAudioBuffer(),
    );
  }

  void _stopSendTimer() {
    _sendTimer?.cancel();
    _sendTimer = null;
  }

  void _flushAudioBuffer() {
    if (_audioBuffer.isEmpty || !_isConnected) return;
    
    final pcmData = Uint8List.fromList(_audioBuffer);
    _audioBuffer.clear();
    
    // Wrap PCM in WAV header so server receives valid WAV
    final wavData = _addWavHeader(pcmData);
    _sendAudioToServer(wavData);
  }

  Uint8List _addWavHeader(Uint8List pcmData) {
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;
    final byteRate = _sampleRate * _numChannels * (_bitsPerSample ~/ 8);
    final blockAlign = _numChannels * (_bitsPerSample ~/ 8);
    
    final header = ByteData(44);
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little);  // PCM format
    header.setUint16(22, _numChannels, Endian.little);
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, _bitsPerSample, Endian.little);
    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);
    
    final wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcmData);
    return wav;
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;
    
    try {
      // Check permission
      if (await _audioRecorder.hasPermission()) {
        // Start recording (stream mode for real-time)
        final stream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        
        _isRecording = true;
        
        // Accumulate audio chunks in buffer
        stream.listen((audioData) {
          if (!_isMuted && _isConnected) {
            _audioBuffer.addAll(audioData);
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
          tempFile.delete().ignore();
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
