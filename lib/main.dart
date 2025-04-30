import 'package:flutter/material.dart';
import 'pages/mover_items.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tela Inicial',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
      primary: Colors.white,
      onPrimary: Colors.black,
      side: const BorderSide(color: Colors.black, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SICE',
            style: TextStyle(fontSize: 30)),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: customButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoverItensPage()),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.inventory_2, size: 70),
                      SizedBox(height: 8),
                      Text(
                        'Mover Itens',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: customButtonStyle,
                  onPressed: () {
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search, size: 70),
                      SizedBox(height: 8),
                      Text(
                        'Consultar Item / Local',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: customButtonStyle,
                  onPressed: () {
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline, size: 70),
                      SizedBox(height: 8),
                      Text(
                        'Cadastrar Local / Item',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[850],
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          children: const [
            Icon(Icons.account_circle, size: 40, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'usuario_1',
              style: TextStyle(fontSize: 32, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
