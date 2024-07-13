class ChatBubble {
  bool isServer;
  String text;
  bool tail;

  ChatBubble({required this.isServer, required this.text, this.tail = true});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isServer': isServer,
      'text': text,
      'tail': tail,
    };
  }

  factory ChatBubble.fromJson(Map<String, dynamic> json) {
    return ChatBubble(
        isServer: json['isServer'] as bool,
        text: json['text'] as String,
        tail: json['tail'] as bool);
  }

  ChatBubble copyWith({
    bool? isServer,
    String? text,
    bool? tail,
  }) {
    return ChatBubble(
      isServer: isServer ?? this.isServer,
      text: text ?? this.text,
      tail: tail ?? this.tail,
    );
  }
}
