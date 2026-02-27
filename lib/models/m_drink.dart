
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      type: json['type'] ?? '',
      mdIconName: json['mdIconName'] ?? '',
      smIconName: json['smIconName'] ?? '',
      lgIconName: json['lgIconName'] ?? '',
      count: json['count'] ?? '',
      grinder: json['grinder'] ?? '',
      bypassSeq: json['bypass_seq'] ?? '',
      coffeeQty: json['coffee_qty'] ?? '',
      waterQty: json['water_qty'] ?? '',
      bypassQty: json['bypass_qty'] ?? '',
      pressure: json['pressure'] ?? '',
      preInfuse: json['pre_infuse'] ?? '',
      preInfuseDelay: json['pre_infuse_delay'] ?? '',
      milkTime: json['milk_time'] ?? '',
      milkFoamTime: json['milk_foam_time'] ?? '',
      mix1RawAmount: json['mix1_raw_amount'] ?? '',
      mix1WaterQuantity: json['mix1_water_quantity'] ?? '',
      mix2RawAmount: json['mix2_raw_amount'] ?? '',
      mix2WaterQuantity: json['mix2_water_quantity'] ?? '',
      mix3RawAmount: json['mix3_raw_amount'] ?? '',
      mix3WaterQuantity: json['mix3_water_quantity'] ?? '',
      isHotDrink: json['is_hot_drink'] ?? '',
      iceThrow: json['ice_throw'] ?? '',
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
