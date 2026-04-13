import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../bloc/chat_bloc.dart';
import '../../domain/entities/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _previousMessageCount = 0;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // reverse:true nên 0 = cuối cùng
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(ChatStarted()),
      child: BlocListener<ChatBloc, ChatState>(
        listenWhen: (prev, curr) => curr.messages.length != prev.messages.length,
        listener: (context, state) {
          _scrollToBottom();
        },
        child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hỗ trợ khách hàng',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                   Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Trực tuyến',
                    style: TextStyle(fontSize: 11.sp, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.status == ChatStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ChatStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                          SizedBox(height: 16.h),
                          Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                          TextButton(
                            onPressed: () => context.read<ChatBloc>().add(ChatStarted()),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Bắt đầu trò chuyện với chúng tôi',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    reverse: true, // Hiển thị tin nhắn mới nhất ở dưới
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderType == 'User';
                      
                      return _MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildInputArea() {
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = _messageController.text.trim();
                      if (text.isNotEmpty) {
                        context.read<ChatBloc>().add(ChatMessageSent(text));
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14.r,
                  backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                  child: Icon(Icons.support_agent, size: 16.sp, color: const Color(0xFF6C63FF)),
                ),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF6C63FF) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                      bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: isMe ? 0 : 40.w, right: isMe ? 4.w : 0),
            child: Text(
              DateFormat('HH:mm').format(message.createdAt),
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
