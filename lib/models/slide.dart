class Slide {
  final int id;
  final String? title;
  final String image;
  final String? link;
  final int order;
  final bool isActive;

  Slide({
    required this.id,
    this.title,
    required this.image,
    this.link,
    required this.order,
    required this.isActive,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      link: json['link'],
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
