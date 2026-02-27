class DrinkModel {
  final String id;
  final String name;
  final String price;
  final String type;
  final String mdIconName;
  final String smIconName;
  final String lgIconName;
  final String count;
  final String grinder;
  final String bypassSeq;
  final String coffeeQty;
  final String waterQty;
  final String bypassQty;
  final String pressure;
  final String preInfuse;
  final String preInfuseDelay;
  final String milkTime;
  final String milkFoamTime;
  final String mix1RawAmount;
  final String mix1WaterQuantity;
  final String mix2RawAmount;
  final String mix2WaterQuantity;
  final String mix3RawAmount;
  final String mix3WaterQuantity;
  final String isHotDrink;
  final String iceThrow;

  DrinkModel({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.mdIconName,
    required this.smIconName,
    required this.lgIconName,
    required this.count,
    required this.grinder,
    required this.bypassSeq,
    required this.coffeeQty,
    required this.waterQty,
    required this.bypassQty,
    required this.pressure,
    required this.preInfuse,
    required this.preInfuseDelay,
    required this.milkTime,
    required this.milkFoamTime,
    required this.mix1RawAmount,
    required this.mix1WaterQuantity,
    required this.mix2RawAmount,
    required this.mix2WaterQuantity,
    required this.mix3RawAmount,
    required this.mix3WaterQuantity,
    required this.isHotDrink,
    required this.iceThrow,
  });

  factory DrinkModel.fromJson(Map<String, dynamic> json) {
    return DrinkModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      mdIconName: (json['mdIconName'] ?? '').toString(),
      smIconName: (json['smIconName'] ?? '').toString(),
      lgIconName: (json['lgIconName'] ?? '').toString(),
      count: (json['count'] ?? '').toString(),
      grinder: (json['grinder'] ?? '').toString(),
      bypassSeq: (json['bypass_seq'] ?? '').toString(),
      coffeeQty: (json['coffee_qty'] ?? '').toString(),
      waterQty: (json['water_qty'] ?? '').toString(),
      bypassQty: (json['bypass_qty'] ?? '').toString(),
      pressure: (json['pressure'] ?? '').toString(),
      preInfuse: (json['pre_infuse'] ?? '').toString(),
      preInfuseDelay: (json['pre_infuse_delay'] ?? '').toString(),
      milkTime: (json['milk_time'] ?? '').toString(),
      milkFoamTime: (json['milk_foam_time'] ?? '').toString(),
      mix1RawAmount: (json['mix1_raw_amount'] ?? '').toString(),
      mix1WaterQuantity: (json['mix1_water_quantity'] ?? '').toString(),
      mix2RawAmount: (json['mix2_raw_amount'] ?? '').toString(),
      mix2WaterQuantity: (json['mix2_water_quantity'] ?? '').toString(),
      mix3RawAmount: (json['mix3_raw_amount'] ?? '').toString(),
      mix3WaterQuantity: (json['mix3_water_quantity'] ?? '').toString(),
      isHotDrink: (json['is_hot_drink'] ?? '').toString(),
      iceThrow: (json['ice_throw'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'type': type,
      'mdIconName': mdIconName,
      'smIconName': smIconName,
      'lgIconName': lgIconName,
      'count': count,
      'grinder': grinder,
      'bypass_seq': bypassSeq,
      'coffee_qty': coffeeQty,
      'water_qty': waterQty,
      'bypass_qty': bypassQty,
      'pressure': pressure,
      'pre_infuse': preInfuse,
      'pre_infuse_delay': preInfuseDelay,
      'milk_time': milkTime,
      'milk_foam_time': milkFoamTime,
      'mix1_raw_amount': mix1RawAmount,
      'mix1_water_quantity': mix1WaterQuantity,
      'mix2_raw_amount': mix2RawAmount,
      'mix2_water_quantity': mix2WaterQuantity,
      'mix3_raw_amount': mix3RawAmount,
      'mix3_water_quantity': mix3WaterQuantity,
      'is_hot_drink': isHotDrink,
      'ice_throw': iceThrow,
    };
  }
}
