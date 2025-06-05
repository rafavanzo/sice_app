import 'dart:convert';
import 'package:flutter/material.dart';
import 'item_detalhes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Modelo para representar um item no sistema.
/// Contém id, nome e local do item.
class Item {
  final int id;
  final int tagid;
  final int categoryid;
  final int userid;
  final int packageid;

  final String name;
  final String description;
  // final String local;

  Item(
      {required this.id,
      required this.name,
      required this.description,
      required this.tagid,
      required this.categoryid,
      required this.packageid,
      required this.userid
      // required this.local
      });
}

/// Serviço que encapsula operações de dados de itens.
/// Preparado para futura substituição por API real.
class ItemService {
  /// Filtra itens pelo nome (simulado).
  /// Retorna lista filtrada de objetos Item.
  Future<List<dynamic>> buscarItemsPorNome(
      String query, List<dynamic> items) async {
    if (query.isEmpty) {
      return items;
    }

    return items
        .where((item) =>
            item['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Página para consulta e visualização de itens.
/// Permite pesquisa, listagem e acesso à leitura de QR code.
class ConsultarItemsPage extends StatefulWidget {
  const ConsultarItemsPage({super.key});

  @override
  State<ConsultarItemsPage> createState() => _ConsultarItemsPageState();
}

class _ConsultarItemsPageState extends State<ConsultarItemsPage> {
  final TextEditingController _pesquisaController = TextEditingController();
  final ItemService _itemService = ItemService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _items = [];
  List<dynamic> _itemsFiltrados = [];

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _items = [];
    _itemsFiltrados = [];
    _carregarItems();
  }

  dynamic _carregarLocal(
      String id, String nome) async {
    try {
      await dotenv.load(fileName: ".env");

      String uri = '${dotenv.env['API_URL']}';

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final package = await http.get(Uri.parse('$uri/package?id=$id'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });

      if (package.statusCode != 200) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        final errorData = jsonDecode(package.body);

        return { "error": true, "statusCode": package.statusCode, "body": errorData['error']};
      }

      final dynamic packageData = jsonDecode(package.body)['data'];

        setState(() {
            _isLoading = false;
        });

        return {"id": id, "nome": nome, "packageData": packageData };
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar itens: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Carrega a lista inicial de itens.
  /// Ponto futuro de integração com API real.
  Future<void> _carregarItems() async {
    try {
      await dotenv.load(fileName: ".env");

      String uri = dotenv.env['API_URL']!;

      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final item = await http.get(
        Uri.parse("$uri/item"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      if (item.statusCode != 200) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });

        return;
      }

      final dynamic itemData = jsonDecode(item.body)['data'];

      setState(() {
        _items = itemData;
        _itemsFiltrados = itemData;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar itens: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Filtra a lista de itens pelo texto digitado.
  /// Otimiza para consultas vazias sem chamar API.
  Future<void> _filtrarItems(String query) async {
    if (query.isEmpty) {
      setState(() {
        _itemsFiltrados = _items;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> itemsFiltrados =
          await _itemService.buscarItemsPorNome(query, _items);

      setState(() {
        _itemsFiltrados = itemsFiltrados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao filtrar itens: ${e.toString()}';
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
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Consultar Itens',
          style: TextStyle(color: Colors.white),
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
                          _filtrarItems(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Digite para buscar um item',
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
                          _filtrarItems(_pesquisaController.text);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildListaItems(),
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
  Widget _buildListaItems() {
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
              onPressed: () {
                _carregarItems();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_itemsFiltrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum item encontrado',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _itemsFiltrados.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = _itemsFiltrados[index];
        return ListTile(
          title: Text(
            item['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${item['description']}'),
            ],
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          onTap: () async {
              final res = await _carregarLocal(item['tagid'].toString(), item['name']);

              if(res["error"] == true) {
                ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
                  SnackBar(
                    content: Column(children: [
                        Text('Erro ${res["statusCode"]}'),
                        Text('Razão: ${res["body"]}')
                    ]),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );

                return;
              }

              Navigator.push(
                  _scaffoldKey.currentContext!,
                  MaterialPageRoute(
                      builder: (context) => ItemDetalhesPage(id: res['id'], nome: res['nome'], local: res['packageData'])
                    )
                );
            },
        );
      },
    );
  }
}
