import 'package:flutter/foundation.dart';

import 'storage_service.dart';

import 'sound_service.dart';

class GameState extends ChangeNotifier {
  final StorageService storage = StorageService();

  // ==========================================================
  // ПРОФИЛЬ
  // ==========================================================

  String playerName = '';
  String petName = '';
  bool profileCreated = false;
  bool tutorialCompleted = false;

  int petColor = 0;
  int petVariant = 0;

  // ==========================================================
  // ЭКОНОМИКА
  // ==========================================================

  // Основной баланс игрока.
  int balance = 500;

  // Накопления на финансовую цель.
  //
  // Это отдельная система.
  // С Копилкой НЕ связана.
  int savings = 0;

  // Еда.
  int food = 0; // Совместимость со старыми сохранениями: яблоки.
  int fishFood = 0;
  int berriesFood = 0;

  // Инвентари покупок.
  int schoolSupplies = 0;
  int neededItems = 0;

  // Игрушки хранятся по названию.
  // Покупленная игрушка больше не показывается в магазине.
  Map<String, int> toys = {};

  int? lastPetStateUpdateAt;

  static const int petStateIntervalMinutes = 5;
  static const int hungerDecayPerInterval = 5;
  static const int funDecayPerInterval = 3;

  // ==========================================================
  // КОПИЛКА
  // ==========================================================

  // Деньги, которые находятся именно в Копилке.
  //
  // Копилка полностью независима от savings.
  int piggyBank = 0;

  // Время последнего начисления дохода Копилки.
  int? lastPiggyBankIncomeAt;

  // Один интервал пассивного дохода.
  static const int piggyBankIntervalMinutes = 5;

  // 1% за один интервал.
  static const double piggyBankIncomePercent = 0.01;

  // ==========================================================
  // НАГРАДА ЗА ВОЗВРАЩЕНИЕ В ИГРУ
  // ==========================================================

  static const int rewardCooldownMinutes = 30;
  static const int rewardAmount = 50;

  int? nextRewardAt;

  // ==========================================================
  // ДОСТУПНОСТЬ НАГРАДЫ
  // ==========================================================

  bool get rewardAvailable {
    if (nextRewardAt == null) {
      return true;
    }

    return DateTime.now().millisecondsSinceEpoch >=
        nextRewardAt!;
  }

  int get rewardSecondsLeft {
    if (nextRewardAt == null) {
      return 0;
    }

    final difference =
        nextRewardAt! -
        DateTime.now().millisecondsSinceEpoch;

    if (difference <= 0) {
      return 0;
    }

    return (difference / 1000).ceil();
  }

  // ==========================================================
  // ПАССИВНЫЙ ДОХОД КОПИЛКИ
  // ==========================================================

  int get piggyBankIncome {
    if (piggyBank <= 0) {
      return 0;
    }

    return (
      piggyBank *
      piggyBankIncomePercent
    ).ceil();
  }

  // ==========================================================
  // ТАЙМЕР КОПИЛКИ
  // ==========================================================

  int get piggyBankSecondsLeft {
    if (piggyBank <= 0) {
      return 0;
    }

    if (lastPiggyBankIncomeAt == null) {
      return piggyBankIntervalMinutes * 60;
    }

    final now =
        DateTime.now().millisecondsSinceEpoch;

    const intervalMilliseconds =
        piggyBankIntervalMinutes *
        60 *
        1000;

    final elapsed =
        now - lastPiggyBankIncomeAt!;

    final remaining =
        intervalMilliseconds -
        (elapsed % intervalMilliseconds);

    return (remaining / 1000).ceil();
  }

  // ==========================================================
  // НАЧИСЛЕНИЕ ПАССИВНОГО ДОХОДА
  // ==========================================================

  void processPiggyBankIncome() {
    if (piggyBank <= 0) {
      lastPiggyBankIncomeAt = null;
      return;
    }

    final now =
        DateTime.now().millisecondsSinceEpoch;

    // Первое пополнение Копилки.
    if (lastPiggyBankIncomeAt == null) {
      lastPiggyBankIncomeAt = now;

      save();
      notifyListeners();

      return;
    }

    const intervalMilliseconds =
        piggyBankIntervalMinutes *
        60 *
        1000;

    final elapsed =
        now - lastPiggyBankIncomeAt!;

    final completedIntervals =
        elapsed ~/ intervalMilliseconds;

    if (completedIntervals <= 0) {
      return;
    }

    final incomePerInterval =
        piggyBankIncome;

    if (incomePerInterval <= 0) {
      return;
    }

    final totalIncome =
        incomePerInterval *
        completedIntervals;

    // Доход остаётся внутри Копилки.
    //
    // Это новые деньги, поэтому бюджет
    // Копилки от этого НЕ увеличивается.
    piggyBank += totalIncome;

    lastPiggyBankIncomeAt =
        lastPiggyBankIncomeAt! +
        completedIntervals *
            intervalMilliseconds;

    lastResult =
        'Копилка принесла +$totalIncome 🪙';

    save();
    notifyListeners();
  }

  // ==========================================================
  // БЮДЖЕТ
  // ==========================================================

  int mandatoryBudget = 0;
  int optionalBudget = 0;
  int savingsBudget = 0;

