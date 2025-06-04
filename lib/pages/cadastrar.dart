import 'package:flutter/material.dart';
import 'package:sice_app/complements/qrcode.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Tela para cadastro de novos locais ou itens no sistema.
class CadastrarPage extends StatefulWidget {
  const CadastrarPage({Key? key}) : super(key: key);

  @override
  State<CadastrarPage> createState() => _CadastrarPageState();
}

class _CadastrarPageState extends State<CadastrarPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  bool _isCadastroLocal = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar(String data) async {

    setState(() {
      _isLoading = true;
    });

    await dotenv.load(fileName: ".env");

    String uri = '${dotenv.env['API_URL']!}/${_isCadastroLocal ? "package" : "item" }';

    Future<void> sendItem(Object data) async {
        final res = await http.post(
            Uri.parse(uri),
            headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
            body: data
        );

        Future.delayed(Duration(seconds: 3), () {
            setState(() {
                _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: res.statusCode == 200 ? Text('Local cadastrado com sucesso!') : Column(children: [
                     Text('Erro ${res.statusCode}'),
                     Text('Razão ${res.body}')
                  ]),
                  backgroundColor: res.statusCode != 200 ? Colors.red : Colors.green,
                  duration: Duration(seconds: 2),
                ),
            );

            if(res.statusCode == 200) {

                _nomeController.clear();
                _descricaoController.clear();

                Navigator.of(context).pop();
            }

        });
    }

    sendItem(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cadastro',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção "Cadastrar um novo"
            const Text(
              'CADASTRAR UM NOVO:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Botões de seleção (Local ou Item)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isCadastroLocal ? Colors.orange : Colors.grey,
                        foregroundColor: _isCadastroLocal ? Colors.white : Colors.black
                    ),
                    onPressed: () {
                      setState(() {
                        _isCadastroLocal = true;
                      });
                    },
                    child: const Text('Local', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: !_isCadastroLocal ? Colors.orange : Colors.grey,
                        foregroundColor: !_isCadastroLocal ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: !_isCadastroLocal ? Colors.orange : Colors.grey,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isCadastroLocal = false;
                      });
                    },
                    child: const Text('Item', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Campo Nome
            const Text(
              'NOME',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                hintText: _isCadastroLocal
                    ? 'Nome do local'
                    : 'Nome do item',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Campo Descrição
            const Text(
              'DESCRIÇÃO',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Descrição',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
                children: [
                    const GenQRCode()
                ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              onPressed: () {
                _cadastrar(
                    jsonEncode(<String, Map>{"record": {"name": _nomeController.text, "description": _descricaoController.text} })
                );
              },
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
                    'Cadastrar',
                    style: TextStyle(fontSize: 18),
                  ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                side: BorderSide(color: Colors.orange)
                ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
