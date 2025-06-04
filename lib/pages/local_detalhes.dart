import 'package:flutter/material.dart';
import 'consultar_items.dart'; // Importando para usar o modelo Item
import 'item_detalhes.dart'; // Importando para navegação

/// Tela de detalhes do local selecionado.
/// Exibe informações do local e os itens presentes nele.
class LocalDetalhesPage extends StatefulWidget {
  final dynamic id;
  final String nome;
  final String? descricao;

  const LocalDetalhesPage({
    Key? key,
    required this.id,
    required this.nome,
    this.descricao
  }) : super(key: key);

  @override
  State<LocalDetalhesPage> createState() => _LocalDetalhesPageState();
}

class _LocalDetalhesPageState extends State<LocalDetalhesPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<Item> _itensNoLocal = [];

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

      // Dados simulados (vou substituir por chamadas a API)

      setState(() {
        _isLoading = false;
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
                        item.nome,
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
                              id: item.id,
                              nome: item.nome,
                              local: item.local,
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
