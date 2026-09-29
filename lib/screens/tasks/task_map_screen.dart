import 'package:flutter/material.dart';
import 'task_game_screen.dart';
import '../../services/game_state.dart';
class TaskMapScreen extends StatelessWidget {
  final String sectionTitle;
  final GameState gameState;
  const TaskMapScreen({
    super.key,
    required this.sectionTitle,
    required this.gameState,
  });

  List<Map<String, dynamic>> get tasks {
    if (sectionTitle == 'Управляй деньгами') {
      return [
        {
          'title': 'Первый бюджет',
          'description': 'Распредели деньги по категориям',
          'icon': '💰',
          'available': true,
        },
        {
          'title': 'Обязательные расходы',
          'description': 'Определи, что нужно оплатить в первую очередь',
          'icon': '🏠',
          'available': true,
        },
        {
          'title': 'План на период',
          'description': 'Составь план расходов и накоплений',
          'icon': '📊',
          'available': true,
        },
        {
          'title': 'Проверка бюджета',
          'description': 'Сравни план с реальными расходами',
          'icon': '📋',
          'available': true,
        },
        {
          'title': 'Мастер бюджета',
          'description': 'Пройди все задания раздела',
          'icon': '🏆',
          'available': true,
        },
      ];
    }

    if (sectionTitle == 'Копи на мечту') {
      return [
        {
          'title': 'Моя мечта',
          'description': 'Выбери финансовую цель',
          'icon': '🎯',
          'available': true,
        },
        {
          'title': 'Первая копилка',
          'description': 'Отложи первые деньги',
          'icon': '🐷',
          'available': true,
        },
        {
          'title': 'Продолжаем копить',
          'description': 'Реши, сколько можно отложить',
          'icon': '💰',
          'available': true,
        },
        {
          'title': 'Проверка цели',
          'description': 'Посмотри, сколько осталось накопить',
          'icon': '📈',
          'available': true,
        },
        {
          'title': 'Большая мечта',
          'description': 'Достигни своей финансовой цели',
          'icon': '🏆',
          'available': true,
        },
      ];
    }

    return [
      {
        'title': 'Нужная покупка',
        'description': 'Определи, действительно ли тебе это нужно',
        'icon': '🛒',
        'available': true,
      },
      {
        'title': 'Хватит ли денег?',
        'description': 'Проверь свой баланс перед покупкой',
        'icon': '🪙',
        'available': true,
      },
      {
        'title': 'Покупка с выбором',
        'description': 'Выбери подходящий вариант',
        'icon': '🛍️',
        'available': true,
      },
      {
        'title': 'Не хватает денег',
        'description': 'Что делать, если денег недостаточно?',
        'icon': '🤔',
        'available': true,
      },
      {
        'title': 'Умный покупатель',
        'description': 'Пройди все задания раздела',
        'icon': '🏆',
        'available': true,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final taskList = tasks;

    return Scaffold(
      appBar: AppBar(
        title: Text(sectionTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Твой путь',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Проходи задания и двигайся вперёд!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 30),

            ...List.generate(
              taskList.length,
              (index) {
                final task = taskList[index];

                return Column(
                  children: [
                    _TaskNode(
                      number: index + 1,
                      title: task['title'],
                      description: task['description'],
                      icon: task['icon'],
                      isAvailable: task['available'],
                      onTap: () {
                        _openTask(
                          context,
                          index + 1,
                          task['title'],
                        );
                      },
                    ),

                    if (index < taskList.length - 1)
                      const _Road(),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              '🌟 Продолжай свой путь!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTask(
  BuildContext context,
  int taskNumber,
  String taskTitle,
) {
  final taskList = tasks;

  if (!taskList[taskNumber - 1]['available']) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Это задание откроется позже',
        ),
      ),
    );

    return;
  }

  // Пока полноценный сюжетный экран есть
  // только у первого задания раздела "Управляй деньгами".
  if (sectionTitle == 'Управляй деньгами' &&
      taskNumber == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskGameScreen(
          gameState: gameState,
          taskNumber: taskNumber,
          taskTitle: taskTitle,
        ),
      ),
    );

    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Сюжет для "$taskTitle" скоро появится 🦕',
      ),
    ),
  );
}
}

class _TaskNode extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String icon;
  final bool isAvailable;
  final VoidCallback onTap;

  const _TaskNode({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAvailable ? 1.0 : 0.45,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isAvailable
                ? Colors.green.shade100
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isAvailable
                  ? Colors.green.shade300
                  : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(
                      fontSize: 38,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Задание $number',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                isAvailable
                    ? Icons.arrow_forward_ios
                    : Icons.lock,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Road extends StatelessWidget {
  const _Road();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 35,
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}