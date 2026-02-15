// lib/models/store.dart
class Store {
  final int id;
  final String name;
  final String? logo;
  final String? coverImage;
  final String? description;
  final String? telegram;
  final String? address;
  final String? businessType;
  final double? lat;
  final double? lng;
  final bool isVerified;

  Store({
    required this.id,
    required this.name,
    this.logo,
    this.coverImage,
    this.description,
    this.telegram,
    this.address,
    this.businessType,
    this.lat,
    this.lng,
    this.isVerified = false,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'] ?? '',
      logo: json['logo'],
      coverImage: json['coverImage'],
      description: json['description'],
      telegram: json['telegram'],
      address: json['address'],
      businessType: json['businessType'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      isVerified: json['isVerified'] ?? false,
    );
  }
}
