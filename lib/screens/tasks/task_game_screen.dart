import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../services/game_state.dart';
import '../../widgets/dino_head.dart';
import '../../services/sound_service.dart';
import '../../services/sound_service.dart';
class TaskGameScreen extends StatefulWidget {
  final GameState gameState;
  final int taskNumber;
  final String taskTitle;

  const TaskGameScreen({
    super.key,
    required this.gameState,
    required this.taskNumber,
    required this.taskTitle,
  });

  @override
  State<TaskGameScreen> createState() => _TaskGameScreenState();
}

class _TaskGameScreenState extends State<TaskGameScreen> {
  int currentStage = 0;
  int selectedAnswer = -1;

  bool showFeedback = false;
  bool feedbackCorrect = false;
  bool finished = false;

  String feedbackText = '';

  Timer? feedbackTimer;

  late final TaskScenario scenario;

  @override
  void initState() {
    super.initState();

    final baseScenario = TaskScenario.forTask(
      widget.taskNumber,
    );

    final random = Random();

    scenario = TaskScenario(
      finalMessage: baseScenario.finalMessage,
      stages: baseScenario.stages.map((stage) {
        final answers = List<TaskAnswer>.from(
          stage.answers,
        );

        answers.shuffle(random);

        return TaskStage(
          title: stage.title,
          story: stage.story,
          question: stage.question,
          answers: answers,
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return _buildResultScreen();
    }

    final stage = scenario.stages[currentStage];

    return Scaffold(
      backgroundColor: const Color(0xFFEAF7E5),
      appBar: AppBar(
        title: Text(
          'Задание ${widget.taskNumber}',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildFinniHeader(),

                const SizedBox(height: 4),

                _buildProgress(),

                const SizedBox(height: 8),

                Text(
                  'Шаг ${currentStage + 1} '
                  'из ${scenario.stages.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      30,
                    ),
                    children: [
                      Text(
                        widget.taskTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildStoryCard(stage),

                      const SizedBox(height: 18),

                      Text(
                        stage.question,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...stage.answers.asMap().entries.map(
                        (entry) {
                          return _buildAnswerButton(
                            index: entry.key,
                            answer: entry.value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (showFeedback)
            _buildFeedbackPopup(),
        ],
      ),
    );
  }

  // ==========================================================
  // ФИННИ
  // ==========================================================

  Widget _buildFinniHeader() {
    final petName = widget.gameState.petName.isEmpty
        ? 'Питомец'
        : widget.gameState.petName;

    String message = '$petName ждёт твоего решения!';

    if (showFeedback) {
      if (feedbackCorrect) {
        message =
            'Посмотрим, почему это решение подходит.';
      } else {
        message =
            'Давай разберём, что можно улучшить.';
      }
    } else if (currentStage > 0) {
      message = 'Отлично! Переходим дальше.';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        8,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          DinoHead(
            asset: widget.gameState.petAsset(
              state: 'neutral',
              stage: 1,
            ),
            size: 64,
            borderRadius: BorderRadius.circular(18),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ПРОГРЕСС
  // ==========================================================

  Widget _buildProgress() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: List.generate(
          scenario.stages.length,
          (index) {
            final active =
                index <= currentStage;

            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(
                  right:
                      index ==
                              scenario.stages.length -
                                  1
                          ? 0
                          : 6,
                ),
                decoration:
                    BoxDecoration(
                  color: active
                      ? const Color(
                          0xFF4CAF50,
                        )
                      : Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // СЮЖЕТ
  // ==========================================================

  Widget _buildStoryCard(
    TaskStage stage,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          18,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              stage.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              stage.story,
              style: const TextStyle(
                fontSize: 17,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ВАРИАНТ ОТВЕТА
  // ==========================================================

  Widget _buildAnswerButton({
    required int index,
    required TaskAnswer answer,
  }) {
    final selected =
        selectedAnswer == index;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Material(
        color: selected
            ? const Color(0xFFE8F5E9)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(18),
          onTap: showFeedback
              ? null
              : () => _answer(
                    index,
                  ),
          child: Padding(
            padding:
                const EdgeInsets.all(
              15,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFEAF7E5,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(
                        65 + index,
                      ),
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    answer.text,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color:
                      Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ОТВЕТ
  // ==========================================================

  void _answer(int index) {
  if (showFeedback) {
    return;
  }

  final stage = scenario.stages[currentStage];
  final answer = stage.answers[index];

  feedbackTimer?.cancel();

  setState(() {
    selectedAnswer = index;
    showFeedback = true;
    feedbackCorrect = answer.correct;

    feedbackText = answer.correct
        ? _getCorrectExplanation()
        : answer.explanation;
  });

  // Звук при каждом правильном ответе.
  if (answer.correct) {
    SoundService.playSuccess();
  }

  feedbackTimer = Timer(
    const Duration(seconds: 7),
    () {
      if (!mounted) {
        return;
      }

      _closeFeedback();
    },
  );
}

  // ==========================================================
  // ЗАКРЫТИЕ ПОЯСНЕНИЯ
  // ==========================================================

  void _closeFeedback() {
    feedbackTimer?.cancel();

    final wasCorrect =
        feedbackCorrect;

    setState(() {
      showFeedback = false;
    });

    if (!wasCorrect) {
      setState(() {
        selectedAnswer = -1;
      });

      return;
    }

    if (currentStage <
        scenario.stages.length - 1) {
      setState(() {
        currentStage++;
        selectedAnswer = -1;
      });

      return;
    }

    _finishTask();
  }

  // ==========================================================
  // ВСПЛЫВАЮЩЕЕ ПОЯСНЕНИЕ
  // ==========================================================

  Widget _buildFeedbackPopup() {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Material(
        elevation: 12,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            14,
            8,
            14,
          ),
          decoration: BoxDecoration(
            color: feedbackCorrect
                ? const Color(
                    0xFFE8F7E8,
                  )
                : const Color(
                    0xFFFFF0E8,
                  ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: feedbackCorrect
                  ? Colors.green.shade300
                  : Colors.orange.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: feedbackCorrect
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  shape:
                      BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    feedbackCorrect
                        ? '✓'
                        : '!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w900,
                      color: feedbackCorrect
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedbackCorrect
                          ? 'Правильное решение!'
                          : 'Разберём ошибку',
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      feedbackText,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Сообщение закроется через 7 секунд',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        color:
                            Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed:
                    _closeFeedback,
                icon:
                    const Icon(
                  Icons.close,
                ),
                tooltip: 'Закрыть',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ОБЪЯСНЕНИЕ ПРАВИЛЬНОГО ОТВЕТА
  // ==========================================================

  String _getCorrectExplanation() {
    switch (widget.taskNumber) {
      case 1:
        if (currentStage == 0) {
          return 'Сначала нужно распределить деньги. '
              'Так Финни заранее понимает, сколько можно потратить, '
              'сколько сохранить и сколько оставить на обязательные расходы.';
        }

        if (currentStage == 1) {
          return 'Обязательные расходы имеют приоритет. '
              'Если не заложить на них деньги заранее, '
              'позже их может не хватить.';
        }

        return 'Копилка помогает Финни двигаться к финансовой цели, '
            'не тратя все деньги сразу.';

      case 2:
        if (currentStage == 0) {
          return 'Свободные деньги тоже нужно учитывать. '
              'Они ограничены текущим балансом Финни.';
        }

        if (currentStage == 1) {
          return '150 🪙 больше 100 🪙, '
              'поэтому такой покупки Финни сейчас позволить себе не может.';
        }

        return 'Отказавшись от другой необязательной покупки, '
            'Финни может сохранить деньги для более важной цели.';

      case 3:
        if (currentStage == 0) {
          return 'Бюджет превращает все деньги Финни '
              'в понятный план: обязательные расходы, желания и накопления.';
        }

        if (currentStage == 1) {
          return 'Три категории помогают разделить разные финансовые задачи '
              'и не потратить деньги одного назначения на другое.';
        }

        return 'Общая сумма плана не должна превышать доступный баланс.';

      case 4:
        if (currentStage == 0) {
          return 'Еда относится к обязательным расходам, '
              'поэтому её стоит учесть раньше необязательной игрушки.';
        }

        if (currentStage == 1) {
          return 'Желание можно купить, если на него действительно '
              'есть место в бюджете.';
        }

        return 'Запас денег позволяет Финни принимать следующие решения '
            'и не оставаться без средств.';

      case 5:
        if (currentStage == 0) {
          return 'Перед покупкой нужно знать свой лимит. '
              'Иначе легко выбрать вещь, на которую денег не хватит.';
        }

        if (currentStage == 1) {
          return '80 🪙 помещается в лимит 100 🪙, '
              'а 180 🪙 уже превышает его.';
        }

        return 'Покупка должна соответствовать доступному бюджету, '
            'а не просто нравиться Финни.';

      case 6:
        if (currentStage == 0) {
          return 'Если сумма категорий больше баланса, '
              'такой бюджет невозможно выполнить.';
        }

        if (currentStage == 1) {
          return '500 − 400 = 100 🪙. '
              'Именно столько остаётся свободными.';
        }

        return 'Проверка перед подтверждением помогает заметить ошибку '
            'до того, как она повлияет на покупки.';

      case 7:
        if (currentStage == 0) {
          return 'Конкретная цель показывает, '
              'ради чего Финни откладывает деньги.';
        }

        if (currentStage == 1) {
          return 'Стоимость цели показывает, '
              'сколько монет нужно собрать.';
        }

        return 'Регулярные пополнения постепенно приближают Финни к цели.';

      case 8:
        if (currentStage == 0) {
          return '400 🪙 является полной стоимостью выбранной цели.';
        }

        if (currentStage == 1) {
          return '400 − 100 = 300 🪙. '
              'Именно столько ещё осталось накопить.';
        }

        return 'Регулярные небольшие взносы помогают постепенно достигать '
            'большой цели.';

      case 9:
        if (currentStage == 0) {
          return 'Даже небольшая сумма может стать первым шагом '
              'к большой цели.';
        }

        if (currentStage == 1) {
          return 'Каждое пополнение увеличивает накопленную сумму '
              'и приближает Финни к цели.';
        }

        return 'Регулярность превращает маленькие взносы '
            'в заметный накопленный результат.';

      case 10:
        if (currentStage == 0) {
          return 'Если цель сейчас важнее небольшой покупки, '
              'свободные деньги разумно направить в накопления.';
        }

        if (currentStage == 1) {
          return 'Иногда ради большой цели приходится отказаться '
              'от небольшой покупки сейчас.';
        }

        return 'Финансовая цель тренирует умение выбирать '
            'между желанием сейчас и результатом в будущем.';

      case 11:
        if (currentStage == 0) {
          return 'Из 500 🪙 уже собрано 200 🪙.';
        }

        if (currentStage == 1) {
          return 'Регулярные накопления постепенно уменьшают '
              'расстояние до цели.';
        }

        return 'Последовательность важнее одного большого взноса.';

      case 12:
        if (currentStage == 0) {
          return 'Прогресс показывает, сколько уже накоплено '
              'и сколько ещё требуется.';
        }

        if (currentStage == 1) {
          return 'Свободные деньги можно направить на цель, '
              'если она остаётся приоритетом.';
        }

        return 'Чем больше накоплено, '
            'тем ближе Финни к своей цели.';

      case 13:
        if (currentStage == 0) {
          return 'Перед покупкой полезно спросить себя, '
              'действительно ли эта вещь нужна.';
        }

        if (currentStage == 1) {
          return 'Цена и доступный лимит показывают, '
              'может ли Финни позволить себе покупку.';
        }

        return 'Разумная покупка одновременно нужна Финни '
            'и укладывается в его финансовый план.';

      case 14:
        if (currentStage == 0) {
          return 'Цена и необходимость помогают сравнивать товары '
              'не только по внешнему виду.';
        }

        if (currentStage == 1) {
          return '100 🪙 помещается в бюджет 120 🪙, '
              'а 160 🪙 превышает его.';
        }

        return 'Выбор товара за 100 🪙 позволяет сохранить '
            'часть денег для других целей.';

      case 15:
        if (currentStage == 0) {
          return 'Если товары одинаковы по назначению, '
              'цена становится важным фактором выбора.';
        }

        if (currentStage == 1) {
          return 'Чем меньше стоит подходящий товар, '
              'тем больше денег остаётся после покупки.';
        }

        return 'Экономия на одинаковом товаре помогает сохранить '
            'больше средств в бюджете.';

      case 16:
        if (currentStage == 0) {
          return 'Если Финни голоден, ему нужна именно еда.';
        }

        if (currentStage == 1) {
          return 'Покупка должна одновременно соответствовать цене '
              'и лимиту обязательных расходов.';
        }

        return 'После покупки еды Финни получает возможность '
            'восстановить сытость.';

      case 17:
        if (currentStage == 0) {
          return 'Желание можно удовлетворить, '
              'если покупка помещается в выделенный бюджет.';
        }

        if (currentStage == 1) {
          return 'Даже для желаемой покупки нужно проверить, '
              'что после неё бюджет остаётся управляемым.';
        }

        return 'Игрушка может повысить веселье Финни, '
            'но за это приходится заплатить монетами.';

      case 18:
        if (currentStage == 0) {
          return 'Проверка бюджета помогает понять, '
              'можно ли позволить себе новую покупку.';
        }

        if (currentStage == 1) {
          return 'Если денег недостаточно, безопаснее отложить покупку, '
              'чем нарушать бюджет.';
        }

        return 'Иногда лучше отказаться от покупки сейчас, '
            'чтобы сохранить деньги для более важных целей.';

      default:
        return 'Это решение соответствует финансовому плану Финни '
            'и помогает контролировать его деньги.';
    }
  }

  // ==========================================================
  // ЗАВЕРШЕНИЕ ЗАДАНИЯ
  // ==========================================================

  void _finishTask() {
    if (finished) {
      return;
    }

    _applyScenarioEffect();

    final reward = widget.gameState.taskReward(
      widget.taskNumber,
    );

    widget.gameState.completeTask(
      taskNumber: widget.taskNumber,
      result:
          'Задание полностью пройдено. '
          'Получено $reward 🪙.',
    );

    // Звук полного прохождения задания.
    if (widget.gameState.isTaskCompleted(
      widget.taskNumber,
    )) {
      SoundService.playSuccess();
    }

    setState(() {
      finished = true;
    });
  }

  // ==========================================================
  // ПОСЛЕДСТВИЯ ЗАДАНИЯ
  // ==========================================================

  void _applyScenarioEffect() {
    switch (widget.taskNumber) {
      // ------------------------------------------------------
      // БЮДЖЕТ
      // ------------------------------------------------------

      case 1:
        widget.gameState.saveBudget(
          mandatory: 150,
          optional: 100,
          savingsAmount: 0,
          goalSavingsAmount: 100,
        );
        break;

      case 2:
        widget.gameState.saveBudget(
          mandatory: 200,
          optional: 100,
          savingsAmount: 0,
          goalSavingsAmount: 100,
        );
        break;

      case 3:
        widget.gameState.saveBudget(
          mandatory: 250,
          optional: 80,
          savingsAmount: 0,
          goalSavingsAmount: 100,
        );
        break;

      case 4:
        widget.gameState.saveBudget(
          mandatory: 180,
          optional: 120,
          savingsAmount: 0,
          goalSavingsAmount: 100,
        );
        break;

      case 5:
        widget.gameState.saveBudget(
          mandatory: 200,
          optional: 100,
          savingsAmount: 0,
          goalSavingsAmount: 150,
        );
        break;

      case 6:
        widget.gameState.saveBudget(
          mandatory: 220,
          optional: 80,
          savingsAmount: 0,
          goalSavingsAmount: 150,
        );
        break;

      // ------------------------------------------------------
      // НАКОПЛЕНИЯ
      // ------------------------------------------------------

      case 7:
        widget.gameState.setGoal(
          name: 'Домик Финни',
          cost: 500,
        );
        break;

      case 8:
        widget.gameState.setGoal(
          name: 'Горка для Финни',
          cost: 400,
        );
        break;

      case 9:
        widget.gameState.addToSavings(
          50,
        );
        break;

      case 10:
        widget.gameState.addToSavings(
          50,
        );
        break;

      case 11:
        widget.gameState.addToSavings(
          100,
        );
        break;

      case 12:
        widget.gameState.addToSavings(
          100,
        );
        break;

      // ------------------------------------------------------
      // ПОКУПКИ
      // ------------------------------------------------------

      case 13:
        widget.gameState.buyMandatory(
          price: 80,
        );
        break;

      case 14:
        widget.gameState.buyMandatory(
          price: 100,
        );
        break;

      case 15:
        widget.gameState.buyOptional(
          price: 100,
          funGain: 10,
        );
        break;

      case 16:
        widget.gameState.buyFood(
          50,
        );
        break;

      case 17:
        widget.gameState.buyOptional(
          price: 100,
          funGain: 20,
        );
        break;

      case 18:
        // В этом задании правильное решение
        // заключается в отказе от необязательной покупки.
        break;
    }
  }

  // ==========================================================
  // РЕЗУЛЬТАТ
  // ==========================================================

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor:
          const Color(0xFFEAF7E5),
      appBar: AppBar(
        title: const Text(
          'Задание завершено',
        ),
        backgroundColor:
            Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),

            const Text(
              '🎉',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 72),
            ),

            const SizedBox(height: 10),

            const Text(
              'Отличная работа!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.taskTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Финни доволен! 🦕',
                      style:
                          TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      scenario.finalMessage,
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _ResultRow(
              icon: '🪙',
              title: 'Баланс',
              value:
                  '${widget.gameState.balance}',
            ),

            _ResultRow(
              icon: '🐷',
              title: 'Копилка',
              value:
                  '${widget.gameState.savings}',
            ),

            _ResultRow(
              icon: '🍎',
              title: 'Еда',
              value:
                  '${widget.gameState.food}',
            ),

            _ResultRow(
              icon: '😊',
              title: 'Веселье',
              value:
                  '${widget.gameState.fun}',
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child:
                  ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: const Text(
                  'Вернуться к заданиям',
                  style:
                      TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// РЕЗУЛЬТАТ
// ============================================================

class _ResultRow
    extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const _ResultRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: Text(
          icon,
          style:
              const TextStyle(
            fontSize: 28,
          ),
        ),
        title: Text(
          title,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        trailing: Text(
          value,
          style:
              const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
    );
  }
}


// ============================================================
// СЦЕНАРИЙ
// ============================================================

class TaskScenario {
  final List<TaskStage> stages;
  final String finalMessage;

  const TaskScenario({
    required this.stages,
    required this.finalMessage,
  });

  static TaskScenario forTask(
    int taskNumber,
  ) {
    switch (taskNumber) {
      // ======================================================
      // 1. БЮДЖЕТ
      // ======================================================

      case 1:
        return TaskScenario(
          finalMessage:
              'Ты распределил деньги так, чтобы у Финни '
              'были обязательные расходы, желания и копилка.',
          stages: [
            TaskStage(
              title: 'Начинаем планировать',
              story:
                  'У Финни есть 500 🪙. '
                  'Он хочет купить нужные вещи, немного развлечься '
                  'и начать копить.',
              question:
                  'Что нужно сделать первым?',
              answers: [
                TaskAnswer(
                  text:
                      'Потратить деньги на первую понравившуюся вещь',
                  correct: false,
                  explanation:
                      'Если начать тратить без плана, '
                      'денег может не хватить на обязательные расходы.',
                ),
                TaskAnswer(
                  text:
                      'Сначала распределить деньги по категориям',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Положить все деньги в копилку',
                  correct: false,
                  explanation:
                      'Копить важно, но обязательные расходы '
                      'тоже нужно учитывать.',
                ),
              ],
            ),
            TaskStage(
              title: 'Расставляем приоритеты',
              story:
                  'Финни нужно купить еду и учебные принадлежности. '
                  'Это обязательные расходы.',
              question:
                  'Как поступить с ними?',
              answers: [
                TaskAnswer(
                  text:
                      'Выделить им деньги в первую очередь',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Сначала потратить деньги на игрушки',
                  correct: false,
                  explanation:
                      'Игрушки относятся к желаниям. '
                      'Сначала нужно обеспечить обязательные расходы.',
                ),
                TaskAnswer(
                  text:
                      'Вообще не учитывать обязательные расходы',
                  correct: false,
                  explanation:
                      'Тогда план бюджета может не сработать.',
                ),
              ],
            ),
            TaskStage(
              title: 'Оставляем место для цели',
              story:
                  'После обязательных расходов у Финни ещё остаются деньги.',
              question:
                  'Что разумно сделать с частью остатка?',
              answers: [
                TaskAnswer(
                  text:
                      'Отложить часть денег в копилку',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Потратить весь остаток сразу',
                  correct: false,
                  explanation:
                      'Если потратить весь остаток, '
                      'до цели будет сложнее добраться.',
                ),
                TaskAnswer(
                  text:
                      'Потратить деньги случайно',
                  correct: false,
                  explanation:
                      'Случайные траты не помогают выполнить финансовый план.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 2. НЕДОСТАТОК ДЕНЕГ
      // ======================================================

      case 2:
        return TaskScenario(
          finalMessage:
              'Ты научился оставлять свободные деньги '
              'и не тратить больше запланированного.',
          stages: [
            TaskStage(
              title: 'Свободные деньги',
              story:
                  'У Финни осталось 100 🪙 после обязательных расходов.',
              question:
                  'Можно ли считать эти деньги бесконечным запасом?',
              answers: [
                TaskAnswer(
                  text:
                      'Да, можно тратить сколько угодно',
                  correct: false,
                  explanation:
                      'Свободные деньги всё равно ограничены.',
                ),
                TaskAnswer(
                  text:
                      'Нет, их тоже нужно учитывать в плане',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Да, потому что баланс никогда не закончится',
                  correct: false,
                  explanation:
                      'Баланс уменьшается после каждой покупки.',
                ),
              ],
            ),
            TaskStage(
              title: 'Появилось желание',
              story:
                  'Финни увидел игрушку за 150 🪙.',
              question:
                  'Хватит ли ему свободных 100 🪙?',
              answers: [
                TaskAnswer(
                  text: 'Да',
                  correct: false,
                  explanation:
                      '150 больше 100, поэтому денег недостаточно.',
                ),
                TaskAnswer(
                  text: 'Нет',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Хватит, если нажать купить два раза',
                  correct: false,
                  explanation:
                      'Повторная покупка не создаёт новые деньги.',
                ),
              ],
            ),
            TaskStage(
              title: 'Ищем решение',
              story:
                  'Финни всё ещё хочет игрушку.',
              question:
                  'Как можно решить проблему без долга?',
              answers: [
                TaskAnswer(
                  text:
                      'Отказаться от другой необязательной покупки',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Уйти в отрицательный баланс',
                  correct: false,
                  explanation:
                      'В игре нельзя тратить деньги, которых нет.',
                ),
                TaskAnswer(
                  text:
                      'Потратить деньги из обязательного бюджета',
                  correct: false,
                  explanation:
                      'Так можно нарушить план обязательных расходов.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 3. БЮДЖЕТНЫЙ ПЛАН
      // ======================================================

      case 3:
        return TaskScenario(
          finalMessage:
              'Ты составил план так, чтобы обязательные расходы '
              'не съели все деньги.',
          stages: [
            TaskStage(
              title: 'Большой план',
              story:
                  'Финни получил 500 🪙 на период.',
              question:
                  'Что помогает не потратить всё сразу?',
              answers: [
                TaskAnswer(
                  text: 'План бюджета',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text: 'Случайные покупки',
                  correct: false,
                  explanation:
                      'Случайные покупки не показывают, сколько денег останется.',
                ),
                TaskAnswer(
                  text: 'Игнорирование баланса',
                  correct: false,
                  explanation:
                      'Без контроля баланса легко потратить слишком много.',
                ),
              ],
            ),
            TaskStage(
              title: 'Три категории',
              story:
                  'Представь, что деньги лежат в трёх конвертах.',
              question:
                  'Какие категории нужны Финни?',
              answers: [
                TaskAnswer(
                  text:
                      'Обязательное, желания, копилка',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Только игрушки и еда',
                  correct: false,
                  explanation:
                      'В таком плане нет отдельной категории накоплений.',
                ),
                TaskAnswer(
                  text:
                      'Только копилка',
                  correct: false,
                  explanation:
                      'Нужно учитывать не только накопления.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем план',
              story:
                  'Финни распределил все 500 🪙.',
              question:
                  'Что важно проверить перед подтверждением?',
              answers: [
                TaskAnswer(
                  text:
                      'Что общая сумма не превышает баланс',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Что сумма обязательно больше баланса',
                  correct: false,
                  explanation:
                      'План не должен требовать больше денег, чем есть.',
                ),
                TaskAnswer(
                  text:
                      'Что все деньги потрачены на желания',
                  correct: false,
                  explanation:
                      'Желания являются только одной частью бюджета.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 4. ПРИОРИТЕТЫ
      // ======================================================

      case 4:
        return TaskScenario(
          finalMessage:
              'Финни сохранил деньги для важных расходов '
              'и не забыл про накопления.',
          stages: [
            TaskStage(
              title: 'Нужно или хочется?',
              story:
                  'Финни увидел красивую игрушку, '
                  'но ему также нужна еда.',
              question:
                  'Что важнее учесть первым?',
              answers: [
                TaskAnswer(
                  text: 'Еду',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text: 'Игрушку',
                  correct: false,
                  explanation:
                      'Игрушка является желанием, '
                      'а еда относится к обязательным расходам.',
                ),
                TaskAnswer(
                  text: 'Ничего',
                  correct: false,
                  explanation:
                      'Финансовый план требует принимать решения.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем желание',
              story:
                  'После обязательной покупки деньги остались.',
              question:
                  'Можно ли купить игрушку?',
              answers: [
                TaskAnswer(
                  text:
                      'Да, если она помещается в лимит желаний',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Да, даже если денег не хватает',
                  correct: false,
                  explanation:
                      'Покупка не должна создавать отрицательный баланс.',
                ),
                TaskAnswer(
                  text:
                      'Да, можно использовать деньги копилки',
                  correct: false,
                  explanation:
                      'Копилка предназначена для финансовой цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Оставляем запас',
              story:
                  'Финни может не тратить всё до последней монетки.',
              question:
                  'Почему запас денег полезен?',
              answers: [
                TaskAnswer(
                  text:
                      'Чтобы оставался резерв для следующих решений',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Чтобы деньги исчезали медленнее',
                  correct: false,
                  explanation:
                      'Запас нужен для управления деньгами.',
                ),
                TaskAnswer(
                  text:
                      'Чтобы вообще не покупать нужные вещи',
                  correct: false,
                  explanation:
                      'Нужные расходы всё равно нужно учитывать.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 5. ЦЕНА И БЮДЖЕТ
      // ======================================================

      case 5:
        return TaskScenario(
          finalMessage:
              'Ты выбрал покупку, которая действительно помещается '
              'в бюджет Финни.',
          stages: [
            TaskStage(
              title: 'Две игрушки',
              story:
                  'В магазине есть игрушка за 80 🪙 '
                  'и игрушка за 180 🪙.',
              question:
                  'Что нужно узнать перед покупкой?',
              answers: [
                TaskAnswer(
                  text:
                      'Размер своего бюджета',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Какую игрушку выбрал сосед',
                  correct: false,
                  explanation:
                      'Чужой выбор не определяет твой бюджет.',
                ),
                TaskAnswer(
                  text:
                      'Какая игрушка выглядит дороже',
                  correct: false,
                  explanation:
                      'Внешний вид не говорит, хватает ли денег.',
                ),
              ],
            ),
            TaskStage(
              title: 'Сравниваем',
              story:
                  'На желания Финни выделено 100 🪙.',
              question:
                  'Какая покупка помещается в этот лимит?',
              answers: [
                TaskAnswer(
                  text:
                      'Игрушка за 80 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Игрушка за 180 🪙',
                  correct: false,
                  explanation:
                      '180 больше выделенного лимита 100.',
                ),
                TaskAnswer(
                  text:
                      'Обе игрушки',
                  correct: false,
                  explanation:
                      'Обе покупки вместе тем более превышают лимит.',
                ),
              ],
            ),
            TaskStage(
              title: 'Финальный выбор',
              story:
                  'Финни хочет сохранить свой план.',
              question:
                  'Что лучше сделать?',
              answers: [
                TaskAnswer(
                  text:
                      'Выбрать вариант, который помещается в бюджет',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Взять более дорогой товар любой ценой',
                  correct: false,
                  explanation:
                      'Цена должна соответствовать доступным деньгам.',
                ),
                TaskAnswer(
                  text:
                      'Потратить деньги копилки',
                  correct: false,
                  explanation:
                      'Накопления предназначены для отдельной цели.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 6. ПРОВЕРКА БЮДЖЕТА
      // ======================================================

      case 6:
        return TaskScenario(
          finalMessage:
              'Ты научился проверять весь план перед его подтверждением.',
          stages: [
            TaskStage(
              title: 'Проверяем суммы',
              story:
                  'Финни хочет распределить 500 🪙.',
              question:
                  'Какое правило главное?',
              answers: [
                TaskAnswer(
                  text:
                      'Сумма всех категорий не должна быть больше 500',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Можно запланировать 700',
                  correct: false,
                  explanation:
                      'План не может превышать доступные деньги.',
                ),
                TaskAnswer(
                  text:
                      'Чем больше запланировано, тем лучше',
                  correct: false,
                  explanation:
                      'Больший план не означает правильный план.',
                ),
              ],
            ),
            TaskStage(
              title: 'Находим остаток',
              story:
                  'Финни запланировал 400 🪙 из 500.',
              question:
                  'Сколько осталось свободными?',
              answers: [
                TaskAnswer(
                  text: '100 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text: '50 🪙',
                  correct: false,
                  explanation:
                      '500 − 400 = 100.',
                ),
                TaskAnswer(
                  text: '200 🪙',
                  correct: false,
                  explanation:
                      '500 − 400 = 100.',
                ),
              ],
            ),
            TaskStage(
              title: 'Последний шаг',
              story:
                  'Остаток найден.',
              question:
                  'Что сделать перед подтверждением?',
              answers: [
                TaskAnswer(
                  text:
                      'Проверить весь план ещё раз',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Сразу всё потратить',
                  correct: false,
                  explanation:
                      'После проверки деньги не обязательно нужно тратить.',
                ),
                TaskAnswer(
                  text:
                      'Увеличить расходы без причины',
                  correct: false,
                  explanation:
                      'Изменять план нужно осознанно.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 7. ЦЕЛЬ
      // ======================================================

      case 7:
        return TaskScenario(
          finalMessage:
              'Финни выбрал большую цель и теперь понимает, '
              'ради чего он откладывает деньги.',
          stages: [
            TaskStage(
              title: 'Мечта Финни',
              story:
                  'Финни хочет накопить деньги на большую цель.',
              question:
                  'Что поможет сделать накопление понятным?',
              answers: [
                TaskAnswer(
                  text:
                      'Конкретная цель',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Тратить деньги без плана',
                  correct: false,
                  explanation:
                      'Без цели сложно понять, ради чего откладывать.',
                ),
                TaskAnswer(
                  text:
                      'Ждать случайных денег',
                  correct: false,
                  explanation:
                      'Накопление требует собственных регулярных решений.',
                ),
              ],
            ),
            TaskStage(
              title: 'Выбираем цель',
              story:
                  'Финни может выбрать домик, горку или корону.',
              question:
                  'Что важно знать о цели?',
              answers: [
                TaskAnswer(
                  text:
                      'Сколько она стоит',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Только её цвет',
                  correct: false,
                  explanation:
                      'Для накопления важна стоимость цели.',
                ),
                TaskAnswer(
                  text:
                      'Только её размер',
                  correct: false,
                  explanation:
                      'Размер не показывает, сколько нужно накопить.',
                ),
              ],
            ),
            TaskStage(
              title: 'Выбираем домик',
              story:
                  'Финни решил копить на домик за 500 🪙.',
              question:
                  'Что теперь нужно делать?',
              answers: [
                TaskAnswer(
                  text:
                      'Регулярно добавлять деньги в копилку',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Забыть о цели',
                  correct: false,
                  explanation:
                      'Без накоплений цель не приблизится.',
                ),
                TaskAnswer(
                  text:
                      'Потратить накопленное на случайную покупку',
                  correct: false,
                  explanation:
                      'Так прогресс к цели уменьшится.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 8. СТОИМОСТЬ ЦЕЛИ
      // ======================================================

      case 8:
        return TaskScenario(
          finalMessage:
              'Теперь Финни знает не только название цели, '
              'но и точную сумму, которую нужно накопить.',
          stages: [
            TaskStage(
              title: 'Цена мечты',
              story:
                  'Горка Финни стоит 400 🪙.',
              question:
                  'Что означает эта сумма?',
              answers: [
                TaskAnswer(
                  text:
                      'Это сумма, которую нужно накопить',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Это случайная награда',
                  correct: false,
                  explanation:
                      '400 🪙 является стоимостью цели.',
                ),
                TaskAnswer(
                  text:
                      'Это количество покупок',
                  correct: false,
                  explanation:
                      'Цена измеряется деньгами.',
                ),
              ],
            ),
            TaskStage(
              title: 'Смотрим прогресс',
              story:
                  'У Финни уже есть 100 🪙 из 400.',
              question:
                  'Сколько ещё нужно накопить?',
              answers: [
                TaskAnswer(
                  text: '300 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text: '200 🪙',
                  correct: false,
                  explanation:
                      '400 − 100 = 300.',
                ),
                TaskAnswer(
                  text: '500 🪙',
                  correct: false,
                  explanation:
                      'До цели осталось 300, а не 500.',
                ),
              ],
            ),
            TaskStage(
              title: 'Планируем путь',
              story:
                  'Финни хочет не забыть о цели.',
              question:
                  'Что лучше сделать?',
              answers: [
                TaskAnswer(
                  text:
                      'Откладывать небольшие суммы регулярно',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Ждать одного случайного большого платежа',
                  correct: false,
                  explanation:
                      'Регулярные взносы дают понятный прогресс.',
                ),
                TaskAnswer(
                  text:
                      'Потратить накопленные деньги',
                  correct: false,
                  explanation:
                      'Тогда расстояние до цели увеличится.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 9. ПЕРВЫЕ НАКОПЛЕНИЯ
      // ======================================================

      case 9:
        return TaskScenario(
          finalMessage:
              'Первая монетка отправилась в копилку. '
              'Большая цель начинается с маленького шага.',
          stages: [
            TaskStage(
              title: 'Первая монетка',
              story:
                  'У Финни есть свободные 50 🪙.',
              question:
                  'Что можно сделать, если он хочет накопить?',
              answers: [
                TaskAnswer(
                  text:
                      'Отложить 50 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Потратить их случайно',
                  correct: false,
                  explanation:
                      'Свободные деньги можно направить на цель.',
                ),
                TaskAnswer(
                  text:
                      'Сделать вид, что их нет',
                  correct: false,
                  explanation:
                      'Игнорирование денег не приближает к цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Копилка растёт',
              story:
                  'В копилке появилась первая сумма.',
              question:
                  'Что происходит с прогрессом?',
              answers: [
                TaskAnswer(
                  text:
                      'Он увеличивается',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Он автоматически обнуляется',
                  correct: false,
                  explanation:
                      'Пополнение копилки увеличивает накопления.',
                ),
                TaskAnswer(
                  text:
                      'Цель становится дороже',
                  correct: false,
                  explanation:
                      'Само пополнение не меняет стоимость цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Закрепляем привычку',
              story:
                  'Финни понял, что небольшие суммы тоже имеют значение.',
              question:
                  'Как продолжить?',
              answers: [
                TaskAnswer(
                  text:
                      'Повторять небольшие накопления',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Больше никогда не откладывать',
                  correct: false,
                  explanation:
                      'Тогда прогресс остановится.',
                ),
                TaskAnswer(
                  text:
                      'Тратить копилку после каждого взноса',
                  correct: false,
                  explanation:
                      'Так накопления не будут расти.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 10. ОТКАЗ ОТ МАЛЕНЬКОЙ ПОКУПКИ
      // ======================================================

      case 10:
        return TaskScenario(
          finalMessage:
              'Финни выбрал долгосрочную цель вместо необязательной '
              'покупки и сделал ещё один шаг к ней.',
          stages: [
            TaskStage(
              title: 'Есть выбор',
              story:
                  'У Финни есть 50 🪙. Он может купить мелочь '
                  'или отложить их.',
              question:
                  'Если цель сейчас важнее, что выбрать?',
              answers: [
                TaskAnswer(
                  text:
                      'Отложить деньги',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Потратить всё',
                  correct: false,
                  explanation:
                      'Покупка отдалит Финни от цели.',
                ),
                TaskAnswer(
                  text:
                      'Потратить деньги случайно',
                  correct: false,
                  explanation:
                      'Случайная трата не помогает цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Маленькая жертва',
              story:
                  'Финни отказывается от маленькой покупки сейчас.',
              question:
                  'Что он получает взамен?',
              answers: [
                TaskAnswer(
                  text:
                      'Более быстрый прогресс к цели',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Больше денег из воздуха',
                  correct: false,
                  explanation:
                      'Отказ от покупки не создаёт новые деньги.',
                ),
                TaskAnswer(
                  text:
                      'Бесплатную игрушку',
                  correct: false,
                  explanation:
                      'Игрушка не появляется автоматически.',
                ),
              ],
            ),
            TaskStage(
              title: 'Решение принято',
              story:
                  'Деньги отправляются в копилку.',
              question:
                  'Какой навык сейчас тренирует Финни?',
              answers: [
                TaskAnswer(
                  text:
                      'Умение откладывать ради цели',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Умение тратить всё сразу',
                  correct: false,
                  explanation:
                      'Финни как раз отказался от необязательной траты.',
                ),
                TaskAnswer(
                  text:
                      'Умение игнорировать бюджет',
                  correct: false,
                  explanation:
                      'Решение основано на финансовом плане.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 11. ПРОГРЕСС ЦЕЛИ
      // ======================================================

      case 11:
        return TaskScenario(
          finalMessage:
              'Ты помог Финни приблизиться к цели ещё на один заметный шаг.',
          stages: [
            TaskStage(
              title: 'Проверяем копилку',
              story:
                  'У Финни накоплено 200 🪙 из 500.',
              question:
                  'Сколько уже собрано от стоимости цели?',
              answers: [
                TaskAnswer(
                  text:
                      '200 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      '300 🪙',
                  correct: false,
                  explanation:
                      '300 🪙 ещё осталось накопить.',
                ),
                TaskAnswer(
                  text:
                      '500 🪙',
                  correct: false,
                  explanation:
                      '500 🪙 является полной стоимостью цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Смотрим вперёд',
              story:
                  'До цели осталось 300 🪙.',
              question:
                  'Что лучше делать дальше?',
              answers: [
                TaskAnswer(
                  text:
                      'Продолжать регулярно откладывать',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Потратить 200 из копилки',
                  correct: false,
                  explanation:
                      'Это уменьшит прогресс.',
                ),
                TaskAnswer(
                  text:
                      'Отменить цель',
                  correct: false,
                  explanation:
                      'Цель всё ещё достижима.',
                ),
              ],
            ),
            TaskStage(
              title: 'Следующий шаг',
              story:
                  'Финни хочет продолжать.',
              question:
                  'Что важнее всего?',
              answers: [
                TaskAnswer(
                  text:
                      'Сохранять последовательность',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Каждый раз начинать новую цель',
                  correct: false,
                  explanation:
                      'Так будет сложнее достичь результата.',
                ),
                TaskAnswer(
                  text:
                      'Тратить накопления после каждого шага',
                  correct: false,
                  explanation:
                      'Это замедлит накопление.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 12. НАКОПЛЕНИЯ
      // ======================================================

      case 12:
        return TaskScenario(
          finalMessage:
              'Финни сохранил ещё 100 🪙 для своей большой мечты.',
          stages: [
            TaskStage(
              title: 'Большая мечта',
              story:
                  'Финни уже накопил часть нужной суммы.',
              question:
                  'Что показывает прогресс цели?',
              answers: [
                TaskAnswer(
                  text:
                      'Сколько уже накоплено и сколько осталось',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Только настроение Финни',
                  correct: false,
                  explanation:
                      'Настроение и накопления являются разными характеристиками.',
                ),
                TaskAnswer(
                  text:
                      'Количество игрушек',
                  correct: false,
                  explanation:
                      'Игрушки не показывают прогресс накопления.',
                ),
              ],
            ),
            TaskStage(
              title: 'Решение',
              story:
                  'У Финни появились свободные деньги.',
              question:
                  'Куда их направить, если цель остаётся приоритетом?',
              answers: [
                TaskAnswer(
                  text:
                      'В копилку',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'На случайную покупку',
                  correct: false,
                  explanation:
                      'Случайная покупка отдаляет от цели.',
                ),
                TaskAnswer(
                  text:
                      'Потратить всё сразу',
                  correct: false,
                  explanation:
                      'Так накопления уменьшатся.',
                ),
              ],
            ),
            TaskStage(
              title: 'Закрепляем результат',
              story:
                  'Финни видит, что копилка стала больше.',
              question:
                  'Что это означает?',
              answers: [
                TaskAnswer(
                  text:
                      'До цели стало немного ближе',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'До цели стало дальше',
                  correct: false,
                  explanation:
                      'Пополнение копилки увеличивает прогресс.',
                ),
                TaskAnswer(
                  text:
                      'Цель исчезла',
                  correct: false,
                  explanation:
                      'Пополнение не отменяет цель.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 13. НУЖНО ИЛИ ХОЧЕТСЯ
      // ======================================================

      case 13:
        return TaskScenario(
          finalMessage:
              'Ты помог Финни отличить действительно нужную '
              'покупку от обычного желания.',
          stages: [
            TaskStage(
              title: 'Список покупок',
              story:
                  'Финни собирается в магазин.',
              question:
                  'Что стоит спросить себя перед покупкой?',
              answers: [
                TaskAnswer(
                  text:
                      'Мне это действительно нужно?',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Самая ли это яркая вещь?',
                  correct: false,
                  explanation:
                      'Яркость товара не показывает его необходимость.',
                ),
                TaskAnswer(
                  text:
                      'Купил ли это кто-то другой?',
                  correct: false,
                  explanation:
                      'Чужая покупка не делает вещь необходимой.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем бюджет',
              story:
                  'На обязательные расходы Финни выделил деньги.',
              question:
                  'Что нужно сделать перед оплатой?',
              answers: [
                TaskAnswer(
                  text:
                      'Проверить цену и доступный лимит',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Не смотреть на цену',
                  correct: false,
                  explanation:
                      'Без цены невозможно понять, хватает ли денег.',
                ),
                TaskAnswer(
                  text:
                      'Потратить деньги копилки',
                  correct: false,
                  explanation:
                      'Копилка предназначена для цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Покупаем',
              story:
                  'Товар стоит 80 🪙 и помещается в план.',
              question:
                  'Что делает покупку разумной?',
              answers: [
                TaskAnswer(
                  text:
                      'Она нужна и помещается в бюджет',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Она просто понравилась',
                  correct: false,
                  explanation:
                      'Одного желания недостаточно для разумной покупки.',
                ),
                TaskAnswer(
                  text:
                      'Она дороже всех остальных',
                  correct: false,
                  explanation:
                      'Высокая цена не делает покупку правильной.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 14. СРАВНЕНИЕ
      // ======================================================

      case 14:
        return TaskScenario(
          finalMessage:
              'Финни сравнил варианты и выбрал товар, '
              'который соответствует его плану.',
          stages: [
            TaskStage(
              title: 'Выбор товара',
              story:
                  'Перед Финни два похожих товара.',
              question:
                  'Что стоит сравнить?',
              answers: [
                TaskAnswer(
                  text:
                      'Цена и необходимость',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Только цвет упаковки',
                  correct: false,
                  explanation:
                      'Цвет не показывает финансовую выгоду.',
                ),
                TaskAnswer(
                  text:
                      'Только размер коробки',
                  correct: false,
                  explanation:
                      'Размер упаковки не определяет разумность покупки.',
                ),
              ],
            ),
            TaskStage(
              title: 'Смотрим на цену',
              story:
                  'Один вариант стоит 100 🪙, другой 160 🪙.',
              question:
                  'Если бюджет 120 🪙, какой вариант доступен?',
              answers: [
                TaskAnswer(
                  text:
                      'Вариант за 100 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Вариант за 160 🪙',
                  correct: false,
                  explanation:
                      '160 больше доступного бюджета 120.',
                ),
                TaskAnswer(
                  text:
                      'Оба варианта',
                  correct: false,
                  explanation:
                      '160 не помещается в бюджет.',
                ),
              ],
            ),
            TaskStage(
              title: 'Делаем вывод',
              story:
                  'Более дешёвый товар подходит Финни.',
              question:
                  'Что выбрать?',
              answers: [
                TaskAnswer(
                  text:
                      'Товар за 100 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Товар за 160 🪙',
                  correct: false,
                  explanation:
                      'Этот товар превышает лимит.',
                ),
                TaskAnswer(
                  text:
                      'Купить оба',
                  correct: false,
                  explanation:
                      'Общая стоимость тем более превышает лимит.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 15. ВЫГОДНАЯ ПОКУПКА
      // ======================================================

      case 15:
        return TaskScenario(
          finalMessage:
              'Ты помог Финни сравнить цены и сделать покупку '
              'без разрушения бюджета.',
          stages: [
            TaskStage(
              title: 'Сравнение',
              story:
                  'В одном магазине игрушка стоит 100 🪙, '
                  'а в другом 140 🪙.',
              question:
                  'Что выгоднее при одинаковом товаре?',
              answers: [
                TaskAnswer(
                  text:
                      '100 🪙',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      '140 🪙',
                  correct: false,
                  explanation:
                      'При одинаковом товаре 100 🪙 дешевле.',
                ),
                TaskAnswer(
                  text:
                      'Цена не имеет значения',
                  correct: false,
                  explanation:
                      'Цена напрямую влияет на бюджет.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем последствия',
              story:
                  'После покупки за 100 🪙 у Финни остаётся больше денег.',
              question:
                  'Почему это полезно?',
              answers: [
                TaskAnswer(
                  text:
                      'Остаётся больше денег для других целей',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Баланс автоматически увеличивается',
                  correct: false,
                  explanation:
                      'Покупка сама по себе не увеличивает баланс.',
                ),
                TaskAnswer(
                  text:
                      'Копилка автоматически удваивается',
                  correct: false,
                  explanation:
                      'Копилка не удваивается автоматически.',
                ),
              ],
            ),
            TaskStage(
              title: 'Финальный выбор',
              story:
                  'Оба товара одинаково подходят Финни.',
              question:
                  'Какое решение разумнее?',
              answers: [
                TaskAnswer(
                  text:
                      'Выбрать более дешёвый вариант',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Всегда выбирать более дорогой',
                  correct: false,
                  explanation:
                      'Более высокая цена сама по себе не даёт преимущества.',
                ),
                TaskAnswer(
                  text:
                      'Купить оба товара',
                  correct: false,
                  explanation:
                      'Покупать два одинаковых товара необязательно.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 16. ЕДА
      // ======================================================

      case 16:
        return TaskScenario(
          finalMessage:
              'Финни получил еду и теперь может позаботиться о себе.',
          stages: [
            TaskStage(
              title: 'Финни проголодался',
              story:
                  'У Финни мало еды, и он хочет восстановить сытость.',
              question:
                  'Что нужно приобрести?',
              answers: [
                TaskAnswer(
                  text:
                      'Еду',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Игрушку',
                  correct: false,
                  explanation:
                      'Игрушка влияет на веселье, но не решает проблему еды.',
                ),
                TaskAnswer(
                  text:
                      'Случайную вещь',
                  correct: false,
                  explanation:
                      'Она не поможет Финни поесть.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем деньги',
              story:
                  'Еда стоит 50 🪙.',
              question:
                  'Что нужно проверить перед покупкой?',
              answers: [
                TaskAnswer(
                  text:
                      'Есть ли 50 🪙 и место в обязательном бюджете',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Только цвет еды',
                  correct: false,
                  explanation:
                      'Цвет не определяет доступность покупки.',
                ),
                TaskAnswer(
                  text:
                      'Можно ли уйти в минус',
                  correct: false,
                  explanation:
                      'Отрицательный баланс недопустим.',
                ),
              ],
            ),
            TaskStage(
              title: 'Кормим Финни',
              story:
                  'Покупка прошла успешно.',
              question:
                  'Что произойдёт после использования еды?',
              answers: [
                TaskAnswer(
                  text:
                      'Сытость Финни увеличится',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Баланс станет бесконечным',
                  correct: false,
                  explanation:
                      'Покупка не создаёт бесконечные деньги.',
                ),
                TaskAnswer(
                  text:
                      'Цель автоматически завершится',
                  correct: false,
                  explanation:
                      'Кормление не завершает финансовую цель.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 17. ЖЕЛАНИЕ
      // ======================================================

      case 17:
        return TaskScenario(
          finalMessage:
              'Финни получил приятную покупку, '
              'но она была сделана в рамках доступного бюджета.',
          stages: [
            TaskStage(
              title: 'Хочу игрушку',
              story:
                  'Финни хочется немного развлечься.',
              question:
                  'Можно ли купить игрушку?',
              answers: [
                TaskAnswer(
                  text:
                      'Да, если она помещается в бюджет желаний',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Да, независимо от цены',
                  correct: false,
                  explanation:
                      'Цена должна соответствовать доступным деньгам.',
                ),
                TaskAnswer(
                  text:
                      'Только за деньги копилки',
                  correct: false,
                  explanation:
                      'Копилка предназначена для отдельной цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем лимит',
              story:
                  'На желания выделено достаточно денег.',
              question:
                  'Что ещё важно проверить?',
              answers: [
                TaskAnswer(
                  text:
                      'Что после покупки останется достаточно денег',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Что баланс станет отрицательным',
                  correct: false,
                  explanation:
                      'Отрицательный баланс недопустим.',
                ),
                TaskAnswer(
                  text:
                      'Что покупка заберёт деньги копилки',
                  correct: false,
                  explanation:
                      'Категории бюджета разделены.',
                ),
              ],
            ),
            TaskStage(
              title: 'Покупаем',
              story:
                  'Игрушка стоит 100 🪙.',
              question:
                  'Что получает Финни от такой покупки?',
              answers: [
                TaskAnswer(
                  text:
                      'Повышение веселья',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Автоматическое завершение цели',
                  correct: false,
                  explanation:
                      'Покупка желания не завершает цель накопления.',
                ),
                TaskAnswer(
                  text:
                      'Бесконечный бюджет',
                  correct: false,
                  explanation:
                      'После покупки баланс уменьшается.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // 18. ОТКАЗ ОТ ПОКУПКИ
      // ======================================================

      case 18:
        return TaskScenario(
          finalMessage:
              'Финни научился говорить «не сейчас», '
              'когда покупка может разрушить его финансовый план.',
          stages: [
            TaskStage(
              title: 'Неожиданная покупка',
              story:
                  'Финни увидел вещь, которую очень хочется купить.',
              question:
                  'Что нужно сделать первым?',
              answers: [
                TaskAnswer(
                  text:
                      'Проверить, есть ли она в плане',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Сразу нажать «Купить»',
                  correct: false,
                  explanation:
                      'Сначала нужно проверить необходимость и бюджет.',
                ),
                TaskAnswer(
                  text:
                      'Потратить накопления',
                  correct: false,
                  explanation:
                      'Накопления предназначены для цели.',
                ),
              ],
            ),
            TaskStage(
              title: 'Денег недостаточно',
              story:
                  'Цена вещи выше свободных денег.',
              question:
                  'Что делать?',
              answers: [
                TaskAnswer(
                  text:
                      'Отложить покупку',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Создать отрицательный баланс',
                  correct: false,
                  explanation:
                      'Игре нельзя уходить в отрицательный баланс.',
                ),
                TaskAnswer(
                  text:
                      'Забрать деньги из обязательных расходов',
                  correct: false,
                  explanation:
                      'Это может нарушить важную часть бюджета.',
                ),
              ],
            ),
            TaskStage(
              title: 'Финальный выбор',
              story:
                  'Финни решил сохранить свой финансовый план.',
              question:
                  'Почему это хорошее решение?',
              answers: [
                TaskAnswer(
                  text:
                      'План сохраняется, а покупку можно сделать позже',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Финни вообще больше ничего не сможет купить',
                  correct: false,
                  explanation:
                      'Отказ от одной покупки не запрещает будущие покупки.',
                ),
                TaskAnswer(
                  text:
                      'Финни теряет все свои деньги',
                  correct: false,
                  explanation:
                      'Наоборот, деньги остаются.',
                ),
              ],
            ),
          ],
        );

      // ======================================================
      // ЗАПАСНОЙ СЦЕНАРИЙ
      // ======================================================

      default:
        return TaskScenario(
          finalMessage:
              'Финни успешно прошёл финансовую ситуацию.',
          stages: [
            TaskStage(
              title: 'Ситуация',
              story:
                  'Финни хочет принять разумное финансовое решение.',
              question:
                  'Что стоит сделать?',
              answers: [
                TaskAnswer(
                  text:
                      'Проверить бюджет и последствия',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Потратить всё сразу',
                  correct: false,
                  explanation:
                      'Сначала нужно оценить последствия решения.',
                ),
                TaskAnswer(
                  text:
                      'Игнорировать баланс',
                  correct: false,
                  explanation:
                      'Баланс показывает доступные деньги.',
                ),
              ],
            ),
            TaskStage(
              title: 'Проверяем решение',
              story:
                  'У Финни есть несколько вариантов.',
              question:
                  'Что выбрать?',
              answers: [
                TaskAnswer(
                  text:
                      'Вариант, который помещается в план',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Самый дорогой вариант',
                  correct: false,
                  explanation:
                      'Цена сама по себе не делает решение правильным.',
                ),
                TaskAnswer(
                  text:
                      'Любой случайный вариант',
                  correct: false,
                  explanation:
                      'Решение должно учитывать бюджет.',
                ),
              ],
            ),
            TaskStage(
              title: 'Итог',
              story:
                  'Решение почти принято.',
              question:
                  'Что важно проверить напоследок?',
              answers: [
                TaskAnswer(
                  text:
                      'Что денег хватает и план не нарушен',
                  correct: true,
                  explanation: '',
                ),
                TaskAnswer(
                  text:
                      'Что баланс отрицательный',
                  correct: false,
                  explanation:
                      'Баланс не должен становиться отрицательным.',
                ),
                TaskAnswer(
                  text:
                      'Что все деньги потрачены',
                  correct: false,
                  explanation:
                      'Необязательно тратить весь баланс.',
                ),
              ],
            ),
          ],
        );
    }
  }
}


// ============================================================
// ЭТАП ЗАДАНИЯ
// ============================================================

class TaskStage {
  final String title;
  final String story;
  final String question;
  final List<TaskAnswer> answers;

  const TaskStage({
    required this.title,
    required this.story,
    required this.question,
    required this.answers,
  });
}


// ============================================================
// ОТВЕТ
// ============================================================

class TaskAnswer {
  final String text;
  final bool correct;
  final String explanation;

  const TaskAnswer({
    required this.text,
    required this.correct,
    required this.explanation,
  });
}