import 'package:flutter/material.dart';
import 'consultar_items.dart';
import 'local_detalhes.dart';

/// Tela de detalhes do item selecionado.
/// Exibe informações do item e permite navegar para o local onde está.
class ItemDetalhesPage extends StatefulWidget {
  final String id;
  final String nome;
  final String local;

  const ItemDetalhesPage({
    Key? key,
    required this.id,
    required this.nome,
    required this.local,
  }) : super(key: key);

  @override
  State<ItemDetalhesPage> createState() => _ItemDetalhesPageState();
}

class _ItemDetalhesPageState extends State<ItemDetalhesPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _descricao = '';
  String _localId = '';

  @override
  void initState() {
    super.initState();
    _carregarDetalhesItem();
  }

  Future<void> _carregarDetalhesItem() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await Future.delayed(Duration(milliseconds: 800));

      // Dados simulados (vou substituir por chamadas a API)
      _descricao = _gerarDescricaoSimulada(widget.id);
      _localId = _buscarLocalIdSimulado(widget.local);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar detalhes do item: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _gerarDescricaoSimulada(String id) {
    final Map<String, String> descricoes = {
      // Almoxarifado A
      '101': 'Notebook Dell Inspiron 15 3000, processador Intel Core i5, 8GB RAM, SSD 256GB. Estado: excelente. Data de aquisição: 15/03/2024.',
      '102': 'Monitor LG 24 polegadas, Full HD, 75Hz, conexões HDMI e DisplayPort. Em bom estado de conservação. Data de aquisição: 10/01/2024.',
      '103': 'Teclado sem fio Logitech K380, Bluetooth, compatível com Windows e macOS. Pilhas inclusas, pouco uso. Data de aquisição: 22/02/2024.',

      // Depósito Central
      '201': 'Cadeira de escritório ergonômica com ajuste de altura, apoio lombar e apoio para braços. Em bom estado. Data de aquisição: 05/03/2024.',
      '202': 'Mesa de reunião oval para 8 pessoas, tampo em MDF, estrutura metálica. Estado: regular. Data de aquisição: 12/12/2023.',
      '203': 'Armário de arquivos com 4 gavetas, em aço, com fechadura. Estado: bom. Data de aquisição: 18/01/2024.',
      '204': 'Ventilador de teto com 3 pás, controle de velocidade e luminária integrada. Estado: bom. Data de aquisição: 05/02/2024.',

      // Estante 42
      '301': 'Mouse óptico USB Dell, 1200 DPI, preto. Estado: novo. Data de aquisição: 10/04/2024.',
      '302': 'Hub USB com 4 portas, alimentação externa. Em bom estado. Data de aquisição: 15/03/2024.',

      // Demais locais
      '401': 'Impressora a laser HP LaserJet Pro, conexão Wi-Fi, duplex automático. Estado: boa. Data de aquisição: 20/01/2024.',
      '501': 'Pacote com 500 folhas de papel A4, 75g/m². Lacrado. Data de aquisição: 01/04/2024.',
      '601': 'Cabos HDMI 2.0, 2 metros, taxa de transferência de 18 Gbps. Estado: novo. Data de aquisição: 10/03/2024.',
      '701': 'Switch de rede 24 portas Gigabit, gerenciável. Estado: excelente. Data de aquisição: 05/02/2024.',
      '801': 'Fones de ouvido Bluetooth com cancelamento de ruído. Estado: bom. Data de aquisição: 15/03/2024.',
      '901': 'Servidor rack 2U, processador Intel Xeon, 32GB RAM, 4TB armazenamento. Estado: bom. Data de aquisição: 10/01/2024.',
      '1001': 'Desktops HP EliteDesk, Core i7, 16GB RAM, SSD 512GB. Estado: excelente. Data de aquisição: 05/02/2024.',
    };

    return descricoes[id] ?? 'Item do inventário SICE. Sem descrição detalhada disponível.';
  }

  /// Busca o ID do local baseado no nome (simulado).
  String _buscarLocalIdSimulado(String localNome) {
    final Map<String, String> locaisIds = {
      'Almoxarifado A': '1',
      'Depósito Central': '2',
      'Estante 42': '3',
      'Galpão B': '4',
      'Prateleira 7': '5',
      'Seção 12': '6',
      'Estante Z': '7',
      'Corredor 3': '8',
      'Bloco D': '9',
      'Armazém Principal': '10',
    };

    return locaisIds[localNome] ?? '';
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.orange[800],
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            side: BorderSide(color: Colors.orange[800]!),
          ),
          onPressed: () {
            print('Remover item do local');
          },
          child: const Text(
            'Remover do Local',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
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
              onPressed: _carregarDetalhesItem,
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
          // Cabeçalho com ícone e nome do item
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.inventory,
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

          // Seção de local (clicável)
          const Text(
            'LOCAL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // Navegar para o local do item
              if (_localId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocalDetalhesPage(
                      id: _localId,
                      nome: widget.local,
                    ),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.local,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}