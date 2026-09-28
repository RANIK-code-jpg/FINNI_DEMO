import 'package:flutter/material.dart';
import '../../services/game_state.dart';
import '../../services/sound_service.dart';

class ShopScreen extends StatelessWidget {
  final GameState gameState;

  const ShopScreen({
    super.key,
    required this.gameState,
  });

  void _showInventory(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...items,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inventoryButton({
    required BuildContext context,
    required String icon,
    required String title,
    required int count,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '×$count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mandatory = [
      _Item('Яблоко для Финни', '🍎', 50, true, foodType: 'apple'),
      _Item('Рыбка для Финни', '🐟', 75, true, foodType: 'fish'),
      _Item('Ягоды для Финни', '🫐', 35, true, foodType: 'berries'),
      _Item('Учебные принадлежности', '🎒', 80, true),
      _Item('Нужная вещь', '📚', 100, true),
    ];

    const optional = [
      _Item('Игрушка', '🧸', 100, false),
      _Item('Мяч', '⚽', 150, false),
      _Item('Большая игра', '🎮', 200, false),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин'),
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          final availableToys = optional
              .where((item) => !gameState.toys.containsKey(item.name))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Баланс: ${gameState.balance} 🪙',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Обязательный бюджет: ${gameState.mandatoryRemaining} 🪙'),
                      Text('Бюджет желаний: ${gameState.optionalRemaining} 🪙'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ==================================================
              // КОЛИЧЕСТВА И ИНВЕНТАРЬ
              // ==================================================

              const Text(
                'Мои запасы',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.25,
                children: [
                  _inventoryButton(
                    context: context,
                    icon: '🍎',
                    title: 'Вся еда',
                    count: gameState.food + gameState.fishFood + gameState.berriesFood,
                    onTap: () => _showInventory(
                      context,
                      'Запас еды',
                      [
                        ListTile(leading: const Text('🍎', style: TextStyle(fontSize: 30)), title: const Text('Яблоки'), trailing: Text('× ${gameState.food}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        ListTile(leading: const Text('🐟', style: TextStyle(fontSize: 30)), title: const Text('Рыбки'), trailing: Text('× ${gameState.fishFood}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                        ListTile(leading: const Text('🫐', style: TextStyle(fontSize: 30)), title: const Text('Ягоды'), trailing: Text('× ${gameState.berriesFood}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  _inventoryButton(
                    context: context,
                    icon: '🧸',
                    title: 'Игрушки',
                    count: gameState.toyCount,
                    onTap: () => _showInventory(
                      context,
                      'Игрушки',
                      gameState.toys.isEmpty
                          ? [const ListTile(title: Text('Игрушек пока нет.'))]
                          : gameState.toys.entries
                              .map(
                                (entry) => ListTile(
                                  leading: const Text('🧸', style: TextStyle(fontSize: 30)),
                                  title: Text(entry.key),
                                  trailing: Text(
                                    '× ${entry.value}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  _inventoryButton(
                    context: context,
                    icon: '🎒',
                    title: 'Учёба',
                    count: gameState.schoolSupplies,
                    onTap: () => _showInventory(
                      context,
                      'Учебные принадлежности',
                      [
                        ListTile(
                          leading: const Text('🎒', style: TextStyle(fontSize: 30)),
                          title: const Text('Учебные принадлежности'),
                          trailing: Text(
                            '× ${gameState.schoolSupplies}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _inventoryButton(
                    context: context,
                    icon: '📚',
                    title: 'Вещи',
                    count: gameState.neededItems,
                    onTap: () => _showInventory(
                      context,
                      'Нужные вещи',
                      [
                        ListTile(
                          leading: const Text('📚', style: TextStyle(fontSize: 30)),
                          title: const Text('Нужная вещь'),
                          trailing: Text(
                            '× ${gameState.neededItems}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                'Обязательное',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...mandatory.map(
                (item) => _ItemCard(item: item, gameState: gameState),
              ),
              const SizedBox(height: 12),
              const Text(
                'Игрушки',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (availableToys.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Все игрушки уже куплены и находятся в запасах. 🎉',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                ...availableToys.map(
                  (item) => _ItemCard(item: item, gameState: gameState),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Item {
  final String name;
  final String icon;
  final int price;
  final bool mandatory;
  final String? foodType;

  const _Item(this.name, this.icon, this.price, this.mandatory, {this.foodType});
}

class _ItemCard extends StatelessWidget {
  final _Item item;
  final GameState gameState;

  const _ItemCard({
    required this.item,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final limit = item.mandatory
        ? gameState.mandatoryBudget
        : gameState.optionalBudget;

    final spent = item.mandatory
        ? gameState.mandatorySpent
        : gameState.optionalSpent;

    final allowed = gameState.budgetConfirmed &&
        gameState.balance >= item.price &&
        spent + item.price <= limit;

    return Card(
      child: ListTile(
        leading: Text(
          item.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${item.price} 🪙 • ${item.mandatory ? 'Обязательное' : 'Желание'}${item.foodType == 'fish' ? ' • сытость +35' : item.foodType == 'berries' ? ' • сытость +15' : item.foodType == 'apple' ? ' • сытость +20' : ''}',
        ),
        trailing: ElevatedButton(
          onPressed: allowed
              ? () {
                  final bool ok;

                  if (item.foodType != null) {
                    ok = gameState.buyFood(item.price, type: item.foodType!);
                  } else if (item.name == 'Учебные принадлежности') {
                    ok = gameState.buySchoolSupplies(item.price);
                  } else if (item.name == 'Нужная вещь') {
                    ok = gameState.buyNeededItem(item.price);
                  } else {
                    ok = gameState.buyToy(
                      name: item.name,
                      price: item.price,
                    );
                  }

                  // Звук при любой успешной покупке.
                  if (ok) {
                    SoundService.playBuying();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? '${item.name} добавлена в запасы! 🦕'
                            : 'Покупка не помещается в твой план.',
                      ),
                    ),
                  );
                }
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Сначала составь бюджет и оставь деньги в нужной категории.',
                      ),
                    ),
                  );
                },
          child: Text('${item.price} 🪙'),
        ),
      ),
    );
  }
}
