import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

/// Página de câmera para escaneamento de QR codes para associar ao cadastro.
/// Gerencia permissões, inicialização e visualização da câmera para identificação
/// e cadastro através de códigos QR.
class CadastrarQRCodePage extends StatefulWidget {
  final String nome;
  final String descricao;
  final bool isLocal;

  const CadastrarQRCodePage({
    super.key,
    required this.nome,
    required this.descricao,
    required this.isLocal
  });

  @override
  State<CadastrarQRCodePage> createState() => _CadastrarQRCodePageState();
}

class _CadastrarQRCodePageState extends State<CadastrarQRCodePage> {
  final TextEditingController _tagController = TextEditingController();
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  bool _isLoading = false;

  String _qrCode = "";

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
        });

        return;
      }

      try {
        await _initializeControllerFuture;
        setState(() {
          _isCameraInitialized = true;
          _isCameraError = false;
        });
      } catch (e) {
        setState(() {
          _isCameraError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isCameraError = true;
      });
    }
  }

  bool _readingEnabled = true;

  void scanQR(BarcodeCapture scan) {
    handleInput(scan.barcodes.first.rawValue ?? "");
  }

  void handleInput(String input) {
    if (!_readingEnabled) return;

    setState(() {
      _qrCode = input;
      _readingEnabled = false;
    });
  }

  Future<dynamic> saveItem() async {
    await dotenv.load(fileName: '.env');

    final String uri = dotenv.env['API_URL']!;
    final String endpoint = widget.isLocal ? "package" : "item";

    setState(() {
      _isLoading = true;
    });

    print('cadastro');
    print(widget.isLocal);
    print(_qrCode);

    try {
      final response = await http.post(
        Uri.parse('$uri/$endpoint'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, Map>{
          "record": {
            'id': _qrCode,
            'name': widget.nome,
            'description': widget.descricao,
          }
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: response.statusCode == 200
              ? Text('${widget.isLocal ? "Local" : "Item"} cadastrado com sucesso!')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Erro ao cadastrar: ${response.statusCode}'),
                    Text('Razão: ${jsonDecode(response.body)['error'] ?? response.body}')
                  ],
                ),
          backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context); // Voltar também para a tela de cadastro
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Erro ao processar cadastro: $err"),
          ]
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 10),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isCameraInitialized) _cameraController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar com QR Code'),
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (!_isCameraError) ...[
            MobileScanner(onDetect: scanQR),
            Positioned(
              top: 50.0,
              left: 70,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                height: 130,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  color: const Color.fromRGBO(255, 255, 255, 0.7)
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _qrCode.isEmpty
                            ? "Escaneie o código QR para cadastrar ${widget.isLocal ? "o local" : "o item"}: ${widget.nome}"
                            : "Código escaneado: $_qrCode",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center
                      ),
                    ),
                  ]
                ),
              )
            ),
            Positioned(
              top: 200,
              left: 70,
              child: Container(
                height: 220,
                width: 250,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.2),
                  border: BoxBorder.all(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                )
              )
            )
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Câmera não disponível. Digite o código manualmente:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'Id da etiqueta',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                      ),
                      onPressed: () => handleInput(_tagController.text),
                      child: const Text(
                        'Usar este código',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ]
                ),
              )
            )
          ]
        ],
      ),
      bottomNavigationBar: _qrCode.isEmpty
          ? SizedBox(height: 0)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _isLoading ? null : saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Cadastrar ${widget.isLocal ? "Local" : "Item"}',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
    );
  }
}
