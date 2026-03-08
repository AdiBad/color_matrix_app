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
        fontFamily: 'Roboto', // consistent Notes-style font
      ),
      home: const ColorMatrixPage(),
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
        // Show warning dialog for invalid input
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Color"),
            content: const Text(
                "The color you entered is invalid. Please use a hex code like #RRGGBB."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK"))
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
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ],
        ),
        width: 120,
        height: 120,
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            colorToHex(color),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: getContrastingTextColor(color),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, Color>> getUniquePairs() {
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
    final pairs = getUniquePairs(); // 12 pairs
    return Scaffold(
      appBar: AppBar(title: const Text("Color map for text and background")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Text(
              "You can also click a square to input color of your choice!",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 2x2 matrix
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              buildCell(0),
              buildCell(1),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              buildCell(2),
              buildCell(3),
            ]),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: changeColorsRandom,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Change Colors Randomly"),
            ),
            const SizedBox(height: 10),

            // Table header
            const Text(
              "Text/Background Combinations:",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Leaner, rounded table
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
                  children: List.generate(6, (rowIndex) {
                    final first = pairs[rowIndex * 2];
                    final second = pairs[rowIndex * 2 + 1];
                    return TableRow(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: first['bg'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${colorToHex(first['text']!)} on ${colorToHex(first['bg']!)}',
                          style: TextStyle(
                            color: first['text'],
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: second['bg'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${colorToHex(second['text']!)} on ${colorToHex(second['bg']!)}',
                          style: TextStyle(
                            color: second['text'],
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}