import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rafiq/core/network/api_client.dart';
import 'package:rafiq/core/ui/appbar.dart';
import 'package:rafiq/features/chat%20ai/data/datasource/ai_chat_remote_datasource.dart';
import 'package:rafiq/features/chat%20ai/models/chat_model.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/chat_cubit.dart';
import 'package:rafiq/features/chat%20ai/presentation/cubit/chat_state.dart';
import 'package:rafiq/features/chat%20ai/repository/ai_chat_repository.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        margin: EdgeInsetsDirectional.only(end: 6.w),
        decoration: BoxDecoration(
          color: isListening ? Colors.red.withValues(alpha:0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: isListening ? Colors.red : Colors.grey.shade600,
          size: 22.sp,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final String? time;
  final bool? isWatched;
  final File? image;

  ChatMessage({
    required this.text,
    required this.isBot,
    this.time,
    this.isWatched,
    this.image,
  });

  factory ChatMessage.fromModel(ChatMessageModel model) {
    return ChatMessage(
      text: model.text,
      isBot: model.isBot,
      isWatched: !model.isBot,
      time: model.createdAt != null ? _formatTime(model.createdAt!) : null,
    );
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'مساءً' : 'صباحاً';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $suffix';
  }
}

class ChatAIView extends StatefulWidget {
  const ChatAIView({super.key});

  @override
  State<ChatAIView> createState() => _ChatAIViewState();
}

class _ChatAIViewState extends State<ChatAIView> {
  late final ChatCubit _cubit;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  final List<ChatMessage> _localAttachmentMessages = [];

  @override
  void initState() {
    super.initState();
    _cubit = ChatCubit(
      AiChatRepository(AiChatRemoteDataSource(createApiService())),
    )..initialize();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  List<ChatMessage> _buildMessages(ChatState state) {
    final apiMessages = switch (state) {
      ChatLoaded(:final messages) => messages.map(ChatMessage.fromModel).toList(),
      ChatError(:final messages) => messages.map(ChatMessage.fromModel).toList(),
      _ => <ChatMessage>[],
    };
    return [...apiMessages, ..._localAttachmentMessages];
  }

  bool _isSending(ChatState state) => state is ChatLoaded && state.isSending;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending(_cubit.state)) return;
    _controller.clear();
    _cubit.sendQuestion(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 300,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (mounted) {
      setState(() {
        _localAttachmentMessages.add(
          ChatMessage(text: '', isBot: false, image: File(image.path)),
        );
      });
    }
    if (mounted) Navigator.pop(context);
    _scrollToBottom();
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    if (mounted) {
      setState(() {
        _localAttachmentMessages.add(
          ChatMessage(text: '', isBot: false, image: File(image.path)),
        );
      });
    }
    if (mounted) Navigator.pop(context);
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result == null) return;
    final fileName = result.files.single.name;
    if (mounted) {
      setState(() {
        _localAttachmentMessages.add(
          ChatMessage(text: '📎 $fileName', isBot: false),
        );
      });
    }
    if (mounted) Navigator.pop(context);
    _scrollToBottom();
  }

  Future<void> _listen() async {
    if (!_speechAvailable) {
      await _initSpeech();
      return;
    }

    if (!_isListening) {
      if (mounted) setState(() => _isListening = true);
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: 'ar_EG',
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
        onResult: (result) {
          if (mounted) {
            setState(() {
              _controller.text = result.recognizedWords;
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            });
          }
        },
      );
    } else {
      if (mounted) setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xff1565C0),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xff1565C0),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12.w,
                    height: 12.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'رفيق يكتب...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xff1565C0),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xff1565C0),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: Text(
                msg.text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(ChatMessage msg) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xffE8F2FC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (msg.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        msg.image!,
                        width: 220.w,
                        height: 220.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (msg.image != null && msg.text.isNotEmpty) SizedBox(height: 10.h),
                  if (msg.text.isNotEmpty)
                    Text(
                      msg.text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: const Color(0xff1A1A1A),
                        fontSize: 14.sp,
                        height: 1.7,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  SizedBox(height: 6.h),
                  if (msg.isWatched == true)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تمت مشاهدته',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.done_all_rounded, size: 16.sp, color: const Color(0xff1565C0)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xffE8F2FC),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.person_outline, color: const Color(0xff1565C0), size: 24.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDivider(String time) {
    final hour = DateTime.now().hour;
    final isMorning = hour >= 6 && hour < 18;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isMorning ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    color: isMorning ? Colors.orange : Colors.indigo,
                    size: 15.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Divider(thickness: 1, color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildAttachItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 58.w,
          height: 58.w,
          decoration: BoxDecoration(
            color: const Color(0xffE8F2FC),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Icon(icon, color: const Color(0xff1565C0), size: 28.sp),
        ),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildInputBar(bool isSending) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: isSending ? null : _sendMessage,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isSending ? Colors.grey : const Color(0xff1565C0),
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22.sp),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffF6F7FB),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                        ),
                        builder: (context) => Container(
                          padding: EdgeInsets.all(20.w),
                          height: 180.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: _buildAttachItem(icon: Icons.image_rounded, label: 'صور'),
                              ),
                              GestureDetector(
                                onTap: _pickFile,
                                child: _buildAttachItem(
                                  icon: Icons.insert_drive_file_rounded,
                                  label: 'ملف',
                                ),
                              ),
                              GestureDetector(
                                onTap: _openCamera,
                                child: _buildAttachItem(icon: Icons.camera_alt_rounded, label: 'كاميرا'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(start: 12.w),
                      child: Icon(Icons.attach_file_rounded, color: Colors.grey.shade600, size: 22.sp),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      cursorColor: const Color(0xff1565C0),
                      minLines: 1,
                      maxLines: 4,
                      enabled: !isSending,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'اكتب رسالتك...',
                        hintTextDirection: TextDirection.rtl,
                        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  MicButton(isListening: _isListening, onTap: _listen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocProvider.value(
        value: _cubit,
        child: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            _scrollToBottom();
          },
          builder: (context, state) {
            if (state is ChatLoading || state is ChatInitial) {
              return Scaffold(
                appBar: const CustomAppBar(title: 'الشات الذكى'),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final messages = _buildMessages(state);
            final isSending = _isSending(state);

            return Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: CustomAppBar(
                title: 'الشات الذكى',
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF1564BF)),
                    onSelected: (value) {
                      if (value == 'new_session') {
                        _cubit.initialize();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'new_session',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('محادثة جديدة', style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13)),
                            SizedBox(width: 8),
                            Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xff1565C0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: messages.isEmpty
                        ? Center(
                            child: Text(
                              'ابدأ محادثتك مع المرشد الأكاديمي',
                              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                            itemCount: messages.length + (isSending ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return _buildTypingIndicator();
                              }
                              final msg = messages[index];
                              if (msg.time != null) {
                                return Column(
                                  children: [
                                    _buildTimeDivider(msg.time!),
                                    msg.isBot ? _buildBotMessage(msg) : _buildUserMessage(msg),
                                  ],
                                );
                              }
                              return msg.isBot ? _buildBotMessage(msg) : _buildUserMessage(msg);
                            },
                          ),
                  ),
                  _buildInputBar(isSending),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _speech.stop();
    _cubit.close();
    super.dispose();
  }
}