  // Отдельный план накоплений именно на выбранную финансовую цель.
  // Копилка сохраняет свою прежнюю механику и бюджет ниже остаётся
  // отдельной категорией.
  int goalBudget = 0;

  bool budgetConfirmed = false;

  // Сколько уже потрачено из обязательного бюджета.
  int mandatorySpent = 0;

  // Сколько уже потрачено из необязательного бюджета.
  int optionalSpent = 0;

  // Сколько уже переведено из бюджета Копилки
  // непосредственно в Копилку.
  int savingsSpent = 0;

  // Сколько уже внесено из бюджета периода в финансовую цель.
  int goalBudgetSpent = 0;

  // ==========================================================
  // ПИТОМЕЦ
  // ==========================================================

  int level = 1;

  int hunger = 50;
  int fun = 50;

  // ==========================================================
  // ЦЕЛЬ
  // ==========================================================

  // goalProgress и savings относятся
  // только к финансовой цели.
  //
  // Копилка сюда НЕ входит.
  String goal = 'Домик Финни';

  int goalProgress = 0;

  int goalCost = 500;

  bool goalCompleted = false;

  // Названия целей, которые уже были полностью выполнены.
  // Выполненная цель больше не может быть выбрана повторно.
  List<String> completedGoals = [];

  // ==========================================================
  // ИГРОВОЙ ЦИКЛ
  // ==========================================================

  int period = 1;

  final int maxPeriods = 5;

  // ==========================================================
  // ОЧКИ РАЗВИТИЯ ФИННИ
  // ==========================================================

  int developmentPoints = 0;

  int get currentLevel {
    // Рост Финни напрямую связан не только с очками развития,
    // но и с выполненными финансовыми целями.
    //
    // LVL 2 невозможен без хотя бы одной выполненной цели.
    // LVL 3 невозможен без хотя бы двух выполненных целей.
    if (developmentPoints >= 130 && completedGoals.length >= 2) {
      return 3;
    }

    if (developmentPoints >= 60 && completedGoals.isNotEmpty) {
      return 2;
    }

    return 1;
  }

  double get levelProgress {
    if (currentLevel == 3) {
      return 1.0;
    }

    if (currentLevel == 1) {
      return (
        developmentPoints / 60
      ).clamp(
        0.0,
        1.0,
      ).toDouble();
    }

    return (
      (developmentPoints - 60) / 70
    ).clamp(
      0.0,
      1.0,
    ).toDouble();
  }

  int get pointsToNextLevel {
    if (currentLevel == 3) {
      return 0;
    }

    if (currentLevel == 1) {
      return 60 - developmentPoints;
    }

    return 130 - developmentPoints;
  }


  bool get nextLevelBlockedByGoal {
    if (currentLevel >= 3) {
      return false;
    }

    return completedGoals.length < currentLevel;
  }

  int get goalsNeededForNextLevel {
    if (currentLevel >= 3) {
      return 0;
    }

    return currentLevel - completedGoals.length;
  }

  // ==========================================================
  // ЗАДАНИЯ
  // ==========================================================

  bool periodTaskCompleted = false;

  int completedTasksCount = 0;

  List<int> completedTasks = [];

  String lastResult =
      'Начни с планирования бюджета.';

  int totalRewards = 0;

  // ==========================================================
  // ВНЕШНИЕ ЗНАЧЕНИЯ
  // ==========================================================

  // ==========================================================
  // ВНЕШНИЙ ВИД ДИНОЗАВРА
  // ==========================================================

  // 3 цвета, 3 узора и 3 размера.
  // Размер автоматически зависит от уровня:
  // LVL 1 -> small, LVL 2 -> medium, LVL 3 -> large.
  String get petColorName {
    const colors = [
      'green',
      'blue',
      'yellow',
    ];

    return colors[
      petColor.clamp(0, colors.length - 1).toInt()
    ];
  }

  String get petPatternName {
    const patterns = [
      'dots',
      'spikes',
      'stripes',
    ];

    return patterns[
      petVariant.clamp(0, patterns.length - 1).toInt()
    ];
  }

  String get petSizeName {
    switch (currentLevel) {
      case 3:
        return 'large';
      case 2:
        return 'medium';
      default:
        return 'small';
    }
  }

  String get petVisualState {
    // Если Финни сильно голоден или ему скучно,
    // на главном экране показываем грустное состояние.
    if (hunger <= 20 || fun <= 20) {
      return 'sad';
    }

    return 'neutral';
  }

  String petAsset({
    String? state,
    int? stage,
  }) {
    final size = stage == null
        ? petSizeName
        : switch (stage) {
            3 => 'large',
            2 => 'medium',
            _ => 'small',
          };

    final safeState = state ?? petVisualState;

    return 'assets/dino/${safeState}_'
        '${petPatternName}_'
        '${petColorName}_'
        '$size.png';
  }


