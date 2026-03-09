import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Color map for text and background",
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: const ColorMatrixPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ColorMatrixPage extends StatefulWidget {
  const ColorMatrixPage({super.key});

  @override
  State<ColorMatrixPage> createState() => _ColorMatrixPageState();
}

class _ColorMatrixPageState extends State<ColorMatrixPage> {
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  final Random random = Random();

  Color randomColor() => Color.fromARGB(
      255, random.nextInt(256), random.nextInt(256), random.nextInt(256));

  String colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  Color? getColorFromHex(String hex) {
    try {
      String cleaned = hex.toUpperCase().replaceAll('#', '');
      if (cleaned.length != 6 && cleaned.length != 8) return null;
      if (cleaned.length == 6) cleaned = 'FF$cleaned';
      return Color(int.parse(cleaned, radix: 16));
    } catch (_) {
      return null;
    }
  }

  Color getContrastingTextColor(Color bg) =>
      bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  void changeColorsRandom() {
    setState(() {
      colors = List.generate(4, (_) => randomColor());
    });
  }

  Future<void> editCell(int index) async {
    String? inputHex = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter hex code (#RRGGBB)'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '#FFFFFF'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (inputHex != null && inputHex.isNotEmpty) {
      final newColor = getColorFromHex(inputHex);
      if (newColor != null) {
        setState(() {
          colors[index] = newColor;
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Color"),
            content: const Text(
                "Please enter a valid hex color like #RRGGBB."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    }
  }

  Widget buildCell(int index) {
    Color color = colors[index];

    return GestureDetector(
      onTap: () => editCell(index),
      child: Container(
        width: 120,
        height: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.9),
              color,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 3),
            )
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                colorToHex(color),
                style: TextStyle(
                  color: getContrastingTextColor(color),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.35),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, Color>> getPairs() {
    List<Map<String, Color>> pairs = [];
    for (var i = 0; i < colors.length; i++) {
      for (var j = 0; j < colors.length; j++) {
        if (i != j) pairs.add({'text': colors[i], 'bg': colors[j]});
      }
    }
    return pairs;
  }

  @override
  Widget build(BuildContext context) {
    final pairs = getPairs();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 30),

            Container(
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Color map for\ntext and background",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "You can click a square to input color of your choice!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCell(0),
                buildCell(1),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildCell(2),
                buildCell(3),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: changeColorsRandom,
              child: const Text("Change Colors Randomly"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Text/Background Combinations",
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepPurple,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey.shade400,
                ),
                children: List.generate(6, (row) {
                  final first = pairs[row * 2];
                  final second = pairs[row * 2 + 1];

                  return TableRow(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: first['bg'],
                      child: Text(
                        '${colorToHex(first['text']!)} on ${colorToHex(first['bg']!)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: first['text']),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: second['bg'],
                      child: Text(
                        '${colorToHex(second['text']!)} on ${colorToHex(second['bg']!)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: second['text']),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}