import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// Página de câmera para escaneamento de QR codes dos itens a serem movidos.
/// Gerencia permissões, inicialização e visualização da câmera para identificação
/// dos itens através de seus códigos QR.
class MoverItensPage extends StatefulWidget {
  const MoverItensPage({Key? key}) : super(key: key);

  @override
  State<MoverItensPage> createState() => _MoverItensPageState();
}

class _MoverItensPageState extends State<MoverItensPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Inicializa a câmera para leitura de QR codes.
  /// Configura a câmera traseira com resolução média para otimizar
  /// o reconhecimento de QR codes com boa performance.
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _isCameraError = true;
          _errorMessage = 'Nenhuma câmera encontrada no dispositivo.';
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
          _isCameraError = false;
        });
      } catch (e) {
        setState(() {
          _isCameraError = true;
          _errorMessage = 'Erro ao inicializar a câmera: ${e.toString()}';
        });
      }
    } catch (e) {
      setState(() {
        _isCameraError = true;
        _errorMessage = 'Erro ao acessar a câmera: ${e.toString()}';
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
  /// Exibe: 1) Mensagem de erro, 2) Indicador de carregamento,
  /// ou 3) Visualização da câmera para escanear QR codes.
  Widget _buildBody() {
    if (_isCameraError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Tentar novamente'),
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
