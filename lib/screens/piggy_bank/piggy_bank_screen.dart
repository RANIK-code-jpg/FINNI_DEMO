import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/game_state.dart';

class PiggyBankScreen extends StatefulWidget {
  final GameState gameState;

  const PiggyBankScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<PiggyBankScreen> createState() =>
      _PiggyBankScreenState();
}

class _PiggyBankScreenState
    extends State<PiggyBankScreen> {
  Timer? _timer;

  GameState get gameState =>
      widget.gameState;

  @override
  void initState() {
    super.initState();

    // Проверяем пассивный доход.
    gameState.processPiggyBankIncome();

    // Обновляем таймер каждую секунду.
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        gameState.processPiggyBankIncome();

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

  // ==========================================================
  // ФОРМАТ ТАЙМЕРА
  // ==========================================================

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // ПОПОЛНЕНИЕ КОПИЛКИ
  // ==========================================================

  Future<void> _showDepositDialog() async {
    final controller =
        TextEditingController();

    final amount =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Пополнить Копилку 🐷',
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'Баланс: ${gameState.balance} 🪙',
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller: controller,

                keyboardType:
                    TextInputType.number,

                autofocus: true,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Сколько положить?',
                  suffixText: '🪙',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Отмена',
              ),
            ),

            FilledButton(
              onPressed: () {
                final value =
                    int.tryParse(
                  controller.text.trim(),
                );

                if (value == null ||
                    value <= 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },

              child: const Text(
                'Положить',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) {
      return;
    }

    final success =
        gameState.addToPiggyBank(
      amount,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'В Копилку добавлено $amount 🪙'
              : 'Недостаточно монет на балансе.',
        ),
      ),
    );

    setState(() {});
  }

  // ==========================================================
  // СНЯТИЕ ИЗ КОПИЛКИ
  // ==========================================================

  Future<void> _showWithdrawDialog() async {
    if (gameState.piggyBank <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Копилка пока пустая.'),
        ),
      );

      return;
    }

    final controller =
        TextEditingController();

    final amount =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Забрать деньги 🐷',
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'В Копилке: '
                '${gameState.piggyBank} 🪙',
              ),

              const SizedBox(
                height: 16,
              ),

              TextField(
                controller: controller,

                keyboardType:
                    TextInputType.number,

                autofocus: true,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Сколько забрать?',
                  suffixText: '🪙',
                  border:
                      OutlineInputBorder(),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Отмена',
              ),
            ),

            FilledButton(
              onPressed: () {
                final value =
                    int.tryParse(
                  controller.text.trim(),
                );

                if (value == null ||
                    value <= 0) {
                  return;
                }

                Navigator.pop(
                  context,
                  value,
                );
              },

              child: const Text(
                'Забрать',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (amount == null) {
      return;
    }

    final success =
        gameState.withdrawFromPiggyBank(
      amount,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'На баланс возвращено $amount 🪙'
              : 'В Копилке недостаточно монет.',
        ),
      ),
    );

    setState(() {});
  }

  // ==========================================================
  // ОСНОВНОЙ ЭКРАН
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F9EE),

      appBar: AppBar(
        title: const Text(
          'Копилка 🐷',
        ),

        centerTitle: true,

        backgroundColor:
            const Color(0xFFF4F9EE),

        elevation: 0,
      ),

      body: ListenableBuilder(
        listenable: gameState,

        builder: (
          context,
          _,
        ) {
          final income =
              gameState.piggyBankIncome;

          final seconds =
              gameState.piggyBankSecondsLeft;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),

            child: Column(
              children: [

                // ==================================================
                // КАРТОЧКА КОПИЛКИ
                // ==================================================

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(24),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(28),

                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 12,

                        offset:
                            Offset(0, 4),

                        color:
                            Colors.black12,
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      // Свинка
                      Container(
                        width: 100,
                        height: 100,

                        decoration:
                            const BoxDecoration(
                          color:
                              Color(0xFFFFE4EC),

                          shape:
                              BoxShape.circle,
                        ),

                        child: const Center(
                          child: Text(
                            '🐷',
                            style:
                                TextStyle(
                              fontSize: 60,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      const Text(
                        'Моя Копилка',
                        style:
                            TextStyle(
                          fontSize: 22,

                          fontWeight:
                              FontWeight.w900,

                          color:
                              Color(0xFF245B91),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        '${gameState.piggyBank} 🪙',
                        style:
                            const TextStyle(
                          fontSize: 38,

                          fontWeight:
                              FontWeight.w900,

                          color:
                              Color(0xFFFF9800),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ==================================================
                      // ПАССИВНЫЙ ДОХОД
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFFF4D6,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),

                        child: Column(
                          children: [

                            const Text(
                              'Пассивный доход',
                              style:
                                  TextStyle(
                                fontSize: 14,

                                fontWeight:
                                    FontWeight.w700,

                                color:
                                    Colors.black54,
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              income > 0
                                  ? '+$income 🪙'
                                  : 'Пополните Копилку',
                              style:
                                  const TextStyle(
                                fontSize: 25,

                                fontWeight:
                                    FontWeight.w900,

                                color:
                                    Color(
                                  0xFFE58A00,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              income > 0
                                  ? 'каждые 5 минут'
                                  : 'для начала начислений',
                              style:
                                  const TextStyle(
                                fontSize: 13,

                                color:
                                    Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ==================================================
                      // ТАЙМЕР
                      // ==================================================

                      if (gameState.piggyBank > 0)
                        Container(
                          width: double.infinity,

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFEAF4FF,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),

                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [

                              const Icon(
                                Icons.timer_outlined,

                                size: 22,

                                color:
                                    Color(
                                  0xFF245B91,
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ),

                              Text(
                                'Следующее начисление: '
                                '${_formatTime(seconds)}',

                                style:
                                    const TextStyle(
                                  fontSize: 14,

                                  fontWeight:
                                      FontWeight.w700,

                                  color:
                                      Color(
                                    0xFF245B91,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================================
                // ИНФОРМАЦИЯ
                // ==================================================

                Container(
                  width: double.infinity,

                  padding:
                      const EdgeInsets.all(16),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        'Как работает Копилка?',
                        style:
                            TextStyle(
                          fontSize: 17,

                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const Text(
                        '🐷 Каждые 5 минут Копилка '
                        'приносит 1% от накопленной суммы.',
                        style:
                            TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Text(
                        '📈 Доход округляется вверх '
                        'до целой монеты.',
                        style:
                            TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      const Text(
                        '💰 Доход остаётся внутри Копилки '
                        'и начинает приносить следующий доход.',
                        style:
                            TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ==================================================
                // БАЛАНС
                // ==================================================

                Text(
                  'На основном балансе: '
                  '${gameState.balance} 🪙',

                  style:
                      const TextStyle(
                    fontSize: 16,

                    fontWeight:
                        FontWeight.w700,

                    color:
                        Color(0xFF245B91),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // КНОПКИ
                // ==================================================

                Row(
                  children: [

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _showDepositDialog,

                        icon:
                            const Icon(
                          Icons
                              .account_balance_wallet,
                        ),

                        label:
                            const Text(
                          'Положить',
                        ),

                        style:
                            ElevatedButton.styleFrom(
                          minimumSize:
                              const Size(
                            0,
                            52,
                          ),

                          backgroundColor:
                              const Color(
                            0xFF7BC67B,
                          ),

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed:
                            gameState.piggyBank >
                                    0
                                ? _showWithdrawDialog
                                : null,

                        icon:
                            const Icon(
                          Icons
                              .payments_outlined,
                        ),

                        label:
                            const Text(
                          'Забрать',
                        ),

                        style:
                            OutlinedButton.styleFrom(
                          minimumSize:
                              const Size(
                            0,
                            52,
                          ),

                          foregroundColor:
                              const Color(
                            0xFF245B91,
                          ),

                          side:
                              const BorderSide(
                            color:
                                Color(
                              0xFF245B91,
                            ),
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}