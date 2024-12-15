import 'dart:async';
import 'package:flutter/material.dart';
import '/models/chat_message.dart';
import '/utils/api_service.dart';
import '/utils/task_handler.dart';
import '/utils/db_helper.dart';
import '/conf/theme.dart';
import '/conf/glassbutton.dart';
import '/conf/frostedglass.dart'; // Importing Glassmorphism widget

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

  bool _isdoodling = false;
  String _dots = '';
  double _opacity = 0.5;
  Timer? _dotsTimer;
  Timer? _opacityTimer;

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
  }

  @override
  void dispose() {
    _dotsTimer?.cancel();
    _opacityTimer?.cancel();
    super.dispose();
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

  void _startdoodlingAnimation() {
    _isdoodling = true;
    _dots = ''; // Reset dots

    // Animate dots
    _dotsTimer = Timer.periodic(Duration(milliseconds: 700), (timer) {
      setState(() {
        if (_dots.length < 3) {
          _dots += '.';
        } else {
          _dots = '';
        }
      });
    });

    // Animate fading
    _opacityTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      setState(() {
        _opacity = _opacity == 0.5 ? 0.05 : 0.5;
      });
    });
  }

  void _stopdoodlingAnimation() {
    _dotsTimer?.cancel();
    _opacityTimer?.cancel();
    _isdoodling = false;
    _dots = '';
    _opacity = 0.5;
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();

    if (userMessage.isNotEmpty) {
      final timestamp = DateTime.now().toIso8601String();

      // Save user message to the database
      await _dbHelper.addChatMessage({
        'sender': 'user',
        'message': userMessage,
        'timestamp': timestamp,
      }, widget.userName);

      // Add user message to the chat list
      setState(() {
        _chatMessages.add(ChatMessage(sender: 'user', message: userMessage));
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Clear the message input
      _messageController.clear();

      setState(() {
        _chatMessages.add(ChatMessage(sender: 'bot', message: 'doodling...'));
        _startdoodlingAnimation();
      });

      // Fetch the bot reply with a delay
      final botReply = await Future.delayed(
        Duration(seconds: 5),
        () => ApiService().fetchChatMessages(userMessage),
      );

      // Remove "doodling..." and add the bot's actual reply
      setState(() {
        _stopdoodlingAnimation();
        _chatMessages.removeWhere((msg) => msg.sender == 'bot' && msg.message == 'doodling...');
        _chatMessages.add(ChatMessage(sender: 'bot', message: botReply["message"]));
      });

      // Save the bot's reply to the database
      await _dbHelper.addChatMessage({
        'sender': 'bot',
        'message': botReply["message"],
        'timestamp': DateTime.now().toIso8601String(),
      }, widget.userName);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
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
    final screenHeight = MediaQuery.of(context).size.height;

    final contentPadding = screenWidth * 0.05;

    return Container(
      decoration: darkGradientBackground,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.08),
          child: Glassmorphism(
            blur: 11.0,
            opacity: 0.3,
            radius: 0.0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'OASIS',
                      style: TextStyle(
                        color: darkTextColor,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                                    vertical: screenHeight * 0.005,
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
                              : (message.message == 'doodling...'
                                  ? AnimatedOpacity(
                                      opacity: _opacity,
                                      duration: Duration(milliseconds: 1000),
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                          vertical: screenHeight * 0.005,
                                          horizontal: contentPadding,
                                        ),
                                        padding:
                                            EdgeInsets.all(screenWidth * 0.03),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          'doodling$_dots',
                                          style: TextStyle(
                                            color: darkTextColor,
                                            fontSize: screenWidth * 0.04,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.005,
                                        horizontal: contentPadding,
                                      ),
                                      padding:
                                          EdgeInsets.all(screenWidth * 0.03),
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
                                    )),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.03,
                top: screenHeight * 0.02,
                left: contentPadding,
                right: contentPadding,
              ),
              child: GlassButton(
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