import 'package:flutter/material.dart';

/// Tela para cadastro de novos locais ou itens no sistema.
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

  void _cadastrar() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCadastroLocal
            ? 'Local cadastrado com sucesso!'
            : 'Item cadastrado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      _nomeController.clear();
      _descricaoController.clear();

      Navigator.of(context).pop();
    });
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
                      // primary: _isCadastroLocal ? Colors.orange : Colors.white,
                      // onPrimary: _isCadastroLocal ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: _isCadastroLocal ? Colors.orange : Colors.grey,
                      ),
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
                      // primary: !_isCadastroLocal ? Colors.orange : Colors.white,
                      // onPrimary: !_isCadastroLocal ? Colors.white : Colors.black,
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
                // primary: Colors.orange,
                // onPrimary: Colors.white,
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              onPressed: _isLoading ? null : _cadastrar,
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
                // primary: Colors.white,
                // onPrimary: Colors.orange,
                minimumSize: Size(double.infinity, 50),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                side: BorderSide(color: Colors.orange),
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
