class AttributeOption {
  final int id;
  final String value;
  final String? attributeName;

  AttributeOption({
    required this.id,
    required this.value,
    this.attributeName,
  });

  factory AttributeOption.fromJson(Map<String, dynamic> json) {
    return AttributeOption(
      id: json['id'],
      value: json['value'] ?? '',
      attributeName:
          json['attribute'] != null ? json['attribute']['name'] : null,
    );
  }
}

class VariantOption {
  final AttributeOption attributeOption;

  VariantOption({required this.attributeOption});

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      attributeOption: AttributeOption.fromJson(json['attributeOption']),
    );
  }
}
