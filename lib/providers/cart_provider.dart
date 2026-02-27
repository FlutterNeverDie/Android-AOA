import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/m_drink.dart';

class CartItem {
  final DrinkModel drink;
  int quantity;

  CartItem({required this.drink, this.quantity = 1});
}

class CartState {
  final List<CartItem> items;
  final int totalPrice;

  CartState({this.items = const [], this.totalPrice = 0});

  CartState copyWith({List<CartItem>? items, int? totalPrice}) {
    return CartState(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => CartState();

  void addToCart(DrinkModel drink) {
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.drink.name == drink.name &&
          item.drink.isHotDrink == drink.isHotDrink,
    );

    List<CartItem> newItems = List.from(state.items);
    if (existingIndex >= 0) {
      newItems[existingIndex] = CartItem(
        drink: drink,
        quantity: state.items[existingIndex].quantity + 1,
      );
    } else {
      newItems.add(CartItem(drink: drink));
    }

    _updateState(newItems);
  }

  void removeFromCart(CartItem item) {
    final newItems = state.items.where((i) => i != item).toList();
    _updateState(newItems);
  }

  void clearCart() {
    _updateState([]);
  }

  void _updateState(List<CartItem> items) {
    int total = 0;
    for (var item in items) {
      total += (int.tryParse(item.drink.price) ?? 0) * item.quantity;
    }
    state = state.copyWith(items: items, totalPrice: total);
  }
}
