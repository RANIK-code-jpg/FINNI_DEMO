import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'services/game_state.dart';
import 'services/sound_service.dart';
import 'services/dino_asset_bounds.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/goal/goal_screen.dart';
import 'screens/piggy_bank/piggy_bank_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/progress/growth_stages_screen.dart';


// ==========================================================
// ЗАПУСК ПРИЛОЖЕНИЯ
// ==========================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final gameState = GameState();

  await gameState.load();
  await gameState.activateDemoMode();

  runApp(
    MyApp(
      gameState: gameState,
    ),
  );
}


// ==========================================================
// ПРИЛОЖЕНИЕ
// ==========================================================

class MyApp extends StatefulWidget {
  final GameState gameState;

  const MyApp({
    super.key,
    required this.gameState,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}


// ==========================================================
// ОСНОВНОЕ СОСТОЯНИЕ ПРИЛОЖЕНИЯ
// ==========================================================

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer =
      AudioPlayer();

  bool _musicEnabled = true;

  bool _appIsActive = true;

  bool _profileCreated = false;

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addObserver(this);

    _profileCreated = widget.gameState.profileCreated;
    widget.gameState.addListener(_onGameStateChanged);

    _startMusic();
  }


  void _onGameStateChanged() {
    if (!mounted) {
      return;
    }

    final profileCreated = widget.gameState.profileCreated;

    if (profileCreated != _profileCreated) {
      setState(() {
        _profileCreated = profileCreated;
      });
    }
  }

  void _openHomeAfterProfileCreated() {
    setState(() {
      _profileCreated = true;
    });

    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MyHomePage(
          gameState: widget.gameState,
          onMusicChanged: _setMusicEnabled,
          onProfileDeleted: _showProfileCreation,
        ),
      ),
      (route) => false,
    );
  }

  void _showProfileCreation() {
    setState(() {
      _profileCreated = false;
    });

    _navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          gameState: widget.gameState,
          onProfileCreated: _openHomeAfterProfileCreated,
        ),
      ),
      (route) => false,
    );
  }


  // ========================================================
  // МУЗЫКА
  // ========================================================

  Future<void> _startMusic() async {
    if (!_musicEnabled ||
        !_appIsActive) {
      return;
    }

    try {
      await _audioPlayer.setReleaseMode(
        ReleaseMode.loop,
      );

      await _audioPlayer.play(
        AssetSource(
          'audio/background_music.mp3',
        ),
      );
    } catch (_) {
      // Если музыка не загрузилась,
      // приложение всё равно продолжает работать.
    }
  }


  Future<void> _pauseMusic() async {
    try {
      await _audioPlayer.pause();
    } catch (_) {}
  }


  Future<void> _resumeMusic() async {
    if (!_musicEnabled ||
        !_appIsActive) {
      return;
    }

    try {
      await _audioPlayer.resume();
    } catch (_) {
      await _startMusic();
    }
  }


  Future<void> _setMusicEnabled(
    bool enabled,
  ) async {
    setState(() {
      _musicEnabled = enabled;
    });

    if (enabled) {
      await _startMusic();
    } else {
      await _pauseMusic();
    }
  }


  // ========================================================
  // ЖИЗНЕННЫЙ ЦИКЛ ПРИЛОЖЕНИЯ
  // ========================================================

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    switch (state) {
      case AppLifecycleState.resumed:
        _appIsActive = true;

        // Проверяем пассивный доход
        // после возвращения в приложение.
        widget.gameState
            .processPiggyBankIncome();

        _resumeMusic();

        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _appIsActive = false;

        _pauseMusic();

        break;
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance
        .removeObserver(this);

    widget.gameState.removeListener(_onGameStateChanged);

    _audioPlayer.dispose();

    super.dispose();
  }


  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,

      title: 'Питомец Финни',

      theme: ThemeData(
        fontFamily: 'Nunito',

        textTheme:
            const TextTheme(
          bodyLarge:
              TextStyle(
            fontWeight:
                FontWeight.w600,
          ),

          bodyMedium:
              TextStyle(
            fontWeight:
                FontWeight.w600,
          ),

          bodySmall:
              TextStyle(
            fontWeight:
                FontWeight.w600,
          ),

          titleLarge:
              TextStyle(
            fontWeight:
                FontWeight.w700,
          ),

          titleMedium:
              TextStyle(
            fontWeight:
                FontWeight.w700,
          ),

          titleSmall:
              TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),

        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              const Color(
            0xFFCFE68A,
          ),
        ),

        useMaterial3: true,
      ),

      home:
          _profileCreated
              ? MyHomePage(
                gameState: widget.gameState,
                onMusicChanged:
                    _setMusicEnabled,
              onProfileDeleted:
                    _showProfileCreation,
              )
              : ProfileScreen(
                  gameState:
                      widget.gameState,

                  onProfileCreated:
                      _openHomeAfterProfileCreated,
                ),
    );
  }
}


