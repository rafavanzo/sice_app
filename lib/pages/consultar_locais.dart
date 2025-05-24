import 'package:flutter/material.dart';
import 'local_detalhes.dart';

/// Modelo para representar um local no sistema.
/// Contém id e nome, mas mudarei futuramente para incluir mais informações.
class Local {
  final String id;
  final String nome;

  Local({required this.id, required this.nome});
}

/// Serviço que encapsula operações de dados.
/// Preparado para futura substituição por API real.
class LocalService {
  /// Busca todos os locais (simulado).
  /// Será substituído por chamada à API real.
  Future<List<Local>> buscarLocais() async {
    await Future.delayed(Duration(milliseconds: 800));

    return [
      Local(id: '1', nome: 'Almoxarifado A'),
      Local(id: '2', nome: 'Depósito Central'),
      Local(id: '3', nome: 'Estante 42'),
      Local(id: '4', nome: 'Galpão B'),
      Local(id: '5', nome: 'Prateleira 7'),
      Local(id: '6', nome: 'Seção 12'),
      Local(id: '7', nome: 'Estante Z'),
      Local(id: '8', nome: 'Corredor 3'),
      Local(id: '9', nome: 'Bloco D'),
      Local(id: '10', nome: 'Armazém Principal'),
    ];
  }

  /// Filtra locais pelo nome (simulado).
  /// Retorna lista filtrada de objetos Local.
  Future<List<Local>> buscarLocaisPorNome(String query) async {
    final locais = await buscarLocais();

    if (query.isEmpty) {
      return locais;
    }

    return locais
        .where((local) => local.nome.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Página para consulta e visualização de locais.
/// Permite pesquisa, listagem e acesso à leitura de QR code.
class ConsultarLocaisPage extends StatefulWidget {
  const ConsultarLocaisPage({Key? key}) : super(key: key);

  @override
  State<ConsultarLocaisPage> createState() => _ConsultarLocaisPageState();
}

class _ConsultarLocaisPageState extends State<ConsultarLocaisPage> {
  final TextEditingController _pesquisaController = TextEditingController();
  final LocalService _localService = LocalService();

  List<Local> _locais = [];
  List<Local> _locaisFiltrados = [];

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _locais = [];
    _locaisFiltrados = [];
    _carregarLocais();
  }

  /// Carrega a lista inicial de locais.
  /// Ponto futuro de integração com API real.
  Future<void> _carregarLocais() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final locais = await _localService.buscarLocais();
      setState(() {
        _locais = locais;
        _locaisFiltrados = locais;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar locais: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Filtra a lista de locais pelo texto digitado.
  /// Otimiza para consultas vazias sem chamar API.
  Future<void> _filtrarLocais(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locaisFiltrados = List<Local>.from(_locais);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Local> locaisFiltrados = await _localService.buscarLocaisPorNome(query);

      setState(() {
        _locaisFiltrados = locaisFiltrados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao filtrar locais: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pesquisaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Consultar Locais',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PESQUISAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pesquisaController,
                        onChanged: (String value) {
                          _filtrarLocais(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Digite para buscar um local',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _filtrarLocais(_pesquisaController.text);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildListaLocais(),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            onPrimary: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          onPressed: () {
            // Levara a camera para ler o QR Code
          },
          child: const Text(
            'Ler uma Etiqueta',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// Constrói a lista conforme o estado atual:
  /// carregando, erro, vazia ou com dados.
  Widget _buildListaLocais() {
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
              onPressed: _carregarLocais,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_locaisFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum local encontrado',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _locaisFiltrados.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final local = _locaisFiltrados[index];
        return ListTile(
          title: Text(
            local.nome,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0
          ),
          onTap: () {
            // Navegar para a view detalhada do local
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalDetalhesPage(
                  id: local.id,
                  nome: local.nome,
                ),
              ),
            );
          },
        );
      },
    );
  }
}