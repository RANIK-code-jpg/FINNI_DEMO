import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/game_state.dart';
import '../../widgets/dino_head.dart';
import 'task_game_screen.dart';


// ============================================================
// ЭКРАН ЗАДАНИЙ
// ============================================================

class TasksScreen extends StatelessWidget {
  final GameState gameState;

  const TasksScreen({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7E5),
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================================
            // ЗАГОЛОВОК
            // ==========================================================

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Задания',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            // ==========================================================
            // НАГРАДА
            // ==========================================================

            _TimeRewardButton(
              gameState: gameState,
            ),

            const SizedBox(height: 16),

            // ==========================================================
            // РАЗДЕЛЫ
            // ==========================================================

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _SectionButton(
                    dinoAsset: gameState.petAsset(state: 'neutral', stage: 1),
                    title: 'Бюджет',
                    subtitle: 'Планируем и распределяем деньги',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskMapScreen(
                            gameState: gameState,
                            section: TaskSection.budget,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _SectionButton(
                    dinoAsset: gameState.petAsset(state: 'neutral', stage: 1),
                    title: 'Накопления',
                    subtitle: 'Копим на большую цель',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskMapScreen(
                            gameState: gameState,
                            section: TaskSection.savings,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _SectionButton(
                    dinoAsset: gameState.petAsset(state: 'neutral', stage: 1),
                    title: 'Покупки и платежи',
                    subtitle: 'Учимся принимать решения о покупках',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskMapScreen(
                            gameState: gameState,
                            section: TaskSection.purchases,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// НАГРАДА РАЗ В 30 МИНУТ
// ============================================================

class _TimeRewardButton extends StatefulWidget {
  final GameState gameState;

  const _TimeRewardButton({
    required this.gameState,
  });

  @override
  State<_TimeRewardButton> createState() => _TimeRewardButtonState();
}

class _TimeRewardButtonState extends State<_TimeRewardButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _claimReward() {
    final success = widget.gameState.claimTimeReward();

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Следующая награда через '
            '${_formatTime(widget.gameState.rewardSecondsLeft)}',
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final available = widget.gameState.rewardAvailable;

        final secondsLeft =
            widget.gameState.rewardSecondsLeft;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            height: 68,
            child: ElevatedButton(
              onPressed: available ? _claimReward : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: available
                    ? const Color(0xFFCFE68A)
                    : const Color(0xFFD8D8D8),

                disabledBackgroundColor:
                    const Color(0xFFD8D8D8),

                foregroundColor: Colors.black,

                disabledForegroundColor:
                    Colors.grey.shade700,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              child: Row(
                children: [
                  Text(
                    available ? '🪙' : '⏳',
                    style: const TextStyle(
                      fontSize: 29,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          available
                              ? 'Получить награду'
                              : 'Награда получена',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        Text(
                          available
                              ? '+50 🪙'
                              : 'Следующая через '
                                  '${_formatTime(secondsLeft)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    available
                        ? Icons.chevron_right
                        : Icons.lock_clock,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


// ============================================================
// КНОПКА РАЗДЕЛА
// ============================================================

class _SectionButton extends StatelessWidget {
  final String dinoAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SectionButton({
    required this.dinoAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7E5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: DinoHead(
                      asset: dinoAsset,
                      size: 58,
                      borderRadius: BorderRadius.circular(29),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// РАЗДЕЛЫ
// ============================================================

enum TaskSection {
  budget,
  savings,
  purchases,
}


// ============================================================
// КАРТА РАЗДЕЛА
// ============================================================

class TaskMapScreen extends StatefulWidget {
  final GameState gameState;
  final TaskSection section;

  const TaskMapScreen({
    super.key,
    required this.gameState,
    required this.section,
  });

  @override
  State<TaskMapScreen> createState() => _TaskMapScreenState();
}

class _TaskMapScreenState extends State<TaskMapScreen> {
  int? selectedTask;

  List<TaskPoint> get tasks {
    switch (widget.section) {
      case TaskSection.budget:
        return budgetTasks;

      case TaskSection.savings:
        return savingsTasks;

      case TaskSection.purchases:
        return purchaseTasks;
    }
  }

  String get title {
    switch (widget.section) {
      case TaskSection.budget:
        return 'Бюджет';

      case TaskSection.savings:
        return 'Накопления';

      case TaskSection.purchases:
        return 'Покупки и платежи';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Colors.white,

    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
    ),

      body: ListenableBuilder(
        listenable: widget.gameState,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                    children: [
                      // ======================================================
                      // ЗЕЛЁНОЕ ПОЛЕ
                      // ======================================================

                      Positioned.fill(
                        child: Image.asset(
                          'assets/tasts_background.png',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // ======================================================
                      // ПУТЬ
                      // ======================================================

                      Positioned.fill(
                        child: CustomPaint(
                          painter: TaskPathPainter(
                            points: tasks,
                          ),
                        ),
                      ),

                      // ======================================================
                      // ТОЧКИ
                      // ======================================================

                      ...List.generate(
                        tasks.length,
                        (index) {
                          final task = tasks[index];

                          final left =
                              constraints.maxWidth *
                                  task.x -
                              24;

                          final top =
                              constraints.maxHeight *
                                  task.y -
                              24;

                          return Positioned(
                            left: left,
                            top: top,
                            child: _TaskPointButton(
                              number: index + 1,
                              state:
                                  _getTaskState(index),
                              onTap: () {
                                setState(() {
                                  selectedTask = index;
                                });
                              },
                            ),
                          );
                        },
                      ),

                      // ======================================================
                      // ИНФОРМАЦИЯ О ЗАДАНИИ
                      // ======================================================

                      if (selectedTask != null)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: _TaskInfoCard(
                            dinoAsset: widget.gameState.petAsset(state: 'neutral', stage: 1),
                            task:
                                tasks[selectedTask!],
                            taskNumber:
                                selectedTask! + 1,
                            state:
                                _getTaskState(
                              selectedTask!,
                            ),
                            onStart: () {
                              if (_getTaskState(
                                    selectedTask!,
                                  ) ==
                                  TaskPointState.locked) {
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskGameScreen(
                                    gameState:
                                        widget.gameState,
                                    taskNumber:
                                        tasks[
                                          selectedTask!
                                        ].id,
                                    taskTitle:
                                        tasks[
                                          selectedTask!
                                        ].title,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
          );
        },
      ),
    );
  }

  // ==========================================================
  // СОСТОЯНИЕ ЗАДАНИЯ
  // ==========================================================

  TaskPointState _getTaskState(int index) {
    final taskNumber = tasks[index].id;

    if (widget.gameState.isTaskCompleted(
      taskNumber,
    )) {
      return TaskPointState.completed;
    }

    if (widget.gameState.isTaskUnlocked(
      taskNumber,
    )) {
      return TaskPointState.available;
    }

    return TaskPointState.locked;
  }
}


// ============================================================
// СОСТОЯНИЕ ТОЧКИ
// ============================================================

enum TaskPointState {
  locked,
  available,
  completed,
}


// ============================================================
// ТОЧКА НА КАРТЕ
// ============================================================

class _TaskPointButton extends StatelessWidget {
  final int number;
  final TaskPointState state;
  final VoidCallback onTap;

  const _TaskPointButton({
    required this.number,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (state) {
      case TaskPointState.locked:
        color = const Color(0xFFB97872);

      case TaskPointState.available:
        color = const Color(0xFFE94B3C);

      case TaskPointState.completed:
        color = const Color(0xFFE94B3C);
    }

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),

        child: Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,

            border: Border.all(
              color: Colors.white,
              width: 4,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Center(
            child: state ==
                    TaskPointState.completed
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}


// ============================================================
// ИНФОРМАЦИЯ О ЗАДАНИИ
// ============================================================

class _TaskInfoCard extends StatelessWidget {
  final String dinoAsset;
  final TaskPoint task;
  final int taskNumber;
  final TaskPointState state;
  final VoidCallback onStart;

  const _TaskInfoCard({
    required this.dinoAsset,
    required this.task,
    required this.taskNumber,
    required this.state,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final locked =
        state == TaskPointState.locked;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 5,

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                DinoHead(
                  asset: dinoAsset,
                  size: 54,
                  borderRadius: BorderRadius.circular(16),
                ),
                if (locked)
                  const Positioned(
                    right: -3,
                    top: -3,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.lock_rounded, size: 13, color: Colors.black54),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Задание $taskNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  if (locked)
                    const Text(
                      'Сначала выполни предыдущее задание',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),

            if (!locked)
              ElevatedButton(
                onPressed: onStart,
                child: Text(
                  state ==
                          TaskPointState.completed
                      ? 'Повторить'
                      : 'Начать',
                ),
              ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// МОДЕЛЬ ТОЧКИ
// ============================================================

class TaskPoint {
  final int id;
  final double x;
  final double y;
  final String title;

  TaskPoint({
    required this.id,
    required this.x,
    required this.y,
    required this.title,
  });
}


// ============================================================
// БЮДЖЕТ
// ============================================================

final List<TaskPoint> budgetTasks = [
  TaskPoint(
    id: 1,
    x: 0.16,
    y: 0.18,
    title: 'Первый бюджет',
  ),
  TaskPoint(
    id: 2,
    x: 0.39,
    y: 0.30,
    title: 'Куда потратить деньги?',
  ),
  TaskPoint(
    id: 3,
    x: 0.65,
    y: 0.18,
    title: 'Обязательные расходы',
  ),
  TaskPoint(
    id: 4,
    x: 0.82,
    y: 0.43,
    title: 'Хочу или нужно?',
  ),
  TaskPoint(
    id: 5,
    x: 0.57,
    y: 0.65,
    title: 'Планируем остаток',
  ),
  TaskPoint(
    id: 6,
    x: 0.25,
    y: 0.80,
    title: 'Бюджет Финни',
  ),
];


// ============================================================
// НАКОПЛЕНИЯ
// ============================================================

final List<TaskPoint> savingsTasks = [
  TaskPoint(
    id: 7,
    x: 0.17,
    y: 0.20,
    title: 'Выбираем мечту',
  ),
  TaskPoint(
    id: 8,
    x: 0.45,
    y: 0.16,
    title: 'Сколько стоит цель?',
  ),
  TaskPoint(
    id: 9,
    x: 0.75,
    y: 0.28,
    title: 'Первая монетка',
  ),
  TaskPoint(
    id: 10,
    x: 0.68,
    y: 0.55,
    title: 'Копить или потратить?',
  ),
  TaskPoint(
    id: 11,
    x: 0.42,
    y: 0.72,
    title: 'Приближаемся к цели',
  ),
  TaskPoint(
    id: 12,
    x: 0.18,
    y: 0.60,
    title: 'Мечта Финни',
  ),
];


// ============================================================
// ПОКУПКИ
// ============================================================

final List<TaskPoint> purchaseTasks = [
  TaskPoint(
    id: 13,
    x: 0.20,
    y: 0.18,
    title: 'Что действительно нужно?',
  ),
  TaskPoint(
    id: 14,
    x: 0.48,
    y: 0.30,
    title: 'Выбираем товар',
  ),
  TaskPoint(
    id: 15,
    x: 0.75,
    y: 0.18,
    title: 'Сравниваем цены',
  ),
  TaskPoint(
    id: 16,
    x: 0.78,
    y: 0.55,
    title: 'Хватит ли денег?',
  ),
  TaskPoint(
    id: 17,
    x: 0.52,
    y: 0.75,
    title: 'Покупаем с умом',
  ),
  TaskPoint(
    id: 18,
    x: 0.22,
    y: 0.72,
    title: 'Неожиданная покупка',
  ),
];


// ============================================================
// РИСОВАНИЕ ПУНКТИРНОГО ПУТИ
// ============================================================

class TaskPathPainter extends CustomPainter {
  final List<TaskPoint> points;

  TaskPathPainter({
    required this.points,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (points.length < 2) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFE94B3C)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final first = Offset(
      points[0].x * size.width,
      points[0].y * size.height,
    );

    path.moveTo(
      first.dx,
      first.dy,
    );

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final start = Offset(
        previous.x * size.width,
        previous.y * size.height,
      );

      final end = Offset(
        current.x * size.width,
        current.y * size.height,
      );

      final middleX =
          (start.dx + end.dx) / 2;

      final control1 = Offset(
        middleX,
        start.dy,
      );

      final control2 = Offset(
        middleX,
        end.dy,
      );

      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );
    }

    _drawDashedPath(
      canvas,
      path,
      paint,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
  ) {
    const dashLength = 9.0;
    const gapLength = 8.0;

    for (final metric
        in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        double nextDistance =
            distance + dashLength;

        if (nextDistance > metric.length) {
          nextDistance = metric.length;
        }

        canvas.drawPath(
          metric.extractPath(
            distance,
            nextDistance,
          ),
          paint,
        );

        distance +=
            dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant TaskPathPainter oldDelegate,
  ) {
    return oldDelegate.points != points;
  }
}