// ==========================================================
// ГЛАВНАЯ СТРАНИЦА
// ==========================================================

class MyHomePage extends StatefulWidget {
  final GameState gameState;

  final Future<void> Function(bool enabled)
      onMusicChanged;

  final VoidCallback onProfileDeleted;

  const MyHomePage({
    super.key,
    required this.gameState,
    required this.onMusicChanged,
    required this.onProfileDeleted,
  });

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}


class _MyHomePageState
    extends State<MyHomePage> {

  // ========================================================
  // ТАЙМЕР КОПИЛКИ
  // ========================================================

  // Таймер нужен для того, чтобы
  // обратный отсчёт на главной странице
  // обновлялся каждую секунду.
  Timer? _piggyBankTimer;

  // Короткое визуальное действие питомца.
  // eating = кормление, happy = игра.
  String _petAction = 'normal';
  int _petActionId = 0;


  // ========================================================
  // НАВИГАЦИЯ
  //
  // 0 = задания
  // 1 = магазин
  // 2 = главная
  // 3 = бюджет
  // 4 = цель
  // 5 = копилка
  //
  // Копилка не показывается в нижней навигации,
  // но остаётся доступна через карточку на главном экране.
  // ========================================================

  int _currentIndex = 2;


  GameState get gameState =>
      widget.gameState;


  // ========================================================
  // ЗАПУСК ТАЙМЕРА КОПИЛКИ
  // ========================================================

  @override
  void initState() {
    super.initState();

    // Обновляем главную страницу каждую секунду.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !gameState.tutorialCompleted) {
        _showTutorial();
      }
    });

    _piggyBankTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) {
          return;
        }

        // Проверяем состояние Финни и пассивный доход.
        gameState.processPetStateDecay();
        gameState.processPiggyBankIncome();

        // Перерисовываем страницу,
        // чтобы таймер менялся каждую секунду.
        setState(() {});
      },
    );
  }


  // ========================================================
  // НАСТРОЙКИ
  // ========================================================

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          gameState: gameState,
          onMusicChanged:
              widget.onMusicChanged,
          onProfileDeleted:
              widget.onProfileDeleted,
        ),
      ),
    );
  }


  // ========================================================
  // ИНФОРМАЦИЯ
  // ========================================================

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('О Финни'),
        content: Text(
          'Получай монеты за задания, планируй бюджет, покупай необходимое и откладывай на цель.\n\n'
          'Копилка приносит пассивный доход каждые 5 минут.\n\n'
          'Твои решения влияют на баланс, накопления и состояние ${gameState.petName.isEmpty ? 'питомца' : gameState.petName}.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showTutorial();
            },
            child: const Text('Пройти обучение'),
          ),
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Понятно')),
        ],
      ),
    );
  }

  void _showTutorial() {
    const steps = <({String title, String body, String icon})>[
      (title: 'Добро пожаловать!', icon: '🦕', body: 'Это Финни — твой виртуальный питомец. Заботься о нём и учись распоряжаться игровыми монетами. Настоящие деньги не используются.'),
      (title: 'Твой баланс', icon: '🪙', body: 'Баланс — монеты, которыми можно расплачиваться. Перед покупкой проверь цену и сколько денег останется.'),
      (title: 'Сначала план', icon: '🧾', body: 'Перед новым игровым периодом распредели деньги по трём направлениям: обязательные покупки, желания и накопления. Сумма плана не должна быть больше доступного бюджета.'),
      (title: 'Обязательное и желаемое', icon: '🛒', body: 'Еда и нужные вещи относятся к обязательным расходам. Игрушки и развлечения — желания. Можно отложить желание на потом, если денег мало.'),
      (title: 'Покорми Финни', icon: '🍎', body: 'В магазине можно купить яблоки, рыбку или ягоды. Нажми кнопку кормления и выбери, чем покормить питомца. Разная еда по-разному повышает сытость.'),
      (title: 'Накопи на цель', icon: '🐷', body: 'Выбери финансовую цель и регулярно откладывай часть монет. Накопления учитываются отдельно от доступного баланса.'),
      (title: 'Задания и награды', icon: '⭐', body: 'Выполняй задания о бюджете, покупках и сбережениях. За действия начисляются игровые монеты, а объяснение поможет понять результат решения.'),
      (title: 'Смотри на результат', icon: '📈', body: 'После покупок проверяй баланс, накопления и состояние Финни. Ошибка — не беда: можно скорректировать следующий план и выбрать более подходящие расходы.'),
      (title: 'Прогресс сохраняется', icon: '💾', body: 'Игра сохраняет профиль на этом устройстве. В разделе «Информация» всегда можно снова открыть это обучение. Взрослый раздел позволяет посмотреть прогресс и управлять локальным профилем.'),
    ];
    var current = 0;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setTutorialState) {
          final step = steps[current];
          return AlertDialog(
            title: Text('Обучение ${current + 1}/${steps.length}: ${step.title}'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(step.icon, style: const TextStyle(fontSize: 54)),
                  const SizedBox(height: 12),
                  Text(step.body, style: const TextStyle(fontSize: 16, height: 1.35)),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(value: (current + 1) / steps.length),
                ],
              ),
            ),
            actions: [
              if (current > 0)
                TextButton(onPressed: () => setTutorialState(() => current--), child: const Text('Назад')),
              TextButton(onPressed: () { gameState.completeTutorial(); Navigator.pop(dialogContext); }, child: const Text('Выйти')),
              FilledButton(
                onPressed: () {
                  if (current < steps.length - 1) {
                    setTutorialState(() => current++);
                  } else {
                    gameState.completeTutorial();
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(current == steps.length - 1 ? 'Начать игру' : 'Далее'),
              ),
            ],
          );
        },
      ),
    );
  }


  // ========================================================
  // КОРМЛЕНИЕ
  // ========================================================

  void _startPetAction(String action) {
    setState(() {
      _petAction = action;
      _petActionId++;
    });

    // После короткой анимации возвращаем обычный
    // внешний вид, который зависит от голода и настроения.
    Future.delayed(
      const Duration(milliseconds: 1500),
      () {
        if (!mounted) return;

        setState(() {
          _petAction = 'normal';
        });
      },
    );
  }


  Future<void> _feedPet() async {
    final foods = <({String type, String name, String icon, int count, int gain})>[
      (type: 'apple', name: 'Яблоко', icon: '🍎', count: gameState.food, gain: 20),
      (type: 'fish', name: 'Рыбка', icon: '🐟', count: gameState.fishFood, gain: 35),
      (type: 'berries', name: 'Ягоды', icon: '🫐', count: gameState.berriesFood, gain: 15),
    ].where((item) => item.count > 0).toList();

    if (gameState.hunger >= 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${gameState.petName.isEmpty ? 'Питомец' : gameState.petName} уже сыт. Сытость 100%!')),
      );
      return;
    }
    if (foods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Еды нет. Купи яблоко, рыбку или ягоды в магазине.')));
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Чем покормим Финни?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...foods.map((item) => Card(
                child: ListTile(
                  leading: Text(item.icon, style: const TextStyle(fontSize: 32)),
                  title: Text(item.name),
                  subtitle: Text('Сытость +${item.gain}'),
                  trailing: Text('×${item.count}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  onTap: () => Navigator.pop(sheetContext, item.type),
                ),
              )),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;

    final success = gameState.feedPet(type: selected);
    final name = gameState.petName.isEmpty ? 'Питомец' : gameState.petName;
    if (success) {
      SoundService.playEating();
      _startPetAction('eating');
    }
    final foodName = selected == 'fish' ? 'рыбку' : selected == 'berries' ? 'ягоды' : 'яблоко';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? '$name съел $foodName! Сытость +${selected == 'fish' ? 35 : selected == 'berries' ? 15 : 20}.' : '$name уже сыт.'),
    ));
  }


  void _playPet() {
    final success = gameState.playWithPet();
    final name = gameState.petName.isEmpty ? 'Питомец' : gameState.petName;

    if (success) {
      _startPetAction('happy');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Поиграли с $name! Веселье +${gameState.playFunGain} 🎾'
              : '$name уже достаточно повеселился. Веселье 100%! 🎾',
        ),
      ),
    );
  }

  // ========================================================
  // ПЕРЕХОД НА КОПИЛКУ
  // ========================================================

  void _openPiggyBank() {
    setState(() {
      _currentIndex = 5;
    });
  }


  // ========================================================
  // ЭКРАНЫ
  // ========================================================

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return TasksScreen(
          gameState: gameState,
        );

      case 1:
        return ShopScreen(
          gameState: gameState,
        );

      case 2:
        return _buildHomeScreen();

      case 3:
        return BudgetScreen(
          gameState: gameState,
        );

      case 4:
        return GoalScreen(
          gameState: gameState,
        );

      case 5:
        return PiggyBankScreen(
          gameState: gameState,
        );

      default:
        return _buildHomeScreen();
    }
  }


  // ========================================================
  // ГЛАВНЫЙ ЭКРАН
  // ========================================================

  Widget _buildHomeScreen() {
    return ListenableBuilder(
      listenable: gameState,

      builder: (
        context,
        _,
      ) {
        return Column(
          children: [

            // ==================================================
            // ФОН + TOOLBAR + ФИННИ
            // ==================================================

            Expanded(
              child: Stack(
                children: [

                  // ==================================================
                  // ПОЛНОРАЗМЕРНЫЙ ФОН
                  // ==================================================

                  Positioned.fill(
                    child: Image.asset(
                      'assets/finni_background.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),


                  // ==================================================
                  // TOOLBAR ПОВЕРХ ФОНА
                  // ==================================================

                  Positioned(
                    top: 6,
                    left: 10,
                    right: 10,

                    child: Row(
                      children: [

                        // ==================================================
                        // УРОВЕНЬ
                        // ==================================================

                        _LevelCircle(
                          level:
                              gameState.currentLevel,

                          progress:
                              gameState.levelProgress,

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GrowthStagesScreen(
                                  gameState:
                                      gameState,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 6),

                        // Откат уровня назад для демонстрации.
                        _ToolbarIconButton(
                          icon: Icons.skip_previous_rounded,
                          onTap: () {
                            gameState.retreatDemoLevel();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Демо: уровень ${gameState.currentLevel}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 6),

                        // Быстрый переход на следующий уровень для демонстрации.
                        _ToolbarIconButton(
                          icon: Icons.skip_next_rounded,
                          onTap: () {
                            gameState.advanceDemoLevel();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Демо: уровень ${gameState.currentLevel}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),

                        const Spacer(),


                        // ==================================================
                        // КОРМЛЕНИЕ
                        // ==================================================

                        _ToolbarIconButton(
                          icon:
                              Icons.restaurant,

                          onTap:
                              _feedPet,
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        // ==================================================
                        // ИГРА
                        // ==================================================

                        _ToolbarIconButton(
                          icon:
                              Icons.sports_esports,

                          onTap:
                              _playPet,
                        ),

                        const SizedBox(
                          width: 6,
                        ),


                        // ==================================================
                        // ИНФОРМАЦИЯ
                        // ==================================================

                        _ToolbarIconButton(
                          icon:
                              Icons.info_outline,

                          onTap:
                              _showInfo,
                        ),

                        const SizedBox(
                          width: 6,
                        ),


                        // ==================================================
                        // НАСТРОЙКИ
                        // ==================================================

                        _ToolbarIconButton(
                          icon:
                              Icons.settings,

                          onTap:
                              _openSettings,
                        ),
                      ],
                    ),
                  ),


                  // ==================================================
                  // ФИННИ
                  // ==================================================

                  // Динозавр автоматически привязывается к тени
                  // на исходном фоне. Мы учитываем реальные прозрачные
                  // поля каждого PNG, поэтому меняющийся размер,
                  // состояние и рисунок не сдвигают лапы вверх/вниз.
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const backgroundWidth = 1024.0;
                        const backgroundHeight = 1024.0;

                        // Координаты центра и линии контакта с тенью
                        // на исходном изображении finni_background.jpg.
                        const shadowCenterX = 515.0;
                        const shadowFootY = 800.0;

                        final backgroundScale = math.max(
                          constraints.maxWidth / backgroundWidth,
                          constraints.maxHeight / backgroundHeight,
                        );

                        final backgroundDrawWidth =
                            backgroundWidth * backgroundScale;
                        final backgroundDrawHeight =
                            backgroundHeight * backgroundScale;

                        final backgroundOffsetX =
                            (constraints.maxWidth - backgroundDrawWidth) / 2.0;
                        final backgroundOffsetY =
                            (constraints.maxHeight - backgroundDrawHeight) / 2.0;

                        final targetX =
                            backgroundOffsetX + shadowCenterX * backgroundScale;
                        final targetY =
                            backgroundOffsetY + shadowFootY * backgroundScale;

                        final visualState = _petAction == 'eating'
                            ? 'eating'
                            : _petAction == 'happy'
                                ? 'happy'
                                : gameState.petVisualState;

                        final petWidth = gameState.petSizeName == 'large'
                            ? 510.0
                            : gameState.petSizeName == 'medium'
                                ? 410.0
                                : 350.0;

                        final asset =
                            gameState.petAsset(state: visualState);

                        final bounds =
                            DinoAssetBounds.forAsset(asset);

                        return _PetDisplay(
                          key: ValueKey(_petActionId),
                          imageAsset: asset,
                          action: _petAction,
                          renderedWidth: petWidth,
                          visibleBounds: bounds,
                          targetX: targetX,
                          targetFootY: targetY,
                        );
                      },
                    ),
                  ),

                  // ==================================================
                  // ИМЯ ФИННИ
                  // ==================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,

                    child:
                        Center(
                      child: Text(
                        gameState
                                .petName
                                .isEmpty
                            ? 'Финни'
                            : gameState
                                .petName,

                        style:
                            const TextStyle(
                          fontSize: 18,

                          fontWeight:
                              FontWeight.w900,

                          color:
                              Colors.white,

                          shadows: [
                            Shadow(
                              blurRadius: 5,

                              offset:
                                  Offset(
                                1,
                                2,
                              ),

                              color:
                                  Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            // ==================================================
            // НАСТРОЕНИЕ + ГОЛОД
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              child: Row(
                children: [

                  Expanded(
                    child:
                        _StatusCard(
                      icon: '😊',

                      title:
                          'Настроение',

                      value:
                          gameState.fun,

                      progressColor:
                          const Color(
                        0xFF32C978,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        _StatusCard(
                      icon: '🍴',

                      title:
                          'Голод',

                      value:
                          gameState.hunger,

                      progressColor:
                          const Color(
                        0xFFFFB52E,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            // ==================================================
            // БАЛАНС + ЦЕЛЬ
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              child: Row(
                children: [

                  Expanded(
                    child:
                        _MoneyCard(
                      icon: '🪙',

                      title:
                          'Баланс',

                      value:
                          gameState.balance,

                      onTap: () {
                        setState(() {
                          _currentIndex =
                              3;
                        });
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        _MoneyCard(
                      icon: '🎯',

                      title:
                          'Цель',

                      value:
                          gameState.savings,

                      onTap: () {
                        setState(() {
                          _currentIndex =
                              4;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),


            // ==================================================
            // КОПИЛКА
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),

              child:
                  _PiggyBankHomeCard(
                gameState:
                    gameState,

                onTap:
                    _openPiggyBank,
              ),
            ),

            const SizedBox(
              height: 4,
            ),
          ],
        );
      },
    );
  }


  // ========================================================
  // ОСТАНОВКА ТАЙМЕРА
  // ========================================================

  @override
  void dispose() {
    // Обязательно останавливаем Timer,
    // когда главная страница уничтожается.
    _piggyBankTimer?.cancel();

    super.dispose();
  }


  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFFEAF7E5,
      ),

      body: SafeArea(
        child:
            _buildCurrentScreen(),
      ),


      // ======================================================
      // НИЖНЯЯ НАВИГАЦИЯ
      //
      // Здесь РОВНО 5 кнопок.
      // Кнопки Копилки здесь НЕТ.
      // ======================================================

      bottomNavigationBar:
          Container(
        margin:
            const EdgeInsets.fromLTRB(
          8,
          4,
          8,
          8,
        ),

        height: 68,

        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.97,
          ),

          borderRadius:
              BorderRadius.circular(
            21,
          ),

          boxShadow: const [
            BoxShadow(
              blurRadius: 9,

              offset:
                  Offset(0, 3),

              color:
                  Colors.black12,
            ),
          ],
        ),

        child: Row(
          children: [

            // ==================================================
            // ЗАДАНИЯ
            // ==================================================

            Expanded(
              child:
                  _BottomItem(
                icon:
                    Icons.assignment,

                title:
                    'Задания',

                active:
                    _currentIndex == 0,

                onTap: () {
                  setState(() {
                    _currentIndex =
                        0;
                  });
                },
              ),
            ),


            // ==================================================
            // МАГАЗИН
            // ==================================================

            Expanded(
              child:
                  _BottomItem(
                icon:
                    Icons.shopping_bag,

                title:
                    'Магазин',

                active:
                    _currentIndex == 1,

                onTap: () {
                  setState(() {
                    _currentIndex =
                        1;
                  });
                },
              ),
            ),


            // ==================================================
            // ГЛАВНАЯ
            // ==================================================

            Expanded(
              child:
                  _BottomItem(
                icon:
                    Icons.home,

                imageAsset: _currentIndex == 2
                    ? 'assets/dino_paw_blue.png'
                    : 'assets/dino_paw_gray.png',

                title:
                    'Главная',

                active:
                    _currentIndex == 2,

                onTap: () {
                  setState(() {
                    _currentIndex =
                        2;
                  });
                },
              ),
            ),


            // ==================================================
            // БЮДЖЕТ
            // ==================================================

            Expanded(
              child:
                  _BottomItem(
                icon:
                    Icons.account_balance_wallet,

                title:
                    'Бюджет',

                active:
                    _currentIndex == 3,

                onTap: () {
                  setState(() {
                    _currentIndex =
                        3;
                  });
                },
              ),
            ),


            // ==================================================
            // ЦЕЛЬ
            // ==================================================

            Expanded(
              child:
                  _BottomItem(
                icon:
                    Icons.flag,

                title:
                    'Цель',

                active:
                    _currentIndex == 4,

                onTap: () {
                  setState(() {
                    _currentIndex =
                        4;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ==========================================================
// ОТОБРАЖЕНИЕ ДИНОЗАВРА
// ==========================================================

class _PetDisplay extends StatefulWidget {
  final String imageAsset;
  final String action;
  final double renderedWidth;
  final DinoAssetBounds visibleBounds;
  final double targetX;
  final double targetFootY;

  const _PetDisplay({
    super.key,
    required this.imageAsset,
    required this.action,
    required this.renderedWidth,
    required this.visibleBounds,
    required this.targetX,
    required this.targetFootY,
  });

  @override
  State<_PetDisplay> createState() => _PetDisplayState();
}

class _PetDisplayState extends State<_PetDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.action == 'eating' || widget.action == 'happy') {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _PetDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.action != oldWidget.action) {
      _controller.reset();

      if (widget.action == 'eating' || widget.action == 'happy') {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sourceWidth = 1536.0;
    const sourceHeight = 1024.0;

    final scale = widget.renderedWidth / sourceWidth;
    final imageHeight = sourceHeight * scale;

    // Позиционируем НЕ прозрачный холст, а реальную видимую
    // часть динозавра. Поэтому центр картинки больше не влияет
    // на положение Финни относительно тени.
    final imageLeft =
        widget.targetX - widget.visibleBounds.centerX * scale;

    final imageTop =
        widget.targetFootY - widget.visibleBounds.bottom * scale;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: imageLeft,
          top: imageTop,
          width: widget.renderedWidth,
          height: imageHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Image.asset(
                widget.imageAsset,
                width: widget.renderedWidth,
                height: imageHeight,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Text(
                      '🦕',
                      style: TextStyle(fontSize: 100),
                    ),
                  );
                },
              );
            },
          ),
        ),

        if (widget.action == 'eating')
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _FoodParticlePainter(
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}


// ==========================================================
// ЧАСТИЦЫ ЕДЫ ПРИ КОРМЛЕНИИ
// ==========================================================

class _FoodParticlePainter extends CustomPainter {
  final double progress;

  const _FoodParticlePainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    // Точка старта находится около нижней центральной
    // части изображения, где расположен рот Финни.
    final start = Offset(
      size.width / 2,
      size.height * 0.61,
    );

    final paint = Paint();

    const colors = [
      Color(0xFFFF5C5C),
      Color(0xFFFFB52E),
      Color(0xFF7BCB5B),
      Color(0xFFE85DFF),
      Color(0xFFFF8A3D),
      Color(0xFF6CC5FF),
    ];

    for (int i = 0; i < 9; i++) {
      final angle =
          -math.pi * 0.92 +
          (i / 8) * math.pi * 0.84;

      final distance =
          20 +
          i * 3 +
          progress * (35 + i * 5);

      final wobble =
          math.sin(progress * math.pi * 2 + i) * 7;

      final x =
          start.dx +
          math.cos(angle) * distance +
          wobble;

      final y =
          start.dy +
          math.sin(angle) * distance +
          progress * progress * 35;

      final radius =
          3.0 +
          (1 - progress) * 2;

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FoodParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


// ==========================================================
// КРУГОВОЙ УРОВЕНЬ
// ==========================================================

class _LevelCircle
    extends StatelessWidget {
  final int level;

  final double progress;

  final VoidCallback onTap;

  const _LevelCircle({
    required this.level,
    required this.progress,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,

      shape:
          const CircleBorder(),

      elevation: 3,

      child: InkWell(
        onTap: onTap,

        customBorder:
            const CircleBorder(),

        child: SizedBox(
          width: 58,
          height: 58,

          child: Stack(
            alignment:
                Alignment.center,

            children: [

              SizedBox(
                width: 54,
                height: 54,

                child:
                    CircularProgressIndicator(
                  value: 1.0,

                  strokeWidth: 11,

                  backgroundColor:
                      Colors.transparent,

                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Color(
                      0xFFFFE0B2,
                    ),
                  ),
                ),
              ),


              SizedBox(
                width: 54,
                height: 54,

                child:
                    CircularProgressIndicator(
                  value: progress,

                  strokeWidth: 11,

                  strokeCap:
                      StrokeCap.round,

                  backgroundColor:
                      Colors.transparent,

                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Color(
                      0xFFFF9800,
                    ),
                  ),
                ),
              ),


              Text(
                '$level',

                style:
                    const TextStyle(
                  fontSize: 25,

                  height: 1,

                  fontWeight:
                      FontWeight.w900,

                  color:
                      Color(
                    0xFFFF9800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================================
// КНОПКА TOOLBAR
// ==========================================================

class _ToolbarIconButton
    extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        14,
      ),

      elevation: 2,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          14,
        ),

        child: SizedBox(
          width: 42,
          height: 42,

          child: Icon(
            icon,

            size: 21,

            color:
                const Color(
              0xFF245B91,
            ),
          ),
        ),
      ),
    );
  }
}


// ==========================================================
// КАРТОЧКА НАСТРОЕНИЯ / ГОЛОДА
// ==========================================================

class _StatusCard
    extends StatelessWidget {
  final String icon;

  final String title;

  final int value;

  final Color progressColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.progressColor,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        boxShadow: const [
          BoxShadow(
            blurRadius: 6,

            offset:
                Offset(0, 2),

            color:
                Colors.black12,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              Text(
                icon,

                style:
                    const TextStyle(
                  fontSize: 19,
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize: 12,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              Text(
                '$value%',

                style:
                    const TextStyle(
                  fontSize: 12,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),

            child:
                LinearProgressIndicator(
              minHeight: 7,

              value:
                  value / 100,

              backgroundColor:
                  Colors.grey.shade200,

              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                progressColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================================
// КАРТОЧКА ДЕНЕГ
// ==========================================================

class _MoneyCard
    extends StatelessWidget {
  final String icon;

  final String title;

  final int value;

  final VoidCallback onTap;

  const _MoneyCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        17,
      ),

      elevation: 1,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),

          child: Row(
            children: [

              Text(
                icon,

                style:
                    const TextStyle(
                  fontSize: 23,
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      style:
                          const TextStyle(
                        fontSize: 11,

                        color:
                            Colors.grey,
                      ),
                    ),

                    Text(
                      '$value 🪙',

                      style:
                          const TextStyle(
                        fontSize: 17,

                        fontWeight:
                            FontWeight.w900,

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
      ),
    );
  }
}


// ==========================================================
// КАРТОЧКА КОПИЛКИ НА ГЛАВНОМ ЭКРАНЕ
// ==========================================================

class _PiggyBankHomeCard
    extends StatelessWidget {
  final GameState gameState;

  final VoidCallback onTap;

  const _PiggyBankHomeCard({
    required this.gameState,
    required this.onTap,
  });


  String _formatTime(
    int seconds,
  ) {
    final minutes =
        seconds ~/ 60;

    final remainingSeconds =
        seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        17,
      ),

      elevation: 1,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),

          child: Row(
            children: [

              Container(
                width: 46,
                height: 46,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFFFE4EC,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Center(
                  child: Text(
                    '🐷',

                    style:
                        TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        const Text(
                          'Копилка',

                          style:
                              TextStyle(
                            fontSize: 15,

                            fontWeight:
                                FontWeight.w900,

                            color:
                                Color(
                              0xFF245B91,
                            ),
                          ),
                        ),

                        const Spacer(),

                        Text(
                          '${gameState.piggyBank} 🪙',

                          style:
                              const TextStyle(
                            fontSize: 16,

                            fontWeight:
                                FontWeight.w900,

                            color:
                                Color(
                              0xFFFF9800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Row(
                      children: [

                        Text(
                          gameState
                                      .piggyBank >
                                  0
                              ? '+${gameState.piggyBankIncome} 🪙 / 5 мин'
                              : 'Пополните Копилку',

                          style:
                              const TextStyle(
                            fontSize: 12,

                            fontWeight:
                                FontWeight.w700,

                            color:
                                Colors.black54,
                          ),
                        ),

                        const Spacer(),

                        if (gameState
                                .piggyBank >
                            0)
                          Text(
                            _formatTime(
                              gameState
                                  .piggyBankSecondsLeft,
                            ),

                            style:
                                const TextStyle(
                              fontSize: 12,

                              fontWeight:
                                  FontWeight.w800,

                              color:
                                  Color(
                                0xFF245B91,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 6,
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
    );
  }
}


// ==========================================================
// КНОПКА ИНВЕНТАРЯ
// ==========================================================

class _InventoryButton extends StatelessWidget {
  final String icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _InventoryButton({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
              Text(
                '× $count',
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ==========================================================
// НИЖНЯЯ НАВИГАЦИЯ
// ==========================================================

class _BottomItem
    extends StatelessWidget {
  final IconData icon;

  final String? imageAsset;

  final String title;

  final bool active;

  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    this.imageAsset,
    required this.title,
    this.active = false,
    required this.onTap,
  });


  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                icon,
                size: 22,
                color: active ? const Color(0xFF1E78C4) : Colors.blueGrey,
              ),
            )
          else
            Icon(
              icon,
              size: 22,
              color: active ? const Color(0xFF1E78C4) : Colors.blueGrey,
            ),

          const SizedBox(
            height: 2,
          ),

          Text(
            title,

            style: TextStyle(
              fontSize: 9,

              fontWeight: active
                  ? FontWeight.w800
                  : FontWeight.w500,

              color: active
                  ? const Color(
                      0xFF1E78C4,
                    )
                  : Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}