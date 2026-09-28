import 'dart:math';

import 'package:flutter/material.dart';
import '../../services/game_state.dart';
import '../../widgets/dino_head.dart';

class SettingsScreen extends StatefulWidget {
  final GameState gameState;
  final Future<void> Function(bool enabled) onMusicChanged;
  final VoidCallback onProfileDeleted;

  const SettingsScreen({
    super.key,
    required this.gameState,
    required this.onMusicChanged,
    required this.onProfileDeleted,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  bool soundsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          _SectionTitle(
            icon: Icons.volume_up_rounded,
            title: 'Звук',
          ),

          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.music_note,
                      color: Colors.green,
                    ),
                  ),
                  title: const Text(
                    'Музыка',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Фоновая музыка'),
                  value: musicEnabled,
                  onChanged: (value) async {
                    setState(() {
                      musicEnabled = value;
                    });

                    await widget.onMusicChanged(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.volume_up,
                      color: Colors.blue,
                    ),
                  ),
                  title: const Text(
                    'Звуки действий',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Звуки покупок, наград и действий'),
                  value: soundsEnabled,
                  onChanged: (value) {
                    setState(() {
                      soundsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          _SectionTitle(
            icon: Icons.pets_rounded,
            title: 'Персонаж',
          ),

          _SettingsCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: DinoHead(
                asset: widget.gameState.petAsset(state: 'neutral', stage: 1),
                size: 58,
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Сменить персонажа',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Выбери цвет и внешний вид Финни',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _showCharacterDialog,
            ),
          ),

          const SizedBox(height: 22),

          _SectionTitle(
            icon: Icons.lock_rounded,
            title: 'Для взрослых',
          ),

          _AdultEntryCard(
            gameState: widget.gameState,
            onTap: _openAdultSection,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ВХОД В РАЗДЕЛ ДЛЯ ВЗРОСЛЫХ
  // ============================================================

  void _openAdultSection() {
    _showAdultQuestion();
  }

  void _showAdultQuestion() {
    final random = Random();

    final first = 5 + random.nextInt(16);
    final second = 3 + random.nextInt(12);
    final correctAnswer = first + second;

    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Раздел для взрослых',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Реши пример, чтобы открыть раздел.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '$first + $second = ?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'Ответ',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Отмена'),
            ),

            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Введите ответ перед проверкой.',
                      ),
                    ),
                  );
                  return;
                }

                final answer = int.tryParse(text);

                if (answer == correctAnswer) {
                  Navigator.pop(dialogContext);

                  _showAdultPanel();
                } else {
                  Navigator.pop(dialogContext);

                  Future.delayed(
                    const Duration(milliseconds: 150),
                    () {
                      if (mounted) {
                        _showAdultQuestion();
                      }
                    },
                  );
                }
              },
              child: const Text('Проверить'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // РАЗДЕЛ ДЛЯ ВЗРОСЛЫХ
  // ============================================================

  void _showAdultPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdultProgressScreen(
          gameState: widget.gameState,
          onProfileDeleted: widget.onProfileDeleted,
        ),
      ),
    );
  }

  // ============================================================
  // ВЫБОР ПЕРСОНАЖА
  // ============================================================

  String _characterPreviewAsset(int color, int variant) {
    const colors = ['green', 'blue', 'yellow'];
    const patterns = ['dots', 'spikes', 'stripes'];

    return 'assets/dino/neutral_${patterns[variant]}_${colors[color]}_small.png';
  }

  void _showCharacterDialog() {
    int color = widget.gameState.petColor;
    int variant = widget.gameState.petVariant;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Выбор персонажа',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Цвет',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ColorChoice(
                        asset: _characterPreviewAsset(0, variant),
                        selected: color == 0,
                        onTap: () {
                          setModalState(() {
                            color = 0;
                          });
                        },
                      ),
                      _ColorChoice(
                        asset: _characterPreviewAsset(1, variant),
                        selected: color == 1,
                        onTap: () {
                          setModalState(() {
                            color = 1;
                          });
                        },
                      ),
                      _ColorChoice(
                        asset: _characterPreviewAsset(2, variant),
                        selected: color == 2,
                        onTap: () {
                          setModalState(() {
                            color = 2;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Внешний вид',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _VariantChoice(
                        asset: _characterPreviewAsset(color, 0),
                        selected: variant == 0,
                        onTap: () {
                          setModalState(() {
                            variant = 0;
                          });
                        },
                      ),
                      _VariantChoice(
                        asset: _characterPreviewAsset(color, 1),
                        selected: variant == 1,
                        onTap: () {
                          setModalState(() {
                            variant = 1;
                          });
                        },
                      ),
                      _VariantChoice(
                        asset: _characterPreviewAsset(color, 2),
                        selected: variant == 2,
                        onTap: () {
                          setModalState(() {
                            variant = 2;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.gameState.changePet(
                          petColor: color,
                          petVariant: variant,
                        );

                        Navigator.pop(sheetContext);
                      },
                      child: const Text(
                        'Сохранить персонажа',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ================================================================
// ЭКРАН ДЛЯ ВЗРОСЛЫХ
// ================================================================

class AdultProgressScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onProfileDeleted;

  const AdultProgressScreen({
    super.key,
    required this.gameState,
    required this.onProfileDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final taskProgress =
        (gameState.completedTasksCount / 6).clamp(0.0, 1.0);

    final periodProgress =
        (gameState.period / 5).clamp(0.0, 1.0);

    final goalProgress =
        gameState.goalCost > 0
            ? (gameState.goalProgress / gameState.goalCost)
                .clamp(0.0, 1.0)
            : 0.0;

    final overallProgress =
        ((taskProgress + periodProgress) / 2).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Для взрослых',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AdultProgressCard(
            progress: overallProgress,
            tasks: gameState.completedTasksCount,
            periods: gameState.period,
            petAsset: gameState.petAsset(state: 'neutral', stage: 1),
          ),

          const SizedBox(height: 18),

          const _SectionTitle(
            icon: Icons.school_rounded,
            title: 'Обучение',
          ),

          _TopicCard(
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.blue,
            title: 'Планирование бюджета',
            description:
                'Ребёнок учится распределять деньги между разными категориями.',
            progress: taskProgress,
          ),

          const SizedBox(height: 10),

          _TopicCard(
            icon: Icons.shopping_cart_rounded,
            color: Colors.orange,
            title: 'Покупки и платежи',
            description:
                'Ребёнок учится сравнивать покупки и учитывать стоимость.',
            progress: taskProgress,
          ),

          const SizedBox(height: 10),

          _TopicCard(
            icon: Icons.savings_rounded,
            color: Colors.green,
            title: 'Накопления',
            description:
                'Ребёнок учится откладывать деньги на выбранную цель.',
            progress: goalProgress,
          ),

          const SizedBox(height: 18),

          const _SectionTitle(
            icon: Icons.insights_rounded,
            title: 'Текущее состояние',
          ),

          _InfoGrid(
            children: [
              _InfoTile(
                icon: Icons.calendar_month_rounded,
                title: 'Период',
                value: '${gameState.period} из 5',
                color: Colors.purple,
              ),
              _InfoTile(
                icon: Icons.task_alt_rounded,
                title: 'Задания',
                value: '${gameState.completedTasksCount} из 6',
                color: Colors.blue,
              ),
              _InfoTile(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Баланс',
                value: '${gameState.balance} 🪙',
                color: Colors.orange,
              ),
              _InfoTile(
                icon: Icons.savings_rounded,
                title: 'Накопления',
                value: '${gameState.savings} 🪙',
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _SectionTitle(
            icon: Icons.flag_rounded,
            title: 'Финансовая цель',
          ),

          _GoalCard(
            gameState: gameState,
            progress: goalProgress,
          ),

          const SizedBox(height: 18),

          _SectionTitle(
            icon: Icons.pets_rounded,
            title: gameState.petName.isEmpty ? 'Питомец' : gameState.petName,
          ),

          _PetCard(
            gameState: gameState,
          ),

          const SizedBox(height: 24),

          if (gameState.periodTaskCompleted &&
              gameState.period < 5)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  gameState.finishPeriod();
                },
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                ),
                label: const Text(
                  'Начать следующий период',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          const _SectionTitle(
            icon: Icons.manage_accounts_rounded,
            title: 'Управление профилем',
          ),

          _DangerCard(
            icon: Icons.restart_alt_rounded,
            title: 'Сбросить прогресс',
            description:
                'Начать игру заново с чистым прогрессом.',
            onTap: () {
              _confirmReset(context);
            },
          ),

          const SizedBox(height: 10),

          _DangerCard(
            icon: Icons.delete_outline_rounded,
            title: 'Удалить локальный профиль',
            description:
                'Удалить сохранённый игровой прогресс с устройства.',
            onTap: () {
              _showDeleteInfo(context);
            },
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ПОДТВЕРЖДЕНИЕ СБРОСА
  // ==============================================================

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Сбросить прогресс?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Все текущие достижения, накопления и прогресс '
            'будут сброшены. Это действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await gameState.resetProgress();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Сбросить'),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // УДАЛЕНИЕ ПРОФИЛЯ
  // ==============================================================

  void _showDeleteInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Удалить локальный профиль?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Будут удалены имя Финни, его внешний вид, '
            'монеты, покупки, накопления, задания и весь игровой прогресс.\n\n'
            'После удаления откроется экран создания нового питомца.\n\n'
            'Действие нельзя отменить.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await gameState.deleteLocalProfile();

                if (!context.mounted) {
                  return;
                }

                // ВАЖНО:
                // AdultProgressScreen является StatelessWidget,
                // поэтому здесь нельзя писать widget.onProfileDeleted().
                onProfileDeleted();
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// КАРТОЧКА ОБЩЕГО ПРОГРЕССА
// ================================================================

class _AdultProgressCard extends StatelessWidget {
  final double progress;
  final int tasks;
  final int periods;
  final String petAsset;

  const _AdultProgressCard({
    required this.progress,
    required this.tasks,
    required this.periods,
    required this.petAsset,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade500,
            Colors.indigo.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DinoHead(
                asset: petAsset,
                size: 48,
                borderRadius: BorderRadius.circular(14),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Общий прогресс',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 7),
                child: Text(
                  'образовательного пути',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _ProgressSmallInfo(
                  icon: Icons.task_alt,
                  text: '$tasks / 6 заданий',
                ),
              ),
              Expanded(
                child: _ProgressSmallInfo(
                  icon: Icons.calendar_month,
                  text: '$periods / 5 периодов',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ТЕМА ОБУЧЕНИЯ
// ================================================================

class _TopicCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final double progress;

  const _TopicCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 9),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: color.withOpacity(0.10),
                    valueColor:
                        AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            '$percent%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ЦЕЛЬ
// ================================================================

class _GoalCard extends StatelessWidget {
  final GameState gameState;
  final double progress;

  const _GoalCard({
    required this.gameState,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: Colors.purple.shade400,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameState.goal,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${gameState.goalProgress} / ${gameState.goalCost} 🪙',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ФИННИ
// ================================================================

class _PetCard extends StatelessWidget {
  final GameState gameState;

  const _PetCard({
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          DinoHead(
            asset: gameState.petAsset(state: 'neutral', stage: 1),
            size: 72,
            borderRadius: BorderRadius.circular(20),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  gameState.petName.isEmpty
                      ? 'Финни'
                      : gameState.petName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gameState.petStage,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Уровень ${gameState.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
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

// ================================================================
// ИНФОРМАЦИОННАЯ СЕТКА
// ================================================================

class _InfoGrid extends StatelessWidget {
  final List<Widget> children;

  const _InfoGrid({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: children,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ОПАСНОЕ ДЕЙСТВИЕ
// ================================================================

class _DangerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DangerCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ВХОД ВО ВЗРОСЛЫЙ РАЗДЕЛ
// ================================================================

class _AdultEntryCard extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onTap;

  const _AdultEntryCard({
    required this.gameState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade500,
              Colors.purple.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.18),
              blurRadius: 15,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: DinoHead(
                asset: gameState.petAsset(state: 'neutral', stage: 1),
                size: 52,
                borderRadius: BorderRadius.circular(26),
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Раздел для взрослых',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Прогресс, обучение и управление профилем',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ЗАГОЛОВОК СЕКЦИИ
// ================================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 21,
            color: Colors.indigo.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// КАРТОЧКА НАСТРОЕК
// ================================================================

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================================================================
// МАЛЕНЬКАЯ ИНФОРМАЦИЯ В ПРОГРЕССЕ
// ================================================================

class _ProgressSmallInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProgressSmallInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// ВЫБОР ЦВЕТА
// ================================================================

class _ColorChoice extends StatelessWidget {
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7E5),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? const Color(0xFF1E78C4) : Colors.transparent,
            width: 3,
          ),
        ),
        child: DinoHead(
          asset: asset,
          size: 56,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

// ================================================================
// ВЫБОР ВАРИАНТА
// ================================================================

class _VariantChoice extends StatelessWidget {
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  const _VariantChoice({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.shade50
              : Colors.grey.shade50,
          border: Border.all(
            color: selected
                ? Colors.blue
                : Colors.grey.shade300,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: DinoHead(
            asset: asset,
            size: 70,
          ),
        ),
      ),
    );
  }
}