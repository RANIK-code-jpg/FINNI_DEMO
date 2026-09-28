import 'package:flutter/material.dart';

import '../../services/game_state.dart';

class GrowthStagesScreen extends StatelessWidget {
  final GameState gameState;

  const GrowthStagesScreen({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Стадии роста Финни',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF245B91),
        elevation: 1,
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GrowthStageCard(
                gameState: gameState,
                level: 1,
                title: 'Стадия 1',
                description: 'Маленький Финни',
                unlocked: gameState.currentLevel >= 1,
              ),
              const SizedBox(height: 12),
              _GrowthStageCard(
                gameState: gameState,
                level: 2,
                title: 'Стадия 2',
                description: 'Юный Финни',
                unlocked: gameState.currentLevel >= 2,
              ),
              const SizedBox(height: 12),
              _GrowthStageCard(
                gameState: gameState,
                level: 3,
                title: 'Стадия 3',
                description: 'Большой Финни',
                unlocked: gameState.currentLevel >= 3,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  gameState.currentLevel >= 3
                      ? 'Финни достиг максимального размера! 🎉'
                      : gameState.nextLevelBlockedByGoal
                          ? 'Для следующего роста сначала выполни финансовую цель.'
                          : 'До следующего роста: '
                              '${gameState.pointsToNextLevel} очков развития.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GrowthStageCard extends StatelessWidget {
  final GameState gameState;
  final int level;
  final String title;
  final String description;
  final bool unlocked;

  const _GrowthStageCard({
    required this.gameState,
    required this.level,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 105,
            height: 95,
            decoration: BoxDecoration(
              color: unlocked
                  ? const Color(0xFFFFE0B2)
                  : const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(5),
            child: unlocked
                ? Transform.translate(
                    offset: Offset(
                      gameState.petVisualOffsetX(
                        state: 'neutral',
                        stage: level,
                        renderedWidth: 95,
                      ),
                      0,
                    ),
                    child: Image.asset(
                      gameState.petAsset(
                        state: 'neutral',
                        stage: level,
                      ),
                      width: 95,
                      height: 63,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Center(
                    child: Text(
                      '🔒',
                      style: TextStyle(fontSize: 34),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF245B91),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  unlocked
                      ? 'Открыто на LVL $level'
                      : 'Откроется на LVL $level',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? const Color(0xFF32A852)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
