import 'package:flutter/material.dart';

import '../../services/game_state.dart';

class BudgetScreen extends StatefulWidget {
  final GameState gameState;

  const BudgetScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late int mandatory;
  late int optional;
  late int goalSavings;
  late int savings;

  @override
  void initState() {
    super.initState();

    mandatory = widget.gameState.mandatoryBudget;
    optional = widget.gameState.optionalBudget;
    goalSavings = widget.gameState.goalBudget;
    savings = widget.gameState.savingsBudget;

    // Следим за изменениями GameState.
    //
    // Например:
    // покупка еды -> mandatoryRemaining уменьшился
    // покупка игрушки -> optionalRemaining уменьшился
    // пополнение копилки -> savingsRemaining уменьшился
    widget.gameState.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameState.removeListener(_onGameStateChanged);

    super.dispose();
  }

  // ============================================================
  // ОБНОВЛЕНИЕ ЭКРАНА
  // ============================================================

  void _onGameStateChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // ОБЩЕЕ КОЛИЧЕСТВО РАСПРЕДЕЛЁННЫХ ДЕНЕГ
  // ============================================================

  int get total {
    return mandatory +
        optional +
        goalSavings +
        savings;
  }

  // ============================================================
  // СКОЛЬКО ОСТАЛОСЬ ПРИ СОЗДАНИИ БЮДЖЕТА
  // ============================================================

  int get remaining {
    return widget.gameState.balance - total;
  }

  // ============================================================
  // ИЗМЕНЕНИЕ ОБЯЗАТЕЛЬНЫХ РАСХОДОВ
  // ============================================================

  void changeMandatory(int newValue) {
    // Если уменьшаем значение,
    // разрешаем всегда.
    if (newValue <= mandatory) {
      setState(() {
        mandatory = newValue;
      });

      return;
    }

    // Сколько денег хотим добавить.
    final difference =
        newValue - mandatory;

    // Если свободных денег хватает,
    // разрешаем увеличение.
    if (difference <= remaining) {
      setState(() {
        mandatory = newValue;
      });
    }
  }

  // ============================================================
  // ИЗМЕНЕНИЕ ЖЕЛАНИЙ
  // ============================================================

  void changeOptional(int newValue) {
    // Уменьшать можно всегда.
    if (newValue <= optional) {
      setState(() {
        optional = newValue;
      });

      return;
    }

    // Сколько денег хотим добавить.
    final difference =
        newValue - optional;

    // Проверяем свободный бюджет.
    if (difference <= remaining) {
      setState(() {
        optional = newValue;
      });
    }
  }

  // ============================================================
  // ИЗМЕНЕНИЕ СУММЫ НА ФИНАНСОВУЮ ЦЕЛЬ
  // ============================================================

  void changeGoalSavings(int newValue) {
    if (newValue <= goalSavings) {
      setState(() {
        goalSavings = newValue;
      });
      return;
    }

    final difference = newValue - goalSavings;
    if (difference <= remaining) {
      setState(() {
        goalSavings = newValue;
      });
    }
  }

  // ============================================================
  // ИЗМЕНЕНИЕ КОПИЛКИ
  // ============================================================

  void changeSavings(int newValue) {
    // Уменьшать можно всегда.
    if (newValue <= savings) {
      setState(() {
        savings = newValue;
      });

      return;
    }

    // Сколько денег хотим добавить.
    final difference =
        newValue - savings;

    // Проверяем свободный бюджет.
    if (difference <= remaining) {
      setState(() {
        savings = newValue;
      });
    }
  }

  // ============================================================
  // СОХРАНЕНИЕ БЮДЖЕТА
  // ============================================================

  void _editConfirmedBudget() {
    // В локальных полях уже лежит текущий подтверждённый бюджет.
    // После изменения пользователь сможет снова сохранить его.
    setState(() {
      // Только разблокируем редактирование. Значения категорий
      // остаются прежними, поэтому уже потраченные деньги не теряются.
    });

    widget.gameState.budgetConfirmed = false;
    widget.gameState.notifyListeners();
  }

