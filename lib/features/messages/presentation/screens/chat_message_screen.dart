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
import '../../../../shared/widgets/app_filepicker_service.dart';


class ChatMessageScreen extends ConsumerStatefulWidget {
  final String name;
  final String image;

  const ChatMessageScreen({
    super.key,
    required this.name,
    required this.image,
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
                          onTap: () {
                            context.pushNamed(
                              RouteNames.messagesdetils,
                              extra: {
                                "name": widget.name,
                                "image": widget.image,
                              },

                            );
                          },
                          child: CircleAvatar(
                            radius: AppRadii.massive,
                            backgroundColor:
                            AppColors.surfaceVariant,

                            backgroundImage:
                            NetworkImage(widget.image),
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
                            widget.name,

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

                                CircleAvatar(
                                  radius: 14,
                                  backgroundImage:
                                  NetworkImage(widget.image),
                                ),

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
                    top: BorderSide(
                      color: AppColors.dividerDark,
                    ),
                  ),
                ),

                child: SafeArea(
                  top: false,

                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.end,

                    children: [



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
                          ),

                          onSubmitted: (_) {
                            sendMessage();
                          },

                          decoration: InputDecoration(
                            hintText: "Write your message",
                            fillColor: AppColors.black,                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadii.roundAll,
                              borderSide: BorderSide.none,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadii.roundAll,
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadii.roundAll,
                              borderSide: BorderSide.none,
                            ),

                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: AppColors.surface,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25),
                                        ),
                                      ),
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [

                                              /// Camera
                                              _buildAttachmentTile(
                                                icon: Icons.camera_alt,
                                                color: Colors.purple,
                                                title: "Camera",
                                                onTap: () async {

                                                  context.pop();

                                                  final file =
                                                  await AppFilePickerService
                                                      .pickCameraImage();

                                                  if (file != null) {

                                                    setState(() {
                                                      messages.add({
                                                        "text": " Camera Image Sent",
                                                        "isMe": true,
                                                        "time": "Now",
                                                      });
                                                    });
                                                  }
                                                },
                                              ),

                                              /// Gallery
                                              _buildAttachmentTile(
                                                icon: Icons.photo,
                                                color: Colors.blue,
                                                title: "Gallery",
                                                onTap: () async {

                                                  context.pop();

                                                  final file =
                                                  await AppFilePickerService
                                                      .pickGalleryImage();

                                                  if (file != null) {

                                                    setState(() {
                                                      messages.add({
                                                        "text": "🖼 Gallery Image Sent",
                                                        "isMe": true,
                                                        "time": "Now",
                                                      });
                                                    });
                                                  }
                                                },
                                              ),

                                              /// Document
                                              _buildAttachmentTile(
                                                icon: Icons.insert_drive_file,
                                                color: Colors.orange,
                                                title: "Document",
                                                onTap: () async {

                                                  context.pop();

                                                  final file =
                                                  await AppFilePickerService
                                                      .pickDocument();

                                                  if (file != null) {

                                                    setState(() {
                                                      messages.add({
                                                        "text": " Document Sent",
                                                        "isMe": true,
                                                        "time": "Now",
                                                      });
                                                    });
                                                  }
                                                },
                                              ),

                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: SvgPicture.asset(
                                      AppAssets.clipAttachment,
                                      color: AppColors.primary,
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// Microphone Button
                                GestureDetector(
                                  onLongPress: () {
                                    /// Start Recording
                                  },

                                  onLongPressUp: () {
                                    /// Stop Recording & Send Voice
                                  },

                                  child: SvgPicture.asset(
                                    AppAssets.microphone,
                                    color: AppColors.white,
                                    height: 20,
                                    width: 20,
                                  ),
                                ),

                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.gapHSm,

                      Container(
                        height: 50,
                        width: 50,

                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),

                        child: IconButton(
                          onPressed: sendMessage,

                          icon: const Icon(
                            Icons.send_rounded,
                            color: AppColors.onPrimary,
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

  Widget _buildAttachmentTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,

        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            color: color,
            size: 26,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      ),
    );
  }
}