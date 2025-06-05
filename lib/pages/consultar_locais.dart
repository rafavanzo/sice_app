import 'dart:convert';
import 'package:flutter/material.dart';
import 'local_detalhes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  /// Filtra locais pelo nome (simulado).
  /// Retorna lista filtrada de objetos Local.
  Future<List<dynamic>> buscarLocaisPorNome(
      String query, List<dynamic> locais) async {
    if (query.isEmpty) {
      return locais;
    }

    return locais
        .where((local) =>
            local['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Página para consulta e visualização de locais.
/// Permite pesquisa, listagem e acesso à leitura de QR code.
class ConsultarLocaisPage extends StatefulWidget {
  const ConsultarLocaisPage({super.key});

  @override
  State<ConsultarLocaisPage> createState() => _ConsultarLocaisPageState();
}

class _ConsultarLocaisPageState extends State<ConsultarLocaisPage> {
  final TextEditingController _pesquisaController = TextEditingController();
  final LocalService _localService = LocalService();

  List<dynamic> _locais = [];
  List<dynamic> _locaisFiltrados = [];

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
    try {
      await dotenv.load(fileName: '.env');

      String uri = '${dotenv.env['API_URL']!}/package';

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final res = await http.get(Uri.parse(uri), headers: <String, String>{
        'Content-type': 'application/json; charset=UTF-8'
      });

      if (res.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });

        return;
      }

      final List<dynamic> locais = jsonDecode(res.body)['data'];

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
        _locaisFiltrados = List<dynamic>.from(_locais);
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> locaisFiltrados =
          await _localService.buscarLocaisPorNome(query, _locais);

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
        title: const Text('Consultar Locais'),
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          elevation: 0,
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
            // primary: Colors.orange,
            // onPrimary: Colors.white,
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
            local['name'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          onTap: () {
            // Navegar para a view detalhada do local
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalDetalhesPage(
                  id: local['id'],
                  nome: local['name'],
                  descricao: local['description'],
                  local: _locais,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