  void saveBudget() {
    final ok =
        widget.gameState.saveBudget(
      mandatory: mandatory,
      optional: optional,
      savingsAmount: savings,
      goalSavingsAmount: goalSavings,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Бюджет сохранён! Теперь можно играть с ним.'
              : 'План не помещается в доступные деньги.',
        ),
      ),
    );

    if (ok) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameState;

    final balance = gameState.balance;

    // ============================================================
    // ТЕКУЩИЕ ЗНАЧЕНИЯ ШКАЛ
    // ============================================================
    //
    // Пока бюджет НЕ подтверждён:
    // показываем то, что пользователь распределяет.
    //
    // После подтверждения:
    // показываем то, что реально осталось после покупок.

    final mandatoryValue =
        gameState.budgetConfirmed
            ? gameState.mandatoryRemaining
            : mandatory;

    final optionalValue =
        gameState.budgetConfirmed
            ? gameState.optionalRemaining
            : optional;

    final goalSavingsValue =
        gameState.budgetConfirmed
            ? gameState.goalBudgetRemaining
            : goalSavings;

    final savingsValue =
        gameState.budgetConfirmed
            ? gameState.savingsRemaining
            : savings;

    // ============================================================
    // ТЕКУЩИЙ ОБЩИЙ ОСТАТОК
    // ============================================================

    final currentBudgetRemaining =
        gameState.budgetConfirmed
            ? gameState.budgetRemaining
            : remaining;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Бюджет периода',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ========================================================
          // ИНФОРМАЦИЯ О БЮДЖЕТЕ
          // ========================================================

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    'Бюджет Финни',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    gameState.budgetConfirmed
                        ? 'Бюджет уже подтверждён. '
                          'Покупки, пополнение цели и Копилка '
                          'уменьшают доступные суммы.'
                        : 'У Финни $balance 🪙. '
                          'Распредели деньги между '
                          'обязательными расходами, целью, '
                          'желаниями и Копилкой.',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Баланс:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        '$balance 🪙',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Остаток бюджета:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        '$currentBudgetRemaining 🪙',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,

                          color:
                              currentBudgetRemaining >
                                      0
                                  ? Colors.green
                                  : currentBudgetRemaining ==
                                          0
                                      ? Colors.orange
                                      : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ========================================================
          // ОБЯЗАТЕЛЬНОЕ
          // ========================================================

          _MoneySlider(
            title: 'Обязательное',
            icon: '🏠',

            // После подтверждения показываем
            // оставшуюся сумму.
            value: mandatoryValue,

            // Максимум всегда остаётся
            // первоначальным бюджетом.
            max: gameState.budgetConfirmed
                ? gameState.mandatoryBudget
                : balance,

            spent: gameState.budgetConfirmed
                ? gameState.mandatorySpent
                : 0,

            enabled:
                !gameState.budgetConfirmed,

            onChanged:
                changeMandatory,
          ),

          // ========================================================
          // ЖЕЛАНИЯ
          // ========================================================

          _MoneySlider(
            title: 'Желания',
            icon: '🎮',

            value: optionalValue,

            max: gameState.budgetConfirmed
                ? gameState.optionalBudget
                : balance,

            spent: gameState.budgetConfirmed
                ? gameState.optionalSpent
                : 0,

            enabled:
                !gameState.budgetConfirmed,

            onChanged:
                changeOptional,
          ),

          // ========================================================
          // ФИНАНСОВАЯ ЦЕЛЬ
          // ========================================================

          _MoneySlider(
            title: 'Накопления на цель «${gameState.goal}»',
            icon: '🎯',

            value: goalSavingsValue,

            max: gameState.budgetConfirmed
                ? gameState.goalBudget
                : balance,

            spent: gameState.budgetConfirmed
                ? gameState.goalBudgetSpent
                : 0,

            enabled:
                !gameState.budgetConfirmed,

            onChanged:
                changeGoalSavings,
          ),

          // ========================================================
          // КОПИЛКА
          // ========================================================

          _MoneySlider(
            title: 'Копилка',
            icon: '🐷',

            value: savingsValue,

            max: gameState.budgetConfirmed
                ? gameState.savingsBudget
                : balance,

            spent: gameState.budgetConfirmed
                ? gameState.savingsSpent
                : 0,

            enabled:
                !gameState.budgetConfirmed,

            onChanged:
                changeSavings,
          ),

          const SizedBox(
            height: 12,
          ),

          // ========================================================
          // ИТОГ
          // ========================================================

          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  if (!gameState.budgetConfirmed) ...[
                    Text(
                      'Распределено: $total 🪙',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Свободно: $remaining 🪙',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,

                        color: remaining >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    if (remaining > 0)
                      const Text(
                        'Свободные деньги можно оставить '
                        'нераспределёнными.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      )
                    else if (remaining == 0)
                      const Text(
                        'Весь бюджет распределён.',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                  ] else ...[
                    Text(
                      'Осталось бюджета: '
                      '$currentBudgetRemaining 🪙',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      'Потрачено и переведено: '
                      '${gameState.mandatorySpent +
                          gameState.optionalSpent +
                          gameState.savingsSpent} 🪙',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Покупки и пополнение Копилки '
                      'уменьшают доступную сумму.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ========================================================
          // ПОДТВЕРДИТЬ
          // ========================================================

          if (!gameState.budgetConfirmed)
            SizedBox(
              height: 52,

              child: ElevatedButton(
                onPressed:
                    remaining >= 0
                        ? saveBudget
                        : null,

                child: const Text(
                  'Подтвердить бюджет',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),

          // ========================================================
          // ПОСЛЕ ПОДТВЕРЖДЕНИЯ
          // ========================================================

          if (gameState.budgetConfirmed) ...[
            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editConfirmedBudget,
                icon: const Icon(Icons.edit_rounded),
                label: const Text(
                  'Изменить бюджет',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Card(
              color: Colors.green
                  .withValues(
                alpha: 0.12,
              ),

              child: const Padding(
                padding:
                    EdgeInsets.all(14),

                child: Text(
                  '✅ Бюджет подтверждён.\n\n'
                  'Теперь покупки, пополнение цели и Копилка '
                  'уменьшают соответствующие шкалы.',
                  textAlign:
                      TextAlign.center,

                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ======================================================================
// ПОЛЗУНОК ДЕНЕГ
// ======================================================================

class _MoneySlider
    extends StatelessWidget {
  final String title;
  final String icon;

  // Текущее значение.
  final int value;

  // Максимальное значение.
  final int max;

  // Сколько уже потрачено.
  final int spent;

  // Можно ли двигать ползунок.
  final bool enabled;

  final ValueChanged<int>
      onChanged;

  const _MoneySlider({
    required this.title,
    required this.icon,
    required this.value,
    required this.max,
    required this.spent,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final safeMax =
        max < 1 ? 1 : max;

    final safeValue =
        value.clamp(
      0,
      safeMax,
    );

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ========================================================
            // ЗАГОЛОВОК
            // ========================================================

            Row(
              children: [
                Text(
                  icon,
                  style:
                      const TextStyle(
                    fontSize: 24,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child: Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  '$value / $max 🪙',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 4,
            ),

            // ========================================================
            // ИНФОРМАЦИЯ
            // ========================================================

            if (enabled)
              Text(
                'Выделено: $max 🪙',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey.shade600,
                ),
              )
            else
              Text(
                'Потрачено: $spent 🪙',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      Colors.grey.shade600,
                ),
              ),

            const SizedBox(
              height: 4,
            ),

            // ========================================================
            // ПОЛЗУНОК
            // ========================================================

            Slider(
              value:
                  safeValue.toDouble(),

              min: 0,

              max:
                  safeMax.toDouble(),

              divisions:
                  safeMax,

              // После подтверждения
              // ползунок блокируется.
              onChanged: enabled
                  ? (newValue) {
                      onChanged(
                        newValue.round(),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}