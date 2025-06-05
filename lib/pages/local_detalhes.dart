import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'item_detalhes.dart'; // Importando para navegação

/// Tela de detalhes do local selecionado.
/// Exibe informações do local e os itens presentes nele.
// ignore: must_be_immutable
class LocalDetalhesPage extends StatefulWidget {
  final dynamic id;
  final String nome;
  final String? descricao;

  dynamic local;

  LocalDetalhesPage(
      {super.key,
      required this.id,
      required this.nome,
      required this.local,
      this.descricao});

  @override
  State<LocalDetalhesPage> createState() => _LocalDetalhesPageState();
}

class _LocalDetalhesPageState extends State<LocalDetalhesPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<dynamic> _itensNoLocal = [];

  @override
  void initState() {
    super.initState();
    _carregarDetalhesLocal();
  }

  Future<void> _carregarDetalhesLocal() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.delayed(Duration(milliseconds: 800));

      await dotenv.load(fileName: '.env');

      String uri = '${dotenv.env['API_URL']}/item?packageId=${widget.id}';

      final packageItens = await http.get(Uri.parse(uri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });

      if (packageItens.statusCode != 200) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        return;
      }

      final packageItensData = jsonDecode(packageItens.body)['data'];

      setState(() {
        _isLoading = false;
        _itensNoLocal = packageItensData;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar detalhes do local: ${e.toString()}';
        _isLoading = false;
      });
    }
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
        title: Text(''),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarDetalhesLocal,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com ícone e nome do local
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.nome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção de descrição
          const Text(
            'DESCRIÇÃO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              widget.descricao ?? "",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Seção de itens no local
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ITENS NESTE LOCAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              Text(
                '${_itensNoLocal.length} itens',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lista de itens no local
          _itensNoLocal.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhum item cadastrado neste local',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _itensNoLocal.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _itensNoLocal[index];
                    return ListTile(
                      title: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      tileColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      onTap: () {
                        // Navegar para a view do item
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetalhesPage(
                              id: item['id'].toString(),
                              nome: item['name'],
                              description: item['description'],
                              local: widget.local,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }
}
