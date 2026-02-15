class PaymentMethod {
  final String id;
  final String name;
  final String? description;
  final String icon;
  final String color;

  PaymentMethod({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    required this.color,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}
