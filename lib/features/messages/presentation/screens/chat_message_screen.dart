import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/route_names.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../shared/widgets/app_filepicker_service.dart';


class ChatMessageScreen extends ConsumerStatefulWidget {
  final String roomId;
  final int chatId;

  const ChatMessageScreen({
    super.key, required this.roomId, required this.chatId,

  });

  @override
  ConsumerState<ChatMessageScreen> createState() =>
      _ChatMessageScreenState();
}

class _ChatMessageScreenState
    extends ConsumerState<ChatMessageScreen> {

  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;



  // ✅ Socket
  final _socket = SocketService();
  late StreamSubscription _messageSub;
  late StreamSubscription _typingSub;
  bool _isTyping = false;
  Timer? _typingTimer;

  final List<Map<String, dynamic>> messages = [
    {
      "text": "Hello! Angela Kia 👋",
      "isMe": true,
      "time": "09:25 AM",
    },
    {
      "text": "Hello Harsh, How are you?",
      "isMe": false,
      "time": "09:26 AM",
    },
    {
      "text": "I am good 😄",
      "isMe": true,
      "time": "09:27 AM",
    },
    {
      "text": "Great 👍",
      "isMe": false,
      "time": "09:28 AM",
    },
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {

    _focusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void sendMessage() {

    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {

      messages.add({
        "text": text,
        "isMe": true,
        "time": "Now",
      });
    });

    _messageController.clear();

    Future.microtask(() {

      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {

        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(95),

          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceMid,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadii.round),
                bottomRight: Radius.circular(AppRadii.round),
              ),
            ),

            child: SafeArea(
              bottom: false,

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),

                child: Row(
                  children: [

                    /// Back Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Container(
                        height: AppSpacing.massive,
                        width: AppSpacing.massive,

                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadii.fullAll,
                        ),

                        child: Center(
                          child: SvgPicture.asset(
                            AppAssets.back,
                            height: AppSpacing.xxl,
                            width: AppSpacing.xxl,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.gapHMd,

                    /// Profile Image
                    Stack(
                      children: [

                        GestureDetector(
                       /*   onTap: () {
                            context.pushNamed(
                              RouteNames.messagesdetils,
                              extra: {
                                "name": widget.name,
                                "image": widget.image,
                              },

                            );
                          },*/
                          child: CircleAvatar(
                            radius: AppRadii.massive,
                            backgroundColor:
                            AppColors.surfaceVariant,

                         /*   backgroundImage:
                            NetworkImage(widget.image),*/
                          ),
                        ),

                        Positioned(
                          bottom: 2,
                          right: 2,

                          child: Container(
                            height: 14,
                            width: 14,

                            decoration: BoxDecoration(
                              color: AppColors.online,
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: AppColors.surface,
                                width: AppSpacing.xxxs,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.gapHMd,

                    /// Name + Status
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        crossAxisAlignment:CrossAxisAlignment.start,

                        children: [

                          Text(
                          "  widget.name,",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style:
                            AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            "Active now",

                            style:
                            AppTextStyles.bodySmall.copyWith(
                              color: AppColors.online,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Call Button
                /*    Container(
                      height: 42,
                      width: 42,

                      decoration: BoxDecoration(
                        color:
                        AppColors.primary.withOpacity(.12),
                        borderRadius: AppRadii.fullAll,
                      ),

                      child: const Icon(
                        Icons.call_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),

                    AppSpacing.gapHSm,

                    /// Video Button
                    Container(
                      height: 42,
                      width: 42,

                      decoration: BoxDecoration(
                        color:
                        AppColors.primary.withOpacity(.12),
                        borderRadius: AppRadii.fullAll,
                      ),

                      child: const Icon(
                        Icons.videocam_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,

                  physics:
                  const BouncingScrollPhysics(),

                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: AppSpacing.lg,
                  ),

                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final msg = messages[index];
                    final bool isMe = msg["isMe"];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.md,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,

                        children: [

                          Row(
                            mainAxisAlignment:
                            isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,

                            crossAxisAlignment:
                            CrossAxisAlignment.end,

                            children: [

                              if (!isMe) ...[

                           /*     CircleAvatar(
                                  radius: 14,
                                  backgroundImage:
                                  NetworkImage(widget.image),
                                ),
*/
                                AppSpacing.gapHSm,
                              ],

                              Flexible(
                                child: Container(
                                  constraints:
                                  BoxConstraints(
                                    maxWidth:
                                    MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.72,
                                  ),

                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal:
                                    AppSpacing.mld,
                                    vertical:
                                    AppSpacing.md,
                                  ),

                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : AppColors.surfaceVariant,

                                    borderRadius:
                                    BorderRadius.only(

                                      topLeft:
                                      const Radius.circular(
                                        AppRadii.xxxl,
                                      ),

                                      topRight:
                                      const Radius.circular(
                                        AppRadii.xxxl,
                                      ),

                                      bottomLeft:
                                      Radius.circular(
                                        isMe
                                            ? AppRadii.xxxl
                                            : AppRadii.xs,
                                      ),

                                      bottomRight:
                                      Radius.circular(
                                        isMe
                                            ? AppRadii.xs
                                            : AppRadii.xxxl,
                                      ),
                                    ),
                                  ),

                                  child: Text(
                                    msg["text"],

                                    style:
                                    AppTextStyles.bodyMedium.copyWith(
                                      color: isMe
                                          ? AppColors.onPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Padding(
                            padding: EdgeInsets.only(
                              top: AppSpacing.xxs,

                              left: isMe ? 0 : 38,

                              right: isMe ? 6 : 0,
                            ),

                            child: Text(
                              msg["time"],

                              style:
                              AppTextStyles.caption.copyWith(
                                color:
                                AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMid,
                  border: Border(
                    top: BorderSide(color: AppColors.dividerDark),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      /// Attachment Icon (left of field)
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppColors.surfaceStats,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xl,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36, height: 4,
                                      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                                      decoration: BoxDecoration(
                                        color: AppColors.white24,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    GridView.count(
                                      crossAxisCount: 3,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      mainAxisSpacing: 20,
                                      crossAxisSpacing: AppSpacing.sm,
                                      children: [
                                        _buildWAItem(
                                          icon: Icons.camera_alt_rounded,
                                          color: const Color(0xFF7C3AED),
                                          label: "Camera",
                                          onTap: () async {
                                            context.pop();
                                            final file = await AppFilePickerService.pickCameraImage();
                                            if (file != null) setState(() {
                                              messages.add({"text": "Camera Image Sent", "isMe": true, "time": "Now"});
                                            });
                                          },
                                        ),
                                        _buildWAItem(
                                          icon: Icons.photo_rounded,
                                          color: AppColors.warning,
                                          label: "Gallery",
                                          onTap: () async {
                                            context.pop();
                                            final file = await AppFilePickerService.pickGalleryImage();
                                            if (file != null) setState(() {
                                              messages.add({"text": "Gallery Image Sent", "isMe": true, "time": "Now"});
                                            });
                                          },
                                        ),
                                        _buildWAItem(
                                          icon: Icons.insert_drive_file_rounded,
                                          color: AppColors.info,
                                          label: "Document",
                                          onTap: () async {
                                            context.pop();
                                            final file = await AppFilePickerService.pickDocument();
                                            if (file != null) setState(() {
                                              messages.add({"text": "Document Sent", "isMe": true, "time": "Now"});
                                            });
                                          },
                                        ),
                                        _buildWAItem(
                                          icon: Icons.mic_rounded,
                                          color: AppColors.online,
                                          label: "Audio",
                                          onTap: () { context.pop(); },
                                        ),
                                        _buildWAItem(
                                          icon: Icons.location_on_rounded,
                                          color: AppColors.error,
                                          label: "Location",
                                          onTap: () { context.pop(); },
                                        ),
                                        _buildWAItem(
                                          icon: Icons.person_rounded,
                                          color: AppColors.mapBlue,
                                          label: "Contact",
                                          onTap: () { context.pop(); },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: AppSpacing.sm,
                            bottom: 12,
                          ),
                          child: SvgPicture.asset(
                            AppAssets.clipAttachment,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textSecondary,
                              BlendMode.srcIn,
                            ),
                            height: 22,
                            width: 22,
                          ),
                        ),
                      ),

                      /// Text Field (pill shaped, icons inside suffix)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: AppRadii.roundAll,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [

                              /// Text Input
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  textInputAction: TextInputAction.send,
                                  minLines: 1,
                                  maxLines: 5,
                                  cursorColor: AppColors.primary,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontFamily: AppTextStyles.fontFamilyBody,
                                  ),
                                  onSubmitted: (_) => sendMessage(),
                                  decoration: InputDecoration(
                                    hintText: "Write your message",
                                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontFamily: AppTextStyles.fontFamilyBody,
                                    ),
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 12,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),

                              /// Right Icons inside pill
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                  bottom: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [

                                    /// Mic Icon
                                    GestureDetector(
                                      onLongPress: () { /* Start recording */ },
                                      onLongPressUp: () { /* Stop & send */ },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: SvgPicture.asset(
                                          AppAssets.microphone,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.textSecondary,
                                            BlendMode.srcIn,
                                          ),
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// Send Button
                      Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: AppColors.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ======================
  /// Attachment Tile Widget
  /// ======================

  Widget _buildWAItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}