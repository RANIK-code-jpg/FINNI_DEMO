import 'package:flutter/material.dart';
import '../../services/game_state.dart';
import '../../widgets/dino_head.dart';

class ProfileScreen extends StatefulWidget {
  final GameState gameState;
  final VoidCallback onProfileCreated;

  const ProfileScreen({
    super.key,
    required this.gameState,
    required this.onProfileCreated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final petNameController = TextEditingController();

  int selectedColor = 0;
  int selectedVariant = 0;

  static const colors = [
    'green',
    'blue',
    'yellow',
  ];

  static const colorNames = [
    'Зелёный',
    'Синий',
    'Жёлтый',
  ];

  static const patterns = [
    'dots',
    'spikes',
    'stripes',
  ];

  static const patternNames = [
    'Точки',
    'Шипы',
    'Полоски',
  ];

  @override
  void dispose() {
    petNameController.dispose();
    super.dispose();
  }

  String _previewAsset(int color, int pattern) {
    return 'assets/dino/neutral_${patterns[pattern]}_${colors[color]}_small.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание профиля'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Создай своего питомца',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Выбери персонажа и имя питомца. По мере развития он будет расти.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: petNameController,
            decoration: const InputDecoration(
              labelText: 'Имя питомца',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Цвет',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (colorIndex) {
              final selected = selectedColor == colorIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedColor = colorIndex),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? const Color(0xFF1E78C4) : Colors.black12,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        DinoHead(
                          asset: _previewAsset(colorIndex, selectedVariant),
                          size: 74,
                        ),
                        const SizedBox(height: 4),
                        Text(colorNames[colorIndex], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          const Text(
            'Внешний вид',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(3, (patternIndex) {
              final selected = selectedVariant == patternIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedVariant = patternIndex),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? const Color(0xFF1E78C4) : Colors.black12,
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        DinoHead(
                          asset: _previewAsset(selectedColor, patternIndex),
                          size: 74,
                        ),
                        const SizedBox(height: 4),
                        Text(patternNames[patternIndex], style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${colorNames[selectedColor]} • ${patternNames[selectedVariant]}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF245B91),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Рост питомца связан с уровнем: LVL 1 — маленький, '
              'LVL 2 — средний, LVL 3 — большой.',
              style: TextStyle(fontSize: 15),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: createProfile,
              child: const Text(
                'Создать профиль',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void createProfile() {
    final petName = petNameController.text.trim();

    if (petName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введи имя питомца'),
        ),
      );
      return;
    }

    widget.gameState.createProfile(
      petName: petName,
      petColor: selectedColor,
      petVariant: selectedVariant,
    );

    widget.onProfileCreated();
  }
}
