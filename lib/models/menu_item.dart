class MenuItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String? type;  // 'link' for clickable items, null or 'dialog' for popup dialog
  final String? url;   // URL for clickable items

  MenuItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.type,
    this.url,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
    };
  }
}
