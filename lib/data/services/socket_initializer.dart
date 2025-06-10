import 'package:flutter/material.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/injection.dart';

class SocketInitializer extends StatefulWidget {
  final Widget child;

  const SocketInitializer({super.key, required this.child});

  @override
  State<SocketInitializer> createState() => _SocketInitializerState();
}

class _SocketInitializerState extends State<SocketInitializer> {
  late Future<void> _socketInitFuture;

  @override
  void initState() {
    super.initState();
    _socketInitFuture = _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    try {
      final socketService = getIt<SocketService>();
      final socketUrl = getIt<String>(instanceName: 'socketUrl');
      await socketService.initSocket(socketUrl);
      print("Socket inicializado correctamente");
    } catch (e) {
      print("Error inicializando socket: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _socketInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Socket inicializado (o falló pero seguimos adelante)
        return widget.child;
      },
    );
  }
}
