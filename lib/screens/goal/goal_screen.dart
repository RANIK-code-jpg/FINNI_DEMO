import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/game_state.dart';
import '../piggy_bank/piggy_bank_screen.dart';

class GoalScreen extends StatelessWidget {
  final GameState gameState;

  const GoalScreen({
    super.key,
    required this.gameState,
  });

  int get _maxContribution {
    final goalLeft =
        math.max(0, gameState.goalCost - gameState.goalProgress);

    return math.min(
      gameState.balance,
      math.min(
        gameState.goalBudgetRemaining,
        goalLeft,
      ),
    ).toInt();
  }

  Future<void> _showContributionDialog(BuildContext context) async {
    final maxAmount = _maxContribution;

    if (!gameState.budgetConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Сначала подтверди бюджет и выдели деньги на цель.',
          ),
        ),
      );
      return;
    }

    if (maxAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gameState.goalCompleted
                ? 'Эта цель уже выполнена.'
                : gameState.goalBudgetRemaining <= 0
                    ? 'В бюджете периода пока нет свободных денег на цель.'
                    : 'Сейчас нечего добавить в цель.',
          ),
        ),
      );
      return;
    }

    final step = maxAmount >= 10 ? 10 : 1;
    final divisions = math.max(1, maxAmount ~/ step);
    int amount = math.min(step, maxAmount);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Пополнить цель'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сколько монет вложить в «${gameState.goal}»?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '$amount 🪙',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: maxAmount.toDouble(),
                    divisions: divisions,
                    value: amount.toDouble(),
                    onChanged: (value) {
                      var next = value.round();
                      if (step > 1) {
                        next = (next / step).round() * step;
                      }
                      next = next.clamp(0, maxAmount).toInt();
                      setDialogState(() {
                        amount = next;
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Доступно сейчас: $maxAmount 🪙',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: amount <= 0
                      ? null
                      : () {
                          final ok = gameState.addToSavings(amount);

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? gameState.goalCompleted
                                        ? 'Цель выполнена! 🎉'
                                        : 'В цель внесено $amount 🪙.'
                                    : 'Не удалось пополнить цель. Проверь бюджет и баланс.',
                              ),
                            ),
                          );
                        },
                  child: const Text('Внести деньги'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final availableToGoal = _maxContribution;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Цель Финни'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gameState.currentLevel >= 3
                            ? 'Все стадии роста открыты!'
                            : gameState.nextLevelBlockedByGoal
                                ? 'Для следующего уровня сначала выполни финансовую цель.'
                                : 'Развитие и выполнение целей помогают Финни расти.',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Выполнено целей: ${gameState.completedGoals.length} / 3',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF245B91),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gameState.goal,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (gameState.goalCompleted)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF2E9B50),
                              size: 30,
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${gameState.goalProgress} / ${gameState.goalCost} 🪙',
                      ),

                      const SizedBox(height: 8),

                      LinearProgressIndicator(
                        value: gameState.goalPercent,
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: gameState.goalCompleted
                              ? const Color(0xFFDDF3D4)
                              : const Color(0xFFF4F4F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          gameState.goalCompleted
                              ? '✓ Цель выполнена'
                              : 'Осталось ${gameState.goalCost - gameState.goalProgress} 🪙',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: gameState.goalCompleted
                                ? const Color(0xFF258B45)
                                : Colors.black87,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'План на цель в этом периоде: ${gameState.goalBudget} 🪙',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Внесено из плана: ${gameState.goalBudgetSpent} / ${gameState.goalBudget} 🪙',
                            ),
                            const SizedBox(height: 5),
                            Text(
                              gameState.budgetConfirmed
                                  ? 'Можно внести сейчас: $availableToGoal 🪙'
                                  : 'Сначала подтверди бюджет в разделе «Бюджет».',
                              style: TextStyle(
                                color: gameState.budgetConfirmed
                                    ? const Color(0xFF258B45)
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: gameState.goalCompleted || availableToGoal <= 0
                              ? null
                              : () => _showContributionDialog(context),
                          icon: const Icon(Icons.savings_outlined),
                          label: const Text(
                            'Внести деньги в цель',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PiggyBankScreen(
                          gameState: gameState,
                        ),
                      ),
                    );
                  },
                  icon: const Text(
                    '🐷',
                    style: TextStyle(fontSize: 24),
                  ),
                  label: const Text(
                    'Открыть Копилку',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Выбери следующую финансовую цель:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              _GoalButton(
                gameState: gameState,
                name: 'Домик Финни',
                cost: 500,
                icon: '🏠',
                description:
                    'Место, которое останется у питомца после достижения цели.',
              ),

              _GoalButton(
                gameState: gameState,
                name: 'Горка для Финни',
                cost: 400,
                icon: '🛝',
                description:
                    'Весёлая покупка, ради которой стоит немного подождать.',
              ),

              _GoalButton(
                gameState: gameState,
                name: 'Корона Финни',
                cost: 700,
                icon: '👑',
                description:
                    'Большая цель для тех, кто умеет планировать.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalButton extends StatelessWidget {
  final GameState gameState;
  final String name;
  final int cost;
  final String icon;
  final String description;

  const _GoalButton({
    required this.gameState,
    required this.name,
    required this.cost,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final selected = gameState.goal == name;
    final completed = gameState.completedGoals.contains(name);

    return Card(
      color: selected && !completed
          ? Colors.green.shade50
          : completed
              ? const Color(0xFFF0F8EE)
              : null,
      child: ListTile(
        leading: Text(
          icon,
          style: const TextStyle(fontSize: 30),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (completed)
              const Text(
                '✓',
                style: TextStyle(
                  color: Color(0xFF2E9B50),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        subtitle: Text(
          completed
              ? '$cost 🪙\n✓ Выполнено'
              : '$cost 🪙\n$description',
        ),
        trailing: completed
            ? const Icon(
                Icons.check_circle,
                color: Color(0xFF2E9B50),
              )
            : selected
                ? const Icon(Icons.radio_button_checked)
                : const Icon(Icons.radio_button_unchecked),
        onTap: completed
            ? null
            : () {
                gameState.setGoal(
                  name: name,
                  cost: cost,
                );
              },
      ),
    );
  }
}
