import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../utils/api_service.dart';
import '../../utils/task_handler.dart';
import '../../utils/db_helper.dart';
import '../../conf/glassbutton.dart';
import '../../conf/glassbuttonwhite.dart'; // Import the white theme button
import '../../conf/theme.dart';

// Define global horizontal padding
const double horizontalPadding = 10.0;

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

    // Scroll to the bottom after loading messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();

    if (userMessage.isNotEmpty) {
      final timestamp = DateTime.now().toIso8601String();

      // Add user message
      await _dbHelper.addChatMessage({
        'sender': 'user',
        'message': userMessage,
        'timestamp': timestamp,
      }, widget.userName);

      setState(() {
        _chatMessages.add(ChatMessage(sender: 'user', message: userMessage));
      });

      // Scroll to the bottom after user message is added
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Bot reply
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

      // Scroll to the bottom after bot reply is added
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

  Widget _buildGlassButton({
    required double blur,
    required double opacity,
    required double radius,
    required EdgeInsetsGeometry padding,
    required Widget child,
  }) {
    // Switch between light and dark mode glass button
    return Theme.of(context).brightness == Brightness.dark
        ? GlassButton(
            blur: blur,
            opacity: opacity,
            radius: radius,
            padding: padding,
            child: child,
          )
        : GlassButtonWhiteTheme(
            blur: blur,
            opacity: opacity,
            radius: radius,
            padding: padding,
            child: child,
          );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final textColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      decoration: getGradientBackground(Theme.of(context).brightness),
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              'Oasis',
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          elevation: 1,
          centerTitle: false,
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
                          color: textColor.withOpacity(0.5),
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.005,
                              horizontal: horizontalPadding,
                            ),
                            child: isUser
                                ? _buildGlassButton(
                                    blur: 30.0,
                                    opacity: 0.2,
                                    radius: 20.0,
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    child: Text(
                                      message.message,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      message.message,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.01,
                top: screenHeight * 0.01,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: _buildGlassButton(
                blur: 30.0,
                opacity: 0.2,
                radius: 30.0,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
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
                            color: textColor.withOpacity(0.5),
                            fontSize: screenWidth * 0.04,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.send, color: textColor),
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