  // Смещение прозрачного холста динозавра.
  // В исходных PNG динозавр находится не в одном и том же месте.
  // Поэтому центрируем именно видимую часть, а не весь PNG.
  double petVisualOffsetX({
    String? state,
    int? stage,
    required double renderedWidth,
  }) {
    final size = stage == null
        ? petSizeName
        : switch (stage) {
            3 => 'large',
            2 => 'medium',
            _ => 'small',
          };

    final safeState = state ?? petVisualState;

    const visibleCenters = <String, double>{
      'eating_small': 290.3,
      'eating_medium': 842.0,
      'eating_large': 858.6,
      'happy_small': 254.7,
      'happy_medium': 677.4,
      'happy_large': 1206.8,
      'neutral_small': 257.4,
      'neutral_medium': 686.4,
      'neutral_large': 1218.0,
      'sad_small': 250.4,
      'sad_medium': 677.0,
      'sad_large': 1209.4,
    };

    final centerX = visibleCenters['${safeState}_$size'] ?? 768.0;

    return (768.0 - centerX) * renderedWidth / 1536.0;
  }

  // Оставляем старое свойство для совместимости
  // с другими экранами проекта.
  String get petEmoji => '🦕';

  String get petStage {
    if (level >= 3) {
      return 'Большой Финни';
    }

    if (level >= 2) {
      return 'Юный Финни';
    }

    return 'Маленький Финни';
  }

  int get availableBudget {
    return balance;
  }

  int get plannedTotal {
    return mandatoryBudget +
        optionalBudget +
        goalBudget +
        savingsBudget;
  }

  // ==========================================================
  // ОСТАТОК БЮДЖЕТА НА ФИНАНСОВУЮ ЦЕЛЬ
  // ==========================================================

  int get goalBudgetRemaining {
    return (
      goalBudget -
      goalBudgetSpent
    ).clamp(
      0,
      goalBudget,
    ).toInt();
  }

  // ==========================================================
  // ОСТАТОК БЮДЖЕТА КОПИЛКИ
  // ==========================================================

  int get savingsRemaining {
    return (
      savingsBudget -
      savingsSpent
    ).clamp(
      0,
      savingsBudget,
    ).toInt();
  }

  // ==========================================================
  // ОСТАТОК ОБЯЗАТЕЛЬНОГО БЮДЖЕТА
  // ==========================================================

  int get mandatoryRemaining {
    return (
      mandatoryBudget -
      mandatorySpent
    ).clamp(
      0,
      mandatoryBudget,
    ).toInt();
  }

  // ==========================================================
  // ОСТАТОК НЕОБЯЗАТЕЛЬНОГО БЮДЖЕТА
  // ==========================================================

  int get optionalRemaining {
    return (
      optionalBudget -
      optionalSpent
    ).clamp(
      0,
      optionalBudget,
    ).toInt();
  }

  // ==========================================================
  // ОСТАТОК ОБЩЕГО БЮДЖЕТА
  // ==========================================================

  // Общий остаток складывается из обязательных расходов, желаний,
  // плана на финансовую цель и отдельного бюджета Копилки.
  int get budgetRemaining {
    return mandatoryRemaining +
        optionalRemaining +
        goalBudgetRemaining +
        savingsRemaining;
  }

  // ==========================================================
  // ПРОГРЕСС ЦЕЛИ
  // ==========================================================

  double get goalPercent {
    if (goalCost <= 0) {
      return 0;
    }

    return (
      goalProgress / goalCost
    ).clamp(
      0.0,
      1.0,
    ).toDouble();
  }

  // ==========================================================
  // ОЧКИ РАЗВИТИЯ
  // ==========================================================

  void addDevelopmentPoints(int amount) {
    if (amount <= 0) {
      return;
    }

    final previousLevel = currentLevel;

    developmentPoints += amount;

    level = currentLevel;

    // Звук только при фактическом повышении уровня.
    if (level > previousLevel) {
      SoundService.playSuccess();
    }

    save();
    notifyListeners();
  }

  // ==========================================================
  // СОЗДАНИЕ ПРОФИЛЯ
  // ==========================================================

  void createProfile({
    String playerName = '',
    required String petName,
    required int petColor,
    required int petVariant,
  }) {
    this.playerName = playerName;
    this.petName = petName;
    this.petColor = petColor;
    this.petVariant = petVariant;

    profileCreated = true;

    save();
    notifyListeners();
  }

  // ==========================================================
  // ИЗМЕНЕНИЕ ФИННИ
  // ==========================================================

  void changePet({
    required int petColor,
    required int petVariant,
  }) {
    this.petColor = petColor;
    this.petVariant = petVariant;

    save();
    notifyListeners();
  }

  // ==========================================================
  // ДОБАВЛЕНИЕ ДЕНЕГ
  // ==========================================================

  void addMoney(
    int amount,
  ) {
    if (amount <= 0) {
      return;
    }

    balance += amount;

    save();
    notifyListeners();
  }

  // ==========================================================
  // НАГРАДА ЗА ВОЗВРАЩЕНИЕ
  // ==========================================================

