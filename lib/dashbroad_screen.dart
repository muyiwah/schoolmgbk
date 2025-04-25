import 'package:flutter/material.dart';

class MyExpansionExample extends StatefulWidget {
  const MyExpansionExample({super.key});

  @override
  State<MyExpansionExample> createState() => _MyExpansionExampleState();
}

class _MyExpansionExampleState extends State<MyExpansionExample> {
  final ExpansionTileController _controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExpansionTileController')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ExpansionTile(
              controller: _controller,
              title: const Text('Click to Expand'),
              children: const [
                ListTile(title: Text('Child 1')),
                ListTile(title: Text('Child 2')),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _controller.expand,
                  child: const Text('Expand'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _controller.collapse,
                  child: const Text('Collapse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
