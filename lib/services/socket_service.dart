import 'dart:math';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/incident.dart';

typedef IncidentCallback = void Function(Incident incident);

class SocketService {
  SocketService._internal();
  static final SocketService instance = SocketService._internal();

  // IMPORTANTE: cambia esto por la URL real de tu backend en Render.
  static const String backendUrl = 'https://werable.onrender.com';

  io.Socket? _socket;
  final String userId = 'watch-${Random().nextInt(1000)}';

  IncidentCallback? onIncidentCreated;
  IncidentCallback? onIncidentUpdated;

  void connect() {
    if (_socket != null) return;

    _socket = io.io(
      backendUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) => print('[Socket] Conectado a $backendUrl'));
    _socket!.onConnectError((e) => print('[Socket] Error de conexión: $e'));

    _socket!.on('incidentCreated', (data) {
      final incident = Incident.fromJson(Map<String, dynamic>.from(data));
      onIncidentCreated?.call(incident);
    });

    _socket!.on('incidentUpdated', (data) {
      final incident = Incident.fromJson(Map<String, dynamic>.from(data));
      onIncidentUpdated?.call(incident);
    });
  }

  void claimIncident(String incidentId, void Function(Map<String, dynamic>) callback) {
    _socket?.emitWithAck(
      'claimIncident',
      {'incidentId': incidentId, 'userId': userId},
      ack: (response) => callback(Map<String, dynamic>.from(response)),
    );
  }

  void rejectIncident(String incidentId) {
    _socket?.emit('rejectIncident', {'incidentId': incidentId, 'userId': userId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
