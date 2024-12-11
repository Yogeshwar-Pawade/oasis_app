class ChatMessage {
  final String sender;
  final String message;

  ChatMessage({required this.sender, required this.message});

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'] as String,
      message: map['message'] as String,
    );
  }

  Map<String, String> toMap() {
    return {
      'sender': sender,
      'message': message,
    };
  }
}