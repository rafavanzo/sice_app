import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

/// Página de câmera para escaneamento de QR codes dos itens a serem movidos.
/// Gerencia permissões, inicialização e visualização da câmera para identificação
/// dos itens através de seus códigos QR.
class MoverItensPage extends StatefulWidget {
  const MoverItensPage({super.key});

  @override
  State<MoverItensPage> createState() => _MoverItensPageState();
}

class _MoverItensPageState extends State<MoverItensPage> {
  final TextEditingController _tagController = TextEditingController();
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraInitialized = false;
  bool _isCameraError = false;
  bool _firstScan = true;
  bool _isLoading = false;

  String _localQr = "";

  final List<dynamic> _itens = [];

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

    if (_firstScan) {
      setState(() {
        _localQr = input;
      });
    }

    if (!_firstScan) {
      setState(() {
        _itens.add(input);
        _readingEnabled = false;
      });
    }
  }

  Future<dynamic> saveSchema() async {
    await dotenv.load(fileName: '.env');

    final String uri = dotenv.env['API_URL']!;

    setState(() {
      _isLoading = true;
    });

    int successCount = 0;
    bool newPackageCreated = false;
    List<String> failedItems = [];

    try {
      for (var itemId in _itens) {
        try {
          final response = await http.post(
            Uri.parse('$uri/item'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode(<String, Map>{
               "record": {
                   // 'id': itemId,
                   'packageId': _localQr,
                   'tagid': _localQr,
                   'name': "item $itemId",
                   'description': 'A inserir',
                }
            }),
          );

          if (response.statusCode == 200) {
            successCount++;
          } else {
            failedItems.add('$itemId (Erro: ${response.statusCode})');
          }
        } catch (itemError) {
          failedItems.add('$itemId (Erro: $itemError)');
        }

        if(failedItems.length != _itens.length) {
            final newPackageResponse = await http.post(
                Uri.parse('$uri/package'),
                headers: {'Content-Type': 'application/json; charset=UTF-8'},
                body: jsonEncode(<String, Map>{
                    "record": {
                        "name": "Prateleira ${_itens.length}",
                        "packageId": 10,
                        "tagid": _localQr,
                        "description": "a inserir"
                    }
                })
            );

            if(newPackageResponse.statusCode != 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: newPackageResponse.statusCode == 200
                        ? Text('Local cadastrado com sucesso!')
                        : Column(children: [
                            Text('Erro ${newPackageResponse.statusCode}'),
                            Text('Razão ${newPackageResponse.body}')
                          ]),
                    backgroundColor: newPackageResponse.statusCode != 200 ? Colors.red : Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
            } else {
                newPackageCreated = true;
            }
        }
      }

      final message = successCount == _itens.length
          ? 'Todos os ${_itens.length} itens foram movidos com sucesso!'
          : 'Movidos $successCount de ${_itens.length} itens.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (failedItems.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Falhas:'),
                ...failedItems.take(3).map((item) => Text('- $item')),
                if (failedItems.length > 3)
                  Text('+ ${failedItems.length - 3} outros erros')
              ]
            ],
          ),
          backgroundColor: failedItems.isEmpty ? Colors.green : Colors.orange,
          duration: Duration(seconds: 8),
        ),
      );

      if(successCount == _itens.length && newPackageCreated) {
          Navigator.pop(context);
      }
    } catch (err) {
      // ignore: avoid_print
      print(err);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Erro ao processar movimentação: $err"),
        ]),
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mover Itens'),
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
                        color: const Color.fromRGBO(255, 255, 255, 0.7)),
                    child: Row(children: [
                      Flexible(
                        child: _firstScan
                            ? Text(
                                "Leia o código de um local para começar a adicionar itens",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center)
                            : Text(
                                "Leia uma Etiqueta/Item para inserir em: $_localQr",
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center),
                      ),
                    ]),
                  )),
              Positioned(
                  top: 200,
                  left: 70,
                  child: Container(
                      height: 220,
                      width: 250,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          border: BoxBorder.all(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(4)))))
            ] else ...[
              Center(
                  child: Column(children: [
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      minimumSize: Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      side: BorderSide(color: Colors.orange)),
                  onPressed: () => handleInput(_tagController.text),
                  child: const Text(
                    'Ler etiqueta',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              ]))
            ]
          ],
        ),
        bottomNavigationBar: Builder(builder: (builderCtx) {
          if (_firstScan & _localQr.isNotEmpty) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_localQr),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _firstScan = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(200.0, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: Text("Adicionar Local?"),
              ),
              SizedBox(
                height: 12,
              )
            ]);
          }

          if (!_firstScan & _itens.isNotEmpty) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(height: 20),
              Text("Local: $_localQr"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              setState(() {
                                _firstScan = false;
                                _readingEnabled = true;
                              });
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.blue),
                            child: Text('Continuar movendo itens'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              saveSchema();
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                            child: Text('Finalizar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(200.0, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Column(children: [
                        Text("Itens: ${_itens.length}"),
                        Text("Finalizar?"),
                      ]),
              ),
              SizedBox(
                height: 12,
              )
            ]);
          } else {
            return SizedBox(
              width: 0,
            );
          }
        }));
  }
}
