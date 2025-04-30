import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Página de câmera para escaneamento dos itens a serem movidos.
/// Gerencia permissões, inicialização e visualização da câmera para identificação
/// dos itens.
class MoverItensPage extends StatefulWidget {
  const MoverItensPage({Key? key}) : super(key: key);

  @override
  State<MoverItensPage> createState() => _MoverItensPageState();
}

class _MoverItensPageState extends State<MoverItensPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  /// Verifica e solicita permissão de câmera se necessário.
  /// Verifica se a permissão já foi concedida antes de solicitar,
  /// evitando diálogos desnecessários para o usuário.
  Future<void> _checkAndRequestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
      });
      _initializeCamera();
    } else {
      final requestStatus = await Permission.camera.request();

      if (requestStatus.isGranted) {
        setState(() {
          _isCameraPermissionGranted = true;
        });
        _initializeCamera();
      }
    }
  }

  /// Inicializa a câmera.
  /// Configura a câmera traseira com resolução média para otimizar
  /// o reconhecimento da camera.
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    if (cameras.isEmpty) {
      setState(() {
        _isCameraInitialized = false;
      });
      return;
    }

    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _initializeControllerFuture = _cameraController.initialize();

    try {
      await _initializeControllerFuture;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      setState(() {
        _isCameraInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mover Itens'),
        backgroundColor: Colors.grey[850],
      ),
      body: _buildBody(),
    );
  }

  /// Constrói a interface com base no estado da câmera.
  /// Exibe: 1) Solicitação de permissão, 2) Indicador de carregamento,
  /// ou 3) Visualização da câmera para escanear QR codes.
  Widget _buildBody() {
    if (!_isCameraPermissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'É necessário permissão de câmera',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAndRequestCameraPermission,
              child: const Text('Solicitar permissão'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_cameraController);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
