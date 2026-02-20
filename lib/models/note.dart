class Note {
  final String id;
  String title;
  String content;
  String deltaContent;
  DateTime createdAt;
  DateTime updatedAt;
  int color;
  bool isPinned;
  double width;
  double height;
  double posX;
  double posY;

  Note({
    required this.id,
    this.title = '',
    this.content = '',
    this.deltaContent = '',
    required this.createdAt,
    required this.updatedAt,
    this.color = 0xFFFFFF00,
    this.isPinned = false,
    this.width = 250.0,
    this.height = 300.0,
    this.posX = 50.0,
    this.posY = 50.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'deltaContent': deltaContent,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'isPinned': isPinned,
      'width': width,
      'height': height,
      'posX': posX,
      'posY': posY,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      deltaContent: json['deltaContent'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      color: json['color'] as int? ?? 0xFFFFFF00,
      isPinned: json['isPinned'] as bool? ?? false,
      width: (json['width'] as num?)?.toDouble() ?? 250.0,
      height: (json['height'] as num?)?.toDouble() ?? 300.0,
      posX: (json['posX'] as num?)?.toDouble() ?? 50.0,
      posY: (json['posY'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? deltaContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? color,
    bool? isPinned,
    double? width,
    double? height,
    double? posX,
    double? posY,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      deltaContent: deltaContent ?? this.deltaContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      width: width ?? this.width,
      height: height ?? this.height,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
    );
  }
}