import 'package:flutter/material.dart';
import 'consultar_items.dart'; // Importando para usar o modelo Item
import 'item_detalhes.dart'; // Importando para navegação

/// Tela de detalhes do local selecionado.
/// Exibe informações do local e os itens presentes nele.
class LocalDetalhesPage extends StatefulWidget {
  final String id;
  final String nome;

  const LocalDetalhesPage({
    Key? key,
    required this.id,
    required this.nome,
  }) : super(key: key);

  @override
  State<LocalDetalhesPage> createState() => _LocalDetalhesPageState();
}

class _LocalDetalhesPageState extends State<LocalDetalhesPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _descricao = '';
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
      _descricao = _gerarDescricaoSimulada(widget.id);
      _itensNoLocal = _buscarItensNoLocalSimulados(widget.id);

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

  String _gerarDescricaoSimulada(String id) {
    switch (id) {
      case '1':
        return 'Almoxarifado principal localizado no primeiro andar, com 150m² destinados ao armazenamento de equipamentos eletrônicos e materiais de escritório.';
      case '2':
        return 'Depósito central para armazenamento de grandes volumes. Localizado no térreo com acesso para carga e descarga.';
      case '3':
        return 'Estante 42 localizada no corredor C do almoxarifado principal. Destinada a itens de médio porte.';
      case '4':
        return 'Galpão B situado na área externa, reservado para equipamentos e materiais de maior porte.';
      case '5':
        return 'Prateleira 7 dentro do depósito central, destinada a itens de escritório e papelaria.';
      case '6':
        return 'Seção 12 do almoxarifado principal, dedicada a componentes eletrônicos e cabos.';
      case '7':
        return 'Estante Z localizada no final do corredor B, usada para itens de uso menos frequente.';
      case '8':
        return 'Corredor 3 do depósito central, contém itens diversos em processo de classificação.';
      case '9':
        return 'Bloco D do complexo administrativo, reservado para equipamentos de alto valor.';
      case '10':
        return 'Armazém principal com 300m², dividido em seções para diferentes categorias de itens.';
      default:
        return 'Local de armazenamento do sistema.';
    }
  }

  /// Busca itens simulados para o local especificado.
  List<Item> _buscarItensNoLocalSimulados(String localId) {
    // Em uma implementação real, isso seria uma chamada à API
    // que retornaria os itens no local específico
    Map<String, List<Item>> itensSimulados = {
      '1': [ // Almoxarifado A
        Item(id: '101', nome: 'Notebook Dell', local: 'Almoxarifado A'),
        Item(id: '102', nome: 'Monitor LG 24"', local: 'Almoxarifado A'),
        Item(id: '103', nome: 'Teclado sem fio', local: 'Almoxarifado A'),
      ],
      '2': [ // Depósito Central
        Item(id: '201', nome: 'Cadeira de escritório', local: 'Depósito Central'),
        Item(id: '202', nome: 'Mesa de reunião', local: 'Depósito Central'),
        Item(id: '203', nome: 'Armário de arquivos', local: 'Depósito Central'),
        Item(id: '204', nome: 'Ventilador de teto', local: 'Depósito Central'),
      ],
      '3': [ // Estante 42
        Item(id: '301', nome: 'Mouse óptico', local: 'Estante 42'),
        Item(id: '302', nome: 'Hub USB', local: 'Estante 42'),
      ],
      '4': [ // Galpão B
        Item(id: '401', nome: 'Impressora a laser', local: 'Galpão B'),
        Item(id: '402', nome: 'Scanner de mesa', local: 'Galpão B'),
        Item(id: '403', nome: 'Projetor', local: 'Galpão B'),
      ],
      '5': [ // Prateleira 7
        Item(id: '501', nome: 'Pacote de papel A4', local: 'Prateleira 7'),
        Item(id: '502', nome: 'Caixas de canetas', local: 'Prateleira 7'),
        Item(id: '503', nome: 'Grampeadores', local: 'Prateleira 7'),
      ],
      '6': [ // Seção 12
        Item(id: '601', nome: 'Cabos HDMI', local: 'Seção 12'),
        Item(id: '602', nome: 'Adaptadores USB-C', local: 'Seção 12'),
      ],
      '7': [ // Estante Z
        Item(id: '701', nome: 'Switch de rede', local: 'Estante Z'),
        Item(id: '702', nome: 'Roteador Wi-Fi', local: 'Estante Z'),
        Item(id: '703', nome: 'Patch cords', local: 'Estante Z'),
      ],
      '8': [ // Corredor 3
        Item(id: '801', nome: 'Fones de ouvido', local: 'Corredor 3'),
        Item(id: '802', nome: 'Webcams', local: 'Corredor 3'),
      ],
      '9': [ // Bloco D
        Item(id: '901', nome: 'Servidor rack', local: 'Bloco D'),
        Item(id: '902', nome: 'UPS 3KVA', local: 'Bloco D'),
      ],
      '10': [ // Armazém Principal
        Item(id: '1001', nome: 'Desktops', local: 'Armazém Principal'),
        Item(id: '1002', nome: 'Monitores ultrawide', local: 'Armazém Principal'),
        Item(id: '1003', nome: 'Tablets', local: 'Armazém Principal'),
        Item(id: '1004', nome: 'Smartphones', local: 'Armazém Principal'),
      ],
    };

    return itensSimulados[localId] ?? [];
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
              _descricao,
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