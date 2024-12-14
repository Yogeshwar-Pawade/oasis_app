import 'package:flutter/material.dart';
import '/models/chat_message.dart';
import '/utils/api_service.dart';
import '/utils/task_handler.dart';
import '/utils/db_helper.dart';
import '/conf/theme.dart';
import '/conf/glassbutton.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, dynamic>> taskData;
  final String userName;

  ChatScreen({required this.taskData, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _chatMessages = [];
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  Future<void> _loadChatMessages() async {
    final messages = await _dbHelper.getChatMessages(widget.userName);
    setState(() {
      _chatMessages.addAll(messages.map((msg) => ChatMessage.fromMap(msg)));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();

    if (userMessage.isNotEmpty) {
      final timestamp = DateTime.now().toIso8601String();

      await _dbHelper.addChatMessage({
        'sender': 'user',
        'message': userMessage,
        'timestamp': timestamp,
      }, widget.userName);

      setState(() {
        _chatMessages.add(ChatMessage(sender: 'user', message: userMessage));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      final botReply = await ApiService().fetchChatMessages(userMessage);
      handleTaskOperation(botReply, widget.userName);

      final botMessage = botReply["message"];
      await _dbHelper.addChatMessage({
        'sender': 'bot',
        'message': botMessage,
        'timestamp': DateTime.now().toIso8601String(),
      }, widget.userName);

      setState(() {
        _chatMessages.add(ChatMessage(sender: 'bot', message: botMessage));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = screenWidth * 0.05;

    return Container(
      decoration: darkGradientBackground,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 4),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [
                    //     Colors.white.withOpacity(0.1),
                    //     Colors.black.withOpacity(0.5),
                    //   ],
                    //   begin: Alignment.topCenter,
                    //   end: Alignment.bottomCenter,
                    // ),
                    // color: Colors.white.withOpacity(0.2), // Semi-transparent background
                    ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'OASIS',
                    style: TextStyle(
                      color: darkTextColor,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: contentPadding),
                height: 2,
                color: Colors.white,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _chatMessages.isEmpty
                  ? Center(
                      child: Text(
                        'Chat History Here',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: darkTextColor.withOpacity(0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = _chatMessages[index];
                        final isUser = message.sender == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: isUser
                              ? GlassButton(
                                  blur: 30.0,
                                  opacity: 0.2,
                                  radius: 20.0,
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005,
                                    horizontal: contentPadding,
                                  ),
                                  child: Text(
                                    message.message,
                                    style: TextStyle(
                                      color: darkTextColor,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.005,
                                    horizontal: contentPadding,
                                  ),
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    message.message,
                                    style: TextStyle(
                                      color: darkTextColor,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height *
                    0.03, // Increased bottom padding
                top: MediaQuery.of(context).size.height *
                    0.02, // Added top padding
                left: contentPadding,
                right: contentPadding,
              ),
              child: GlassButton(
                blur: 30.0,
                opacity: 0.2,
                radius: 30.0,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _messageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          hintStyle: TextStyle(
                            color: darkTextColor.withOpacity(0.5),
                            fontSize: screenWidth * 0.04,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: darkTextColor,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: darkPrimaryColor,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: darkTextColor),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