  bool claimTimeReward() {
    if (!rewardAvailable) {
      return false;
    }

    balance += rewardAmount;

    totalRewards += rewardAmount;

    nextRewardAt =
        DateTime.now()
            .add(
              const Duration(
                minutes:
                    rewardCooldownMinutes,
              ),
            )
            .millisecondsSinceEpoch;

    lastResult =
        'Ты получил награду за возвращение! '
        '+$rewardAmount 🪙';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // 🎯 ПОПОЛНЕНИЕ ЦЕЛИ
  // ==========================================================

  bool addToSavings(
    int amount,
  ) {
    if (amount <= 0 ||
        !budgetConfirmed ||
        goalCompleted ||
        balance < amount) {
      return false;
    }

    // Пополнять цель можно только в рамках суммы,
    // которую ребенок заранее выделил для неё в бюджете.
    if (amount > goalBudgetRemaining) {
      return false;
    }

    // Не даём внести больше, чем осталось до стоимости цели.
    final goalLeft = goalCost - goalProgress;
    if (goalLeft <= 0 || amount > goalLeft) {
      return false;
    }

    balance -= amount;
    savings += amount;
    goalProgress = savings;
    goalBudgetSpent += amount;

    _checkGoal();

    if (goalCompleted) {
      lastResult =
          'Цель «$goal» выполнена! $amount 🪙 добавлено. 🎉';
    } else {
      lastResult =
          'В цель добавлено $amount 🪙. ' +
          'До цели осталось ' +
          '${(goalCost - goalProgress).clamp(0, goalCost)} 🪙.';
    }

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // 🐷 ПОПОЛНЕНИЕ КОПИЛКИ
  // ==========================================================

  bool addToPiggyBank(
    int amount,
  ) {
    if (amount <= 0) {
      return false;
    }

    // Нельзя пользоваться Копилкой,
    // пока бюджет не подтверждён.
    if (!budgetConfirmed) {
      return false;
    }

    // Нельзя положить в Копилку
    // больше свободного бюджета Копилки.
    if (amount > savingsRemaining) {
      return false;
    }

    // Нельзя положить больше денег,
    // чем есть на основном балансе.
    if (balance < amount) {
      return false;
    }

    // Сначала начисляем уже накопившийся
    // пассивный доход.
    processPiggyBankIncome();

    // Переводим деньги.
    balance -= amount;

    piggyBank += amount;

    // Уменьшаем доступную часть бюджета Копилки.
    savingsSpent += amount;

    // Запускаем новый интервал дохода.
    lastPiggyBankIncomeAt =
        DateTime.now()
            .millisecondsSinceEpoch;

    lastResult =
        'Ты положил $amount 🪙 в Копилку.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // 🐷 СНЯТИЕ ИЗ КОПИЛКИ
  // ==========================================================

  bool withdrawFromPiggyBank(
    int amount,
  ) {
    if (amount <= 0) {
      return false;
    }

    // Сначала начисляем накопившийся доход.
    processPiggyBankIncome();

    // Проверяем сумму уже после начисления.
    if (piggyBank < amount) {
      return false;
    }

    piggyBank -= amount;

    balance += amount;

    // Возвращаем сумму в доступную часть
    // бюджета Копилки.
    savingsSpent = (
      savingsSpent -
      amount
    ).clamp(
      0,
      savingsSpent,
    ).toInt();

    if (piggyBank <= 0) {
      piggyBank = 0;

      lastPiggyBankIncomeAt = null;
    } else {
      lastPiggyBankIncomeAt =
          DateTime.now()
              .millisecondsSinceEpoch;
    }

    lastResult =
        'Ты забрал $amount 🪙 из Копилки.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // АВТОМАТИЧЕСКОЕ ИЗМЕНЕНИЕ СОСТОЯНИЯ ФИННИ
  // ==========================================================

  void processPetStateDecay() {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastPetStateUpdateAt == null) {
      lastPetStateUpdateAt = now;
      save();
      return;
    }

    const intervalMilliseconds =
        petStateIntervalMinutes * 60 * 1000;

    final elapsed = now - lastPetStateUpdateAt!;
    final completedIntervals = elapsed ~/ intervalMilliseconds;

    if (completedIntervals <= 0) {
      return;
    }

    hunger = (hunger - hungerDecayPerInterval * completedIntervals)
        .clamp(0, 100)
        .toInt();

    fun = (fun - funDecayPerInterval * completedIntervals)
        .clamp(0, 100)
        .toInt();

    lastPetStateUpdateAt =
        lastPetStateUpdateAt! + completedIntervals * intervalMilliseconds;

    lastResult = 'Финни немного проголодался и заскучал.';

    save();
    notifyListeners();
  }

  // ==========================================================
  // ИГРА С ФИННИ
  // ==========================================================

  int get toyCount => toys.values.fold(0, (sum, count) => sum + count);

  int get playFunGain {
    final count = toyCount.clamp(0, 5).toInt();
    return 5 + count * 3;
  }

  bool playWithPet() {
  processPetStateDecay();

  // Нельзя бесконечно повышать показатель выше 100%.
  if (fun >= 100) {
    lastResult = 'Финни уже достаточно повеселился. Веселье 100%! 🎾';
    notifyListeners();
    return false;
  }

  // Запоминаем уровень до начисления очков.
  final previousLevel = currentLevel;

  final gain = playFunGain.clamp(1, 20).toInt();

  fun = (fun + gain).clamp(0, 100).toInt();
  developmentPoints += 2;
  level = currentLevel;

  // Проигрываем звук только при повышении уровня.
  if (level > previousLevel) {
    SoundService.playSuccess();
  }

  lastResult = 'Вы поиграли с Финни. Веселье +$gain 🎾';

  save();
  notifyListeners();
  return true;
}

  // ==========================================================
  // ПОКУПКА ЕДЫ
  // ==========================================================

  bool buyFood(int price, {String type = 'apple'}) {
    if (price <= 0 || balance < price) {
      return false;
    }

    if (!_canSpendInCategory(
      price,
      mandatory: true,
    )) {
      return false;
    }

    // Уменьшаем основной баланс.
    balance -= price;

    // Добавляем еду в соответствующий запас.
    switch (type) {
      case 'fish':
        fishFood++;
        break;
      case 'berries':
        berriesFood++;
        break;
      default:
        food++;
        break;
    }

    // Учитываем расходы в обязательном бюджете.
    mandatorySpent += price;

    final String foodName;

    switch (type) {
      case 'fish':
        foodName = 'Рыбка';
        break;
      case 'berries':
        foodName = 'Ягоды';
        break;
      default:
        foodName = 'Яблоко';
        break;
    }

    lastResult =
        '$foodName куплено и добавлено в запас. '
        'Покорми Финни, когда он проголодается.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // ПОКУПКА УЧЕБНЫХ ПРИНАДЛЕЖНОСТЕЙ
  // ==========================================================

  bool buySchoolSupplies(int price) {
    if (price <= 0 || balance < price ||
        !_canSpendInCategory(price, mandatory: true)) {
      return false;
    }

    balance -= price;
    mandatorySpent += price;
    schoolSupplies++;
    lastResult = 'Учебные принадлежности добавлены в инвентарь. 🎒';

    save();
    notifyListeners();
    return true;
  }

  // ==========================================================
  // ПОКУПКА НУЖНОЙ ВЕЩИ
  // ==========================================================

  bool buyNeededItem(int price) {
    if (price <= 0 || balance < price ||
        !_canSpendInCategory(price, mandatory: true)) {
      return false;
    }

    balance -= price;
    mandatorySpent += price;
    neededItems++;
    lastResult = 'Нужная вещь добавлена в инвентарь. 📚';

    save();
    notifyListeners();
    return true;
  }

  // ==========================================================
  // ПОКУПКА ИГРУШКИ
  // ==========================================================

  bool buyToy({
    required String name,
    required int price,
  }) {
    if (price <= 0 || balance < price || toys.containsKey(name) ||
        !_canSpendInCategory(price, mandatory: false)) {
      return false;
    }

    balance -= price;
    optionalSpent += price;
    toys[name] = 1;
    lastResult = '$name добавлена в инвентарь. Теперь Финни веселее играть! 🧸';

    save();
    notifyListeners();
    return true;
  }

  // ==========================================================
  // НЕОБЯЗАТЕЛЬНАЯ ПОКУПКА
  // ==========================================================

  bool buyOptional({
    required int price,
    required int funGain,
  }) {
    if (price <= 0 ||
        balance < price) {
      return false;
    }

    if (!_canSpendInCategory(
      price,
      mandatory: false,
    )) {
      return false;
    }

    // Уменьшаем основной баланс.
    balance -= price;

    // Уменьшаем потраченный необязательный бюджет.
    optionalSpent += price;

    fun = (
      fun + funGain
    ).clamp(
      0,
      100,
    ).toInt();

    lastResult =
        'Покупка сделана. Финни веселее, '
        'но свободных монет стало меньше.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // ОБЯЗАТЕЛЬНАЯ ПОКУПКА
  // ==========================================================

  bool buyMandatory({
    required int price,
  }) {
    if (price <= 0 ||
        balance < price) {
      return false;
    }

    if (!_canSpendInCategory(
      price,
      mandatory: true,
    )) {
      return false;
    }

    // Уменьшаем основной баланс.
    balance -= price;

    // Уменьшаем потраченный обязательный бюджет.
    mandatorySpent += price;

    lastResult =
        'Обязательная покупка выполнена.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // ПРОВЕРКА БЮДЖЕТА
  // ==========================================================

  bool _canSpendInCategory(
    int price, {
    required bool mandatory,
  }) {
    if (!budgetConfirmed) {
      return false;
    }

    if (mandatory) {
      return mandatorySpent +
              price <=
          mandatoryBudget;
    }

    return optionalSpent +
            price <=
        optionalBudget;
  }

  Future<void> completeTutorial() async {
    tutorialCompleted = true;
    await save();
    notifyListeners();
  }

  // ==========================================================
  // КОРМЛЕНИЕ ФИННИ
  // ==========================================================

  bool feedPet({String type = 'apple'}) {
    final available = type == 'fish' ? fishFood : type == 'berries' ? berriesFood : food;
    if (available <= 0) {
      return false;
    }

    // Если сытость уже 100%, дополнительное кормление невозможно.
    if (hunger >= 100) {
      lastResult = 'Финни уже сыт. Сытость 100%! 🍎';
      notifyListeners();
      return false;
    }

    final gain = type == 'fish' ? 35 : type == 'berries' ? 15 : 20;
    if (type == 'fish') { fishFood--; } else if (type == 'berries') { berriesFood--; } else { food--; }

    hunger = (
      hunger + gain
    ).clamp(
      0,
      100,
    ).toInt();
    final previousLevel = currentLevel;
    developmentPoints += 3;

    level = currentLevel;

    final foodName = type == 'fish' ? 'рыбку' : type == 'berries' ? 'ягоды' : 'яблоко';
    lastResult = 'Финни съел $foodName. Сытость +$gain. Развитие +3.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // ИЗМЕНЕНИЕ ГОЛОДА
  // ==========================================================

  void changeHunger(
    int amount,
  ) {
    hunger = (
      hunger + amount
    ).clamp(
      0,
      100,
    ).toInt();

    save();
    notifyListeners();
  }

  // ==========================================================
  // ИЗМЕНЕНИЕ ВЕСЕЛЬЯ
  // ==========================================================

  void changeFun(
    int amount,
  ) {
    fun = (
      fun + amount
    ).clamp(
      0,
      100,
    ).toInt();

    save();
    notifyListeners();
  }

  // ==========================================================
  // СОХРАНЕНИЕ БЮДЖЕТА
  // ==========================================================

  bool saveBudget({
    required int mandatory,
    required int optional,
    required int savingsAmount,
    int goalSavingsAmount = 0,
  }) {
    if (mandatory < 0 ||
        optional < 0 ||
        savingsAmount < 0 ||
        goalSavingsAmount < 0) {
      return false;
    }

    final total =
        mandatory +
        optional +
        savingsAmount +
        goalSavingsAmount;

    if (total > balance) {
      return false;
    }

    mandatoryBudget = mandatory;

    optionalBudget = optional;

    savingsBudget =
        savingsAmount;

    goalBudget =
        goalSavingsAmount;

    // Новый бюджет начинается
    // с нулевых расходов.
    mandatorySpent = 0;
    optionalSpent = 0;
    savingsSpent = 0;
    goalBudgetSpent = 0;

    budgetConfirmed = true;

    lastResult =
        'Бюджет составлен. '
        'Теперь можно принимать решения и покупать.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // УСТАНОВКА ЦЕЛИ
  // ==========================================================

  bool setGoal({
    required String name,
    required int cost,
  }) {
    // Уже выполненную цель повторно выбрать нельзя.
    if (completedGoals.contains(name)) {
      return false;
    }

    goal = name;
    goalCost = cost;

    // Прогресс цели берётся только из savings.
    goalProgress = savings;
    goalCompleted = false;

    if (goalProgress >= goalCost) {
      _checkGoal();
    }

    save();
    notifyListeners();
    return true;
  }

  // ==========================================================
  // ПРОВЕРКА ЦЕЛИ
  // ==========================================================

  void _checkGoal() {
    if (!goalCompleted &&
        savings >= goalCost) {
      goalCompleted = true;

      if (!completedGoals.contains(goal)) {
        completedGoals.add(goal);
      }

      developmentPoints += 20;

      level = currentLevel;

      fun = (
        fun + 15
      ).clamp(
        0,
        100,
      ).toInt();

      lastResult =
          'Цель достигнута! '
          'Финни получил +20 к развитию! 🎉';
      SoundService.playSuccess();
    }
  }

  // ==========================================================
  // ЗАДАНИЯ
  // ==========================================================

  bool isTaskCompleted(
    int taskNumber,
  ) {
    return completedTasks
        .contains(taskNumber);
  }

  bool isTaskUnlocked(
    int taskNumber,
  ) {
    if (taskNumber < 1 ||
        taskNumber > 18) {
      return false;
    }

    if (taskNumber == 1 ||
        taskNumber == 7 ||
        taskNumber == 13) {
      return true;
    }

    return isTaskCompleted(
      taskNumber - 1,
    );
  }

  int taskReward(
    int taskNumber,
  ) {
    if (taskNumber < 1 ||
        taskNumber > 18) {
      return 0;
    }

    final positionInSection =
        ((taskNumber - 1) % 6) + 1;

    return 40 +
        positionInSection * 10;
  }

  void completeTask({
    required int taskNumber,
    required String result,
  }) {
    if (taskNumber < 1 ||
        taskNumber > 18) {
      return;
    }

    if (isTaskCompleted(
      taskNumber,
    )) {
      return;
    }

    if (!isTaskUnlocked(
      taskNumber,
    )) {
      return;
    }

    completedTasks.add(
      taskNumber,
    );

    completedTasks.sort();

    completedTasksCount =
        completedTasks.length;

    periodTaskCompleted = true;

    final reward =
        taskReward(taskNumber);

    totalRewards += reward;

    balance += reward;

    developmentPoints += 10;

    level = currentLevel;

    lastResult =
        '$result\n'
        'Развитие Финни: +10 ⭐';

    fun = (
      fun + 5
    ).clamp(
      0,
      100,
    ).toInt();

    save();
    notifyListeners();
  }

  // ==========================================================
  // ЗАВЕРШЕНИЕ ПЕРИОДА
  // ==========================================================

  bool finishPeriod() {
    if (!budgetConfirmed) {
      return false;
    }

    if (!periodTaskCompleted) {
      return false;
    }

    if (period >= maxPeriods) {
      return false;
    }

    period++;

    balance += 500;

    mandatoryBudget = 0;

    optionalBudget = 0;

    savingsBudget = 0;
    goalBudget = 0;

    mandatorySpent = 0;

    optionalSpent = 0;

    savingsSpent = 0;
    goalBudgetSpent = 0;

    budgetConfirmed = false;

    periodTaskCompleted = false;

    developmentPoints += 10;

    level = currentLevel;

    lastResult =
        'Начался период $period. '
        'Финни получил 500 🪙 '
        'и +10 к развитию.';

    save();
    notifyListeners();

    return true;
  }

  // ==========================================================
  // СБРОС ПРОГРЕССА
  // ==========================================================

  Future<void> resetProgress() async {
    // Сбрасываем именно игровой прогресс,
    // но сохраняем локальный профиль Финни.
    balance = 500;
    savings = 0;
    food = 0;
    fishFood = 0;
    berriesFood = 0;
    schoolSupplies = 0;
    neededItems = 0;
    toys = {};
    lastPetStateUpdateAt = null;

    piggyBank = 0;
    lastPiggyBankIncomeAt = null;

    mandatoryBudget = 0;
    optionalBudget = 0;
    savingsBudget = 0;
    goalBudget = 0;
    budgetConfirmed = false;
    mandatorySpent = 0;
    optionalSpent = 0;
    savingsSpent = 0;
    goalBudgetSpent = 0;

    developmentPoints = 0;
    level = 1;

    hunger = 50;
    fun = 50;

    goal = 'Домик Финни';
    goalProgress = 0;
    goalCost = 500;
    goalCompleted = false;
    completedGoals = [];

    period = 1;
    periodTaskCompleted = false;
    completedTasksCount = 0;
    completedTasks = [];

    lastResult = 'Начни с планирования бюджета.';
    totalRewards = 0;
    nextRewardAt = null;

    await save();
    notifyListeners();
  }

  // ==========================================================
  // ПОЛНОЕ УДАЛЕНИЕ ЛОКАЛЬНОГО ПРОФИЛЯ
  // ==========================================================

  Future<void> deleteLocalProfile() async {
    // Сначала удаляем сохранённые данные с устройства.
    await storage.clearGameState();

    // Возвращаем состояние к экрану создания профиля.
    playerName = '';
    petName = '';
    profileCreated = false;
    tutorialCompleted = false;
    petColor = 0;
    petVariant = 0;

    balance = 500;
    savings = 0;
    food = 0;
    fishFood = 0;
    berriesFood = 0;
    schoolSupplies = 0;
    neededItems = 0;
    toys = {};
    lastPetStateUpdateAt = null;

    piggyBank = 0;
    lastPiggyBankIncomeAt = null;

    mandatoryBudget = 0;
    optionalBudget = 0;
    savingsBudget = 0;
    goalBudget = 0;
    budgetConfirmed = false;
    mandatorySpent = 0;
    optionalSpent = 0;
    savingsSpent = 0;
    goalBudgetSpent = 0;

    developmentPoints = 0;
    level = 1;
    hunger = 50;
    fun = 50;

    goal = 'Домик Финни';
    goalProgress = 0;
    goalCost = 500;
    goalCompleted = false;
    completedGoals = [];

    period = 1;
    periodTaskCompleted = false;
    completedTasksCount = 0;
    completedTasks = [];

    lastResult = 'Создай нового питомца.';
    totalRewards = 0;
    nextRewardAt = null;

    notifyListeners();
  }

  // ==========================================================
  // СОХРАНЕНИЕ В MAP
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      // ======================================================
      // Профиль
      // ======================================================

      'playerName': playerName,

      'petName': petName,

      'profileCreated':
          profileCreated,
      'tutorialCompleted': tutorialCompleted,

      'petColor': petColor,

      'petVariant': petVariant,

      // ======================================================
      // Экономика
      // ======================================================

      'balance': balance,

      'savings': savings,

      'food': food,
      'fishFood': fishFood,
      'berriesFood': berriesFood,
      'schoolSupplies': schoolSupplies,
      'neededItems': neededItems,
      'toys': toys,
      'lastPetStateUpdateAt': lastPetStateUpdateAt,

      // ======================================================
      // Копилка
      // ======================================================

      'piggyBank': piggyBank,

      'lastPiggyBankIncomeAt':
          lastPiggyBankIncomeAt,

      // ======================================================
      // Бюджет
      // ======================================================

      'mandatoryBudget':
          mandatoryBudget,

      'optionalBudget':
          optionalBudget,

      'savingsBudget':
          savingsBudget,

      'goalBudget':
          goalBudget,

      'budgetConfirmed':
          budgetConfirmed,

      'mandatorySpent':
          mandatorySpent,

      'optionalSpent':
          optionalSpent,

      'savingsSpent':
          savingsSpent,

      'goalBudgetSpent':
          goalBudgetSpent,

      // ======================================================
      // Развитие
      // ======================================================

      'level': level,

      'developmentPoints':
          developmentPoints,

      // ======================================================
      // Финни
      // ======================================================

      'hunger': hunger,

      'fun': fun,

      // ======================================================
      // Цель
      // ======================================================

      'goal': goal,

      'goalProgress':
          goalProgress,

      'goalCost':
          goalCost,

      'goalCompleted':
          goalCompleted,

      'completedGoals':
          completedGoals,

      // ======================================================
      // Период
      // ======================================================

      'period': period,

      'periodTaskCompleted':
          periodTaskCompleted,

      // ======================================================
      // Задания
      // ======================================================

      'completedTasksCount':
          completedTasksCount,

      'completedTasks':
          completedTasks,

      // ======================================================
      // Результат
      // ======================================================

      'lastResult':
          lastResult,

      'totalRewards':
          totalRewards,

      // ======================================================
      // Награда
      // ======================================================

      'nextRewardAt':
          nextRewardAt,
    };
  }

  // ==========================================================
  // ЗАГРУЗКА ИЗ MAP
  // ==========================================================

  void fromMap(
    Map<String, dynamic> map,
  ) {
    // ========================================================
    // Профиль
    // ========================================================

    playerName =
        map['playerName'] ?? '';

    petName =
        map['petName'] ?? '';

    profileCreated =
        map['profileCreated'] ??
        false;
    tutorialCompleted = map['tutorialCompleted'] ?? false;

    petColor =
        map['petColor'] ?? 0;

    petVariant =
        map['petVariant'] ?? 0;

    // ========================================================
    // Экономика
    // ========================================================

    balance =
        map['balance'] ?? 500;

    savings =
        map['savings'] ?? 0;

    food = map['food'] ?? 0;
    fishFood = map['fishFood'] ?? 0;
    berriesFood = map['berriesFood'] ?? 0;

    schoolSupplies =
        map['schoolSupplies'] ?? 0;

    neededItems =
        map['neededItems'] ?? 0;

    final savedToys = map['toys'];
    if (savedToys is Map) {
      toys = savedToys.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    } else {
      toys = {};
    }

    lastPetStateUpdateAt =
        map['lastPetStateUpdateAt'];

    // ========================================================
    // Копилка
    // ========================================================

    piggyBank =
        map['piggyBank'] ?? 0;

    lastPiggyBankIncomeAt =
        map['lastPiggyBankIncomeAt'];

    // ========================================================
    // Бюджет
    // ========================================================

    mandatoryBudget =
        map['mandatoryBudget'] ?? 0;

    optionalBudget =
        map['optionalBudget'] ?? 0;

    savingsBudget =
        map['savingsBudget'] ?? 0;

    goalBudget =
        map['goalBudget'] ?? 0;

    budgetConfirmed =
        map['budgetConfirmed'] ??
        false;

    mandatorySpent =
        map['mandatorySpent'] ?? 0;

    optionalSpent =
        map['optionalSpent'] ?? 0;

    savingsSpent =
        map['savingsSpent'] ?? 0;

    goalBudgetSpent =
        map['goalBudgetSpent'] ?? 0;

    // ========================================================
    // Развитие
    // ========================================================

    developmentPoints =
        map['developmentPoints'] ?? 0;

    level = currentLevel;

    // ========================================================
    // Финни
    // ========================================================

    hunger =
        map['hunger'] ?? 50;

    fun =
        map['fun'] ?? 50;

    // ========================================================
    // Цель
    // ========================================================

    goal =
        map['goal'] ??
        'Домик Финни';

    goalProgress =
        map['goalProgress'] ??
        savings;

    goalCost =
        map['goalCost'] ?? 500;

    goalCompleted =
        map['goalCompleted'] ??
        (goalProgress >= goalCost);

    completedGoals =
        List<String>.from(
          map['completedGoals'] ?? const [],
        );

    // Миграция старых сохранений: если старая версия уже
    // отметила текущую цель выполненной, переносим её в список.
    if (goalCompleted && !completedGoals.contains(goal)) {
      completedGoals.add(goal);
    }

    // После загрузки целей пересчитываем уровень ещё раз,
    // потому что рост теперь зависит и от выполненных целей.
    level = currentLevel;

    // ========================================================
    // Период
    // ========================================================

    period =
        map['period'] ?? 1;

    periodTaskCompleted =
        map['periodTaskCompleted'] ??
        false;

    // ========================================================
    // Задания
    // ========================================================

    completedTasksCount =
        map['completedTasksCount'] ?? 0;

    completedTasks =
        List<int>.from(
          map['completedTasks'] ??
              const [],
        );

    // ========================================================
    // Результат
    // ========================================================

    lastResult =
        map['lastResult'] ??
        'Начни с планирования бюджета.';

    totalRewards =
        map['totalRewards'] ?? 0;

    // ========================================================
    // Награда
    // ========================================================

    nextRewardAt =
        map['nextRewardAt'];

    notifyListeners();
  }

  // ==========================================================
  // СОХРАНЕНИЕ
  // ==========================================================

  Future<void> save() async {
    await storage.saveGameState(
      toMap(),
    );
  }

  // ==========================================================
  // ЗАГРУЗКА
  // ==========================================================

  Future<void> load() async {
    final data =
        await storage.loadGameState();

    if (data != null) {
      fromMap(data);

      // Проверяем состояние Финни и пассивный доход,
      // пока приложение было закрыто.
      processPetStateDecay();
      processPiggyBankIncome();
    }
  }
}
