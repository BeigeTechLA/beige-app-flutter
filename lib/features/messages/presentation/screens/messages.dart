  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:flutter_svg/flutter_svg.dart';
  import 'package:go_router/go_router.dart';

  import '../../../../app/assets.dart';
  import '../../../../app/colors.dart';
  import '../../../../app/radii.dart';
  import '../../../../app/route_names.dart';
  import '../../../../app/spacing.dart';
  import '../../../../app/text_styles.dart';
  import '../../../../core/utils/date_time_utils.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../app_drawer/screen/drawer_screen.dart';
import '../providers/messages_notifier.dart';

  class Messages extends ConsumerStatefulWidget {
    const Messages({super.key});

    @override
    ConsumerState<Messages> createState() =>
        _MessagesState();
  }

  class _MessagesState extends ConsumerState<Messages> {


    final List<Map<String, dynamic>> chats = [
      {
        "name": "Angela Kid",
        "message": "Hey! How’s it going?",
        "time": "04:04 AM",
       /* "image":
        "https://i.pravatar.cc/150?img=1",*/
        "count": "3",
      },
      {
        "name": "Connor Frazier",
        "message":
        "What kind of music do you like?",
        "time": "08:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=2",
        "count": "1",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Timothy Steele",
        "message":
        "Hi Tina. How’s your night going?",
        "time": "04:58 PM",
        "image":
        "https://i.pravatar.cc/150?img=3",
        "count": "",
      },
      {
        "name": "Josephine Gordon",
        "message": "Sounds good to me!",
        "time": "11:33 PM",
        "image":
        "https://i.pravatar.cc/150?img=4",
        "count": "",
      },
    ];

    int selectedTab = 0;

    final List<String> tabs = [
      "All",
      "Shoots",
      "Admin",
    ];

    @override
    Widget build(BuildContext context) {
      final roomsState = ref.watch(roomsNotifierProvider);

      final isLoading = roomsState.status == RoomsStatus.loading;

      return Scaffold(


        drawer: const DrawerScreen(),

        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,

          title: Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.base,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [

                /// MENU ICON
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(
                            context,
                          ).openDrawer();
                        },
                        icon: SvgPicture.asset(
                          AppAssets.menu,
                          height: 24,
                          width: 24,
                        ),
                      );
                    },
                  ),
                ),

                /// TITLE
                Center(
                  child: Text(
                    "Message",
                    style:
                    AppTextStyles.titleMedium
                        .copyWith(
                      color: AppColors.white,
                      fontFamily:
                      AppAssets.fontUnbounded,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Column(
                children: [

                  /// TOP TABS
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                      AppRadii.xlAll,
                    ),
                    child: Row(
                      children: List.generate(
                        tabs.length,
                            (index) {
                          final isSelected =
                              selectedTab == index;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTab =
                                      index;
                                });
                              },
                              child: AnimatedContainer(
                                duration:
                                const Duration(
                                  milliseconds: 250,
                                ),
                                alignment:
                                Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors
                                      .primary
                                      : Colors
                                      .transparent,
                                  borderRadius:
                                  AppRadii.lgAll,
                                ),
                                child: Text(
                                  tabs[index],
                                  style:
                                  AppTextStyles
                                      .bodyMedium
                                      .copyWith(
                                    color: isSelected
                                        ? AppColors
                                        .black
                                        : AppColors
                                        .white,
                                    fontWeight: FontWeight
                                        .w500,
                                    fontFamily: AppTextStyles.fontFamilyBody,

                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  AppSpacing.verticalBase,

                  /// SEARCH
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadii.lgAll,
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadii.lgAll,
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadii.lgAll,
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Search Creator, Host...",
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              fontFamily: AppTextStyles.fontFamilyBody,
                              color: AppColors.white54,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                AppAssets.search,
                                height: 20,
                                width: 20,
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 45,
                              minHeight: 45,
                            ),
                          ),
                        ),
                      ),

                      AppSpacing.gapHSm,

                      /// ADD BUTTON
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                          AppRadii.lgAll,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.verticalXl,

                  /// CHAT LIST
                  Expanded(
                    child: roomsState.rooms.isEmpty
                  ? const Center(
                  child: Text(
                    "No Chats Found",
                    style: TextStyle(color: Colors.white),
                  ),
      )
          :ListView.separated(
                      itemCount: roomsState.rooms.length,
                      separatorBuilder:
                          (context, index) =>
                      const SizedBox(
                        height: 18,
                      ),
                      itemBuilder: (context, index) {
                        final room = roomsState.rooms[index];
                        final unreadCount = room.totalUnreadCount;
                        final profileImage = room.clientSnapshot?.profileImage;
                        final hasImage = profileImage != null && profileImage.isNotEmpty;

                        return GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              RouteNames.chatmessage,
                              extra: {
                                // "name": room.resolvedDisplayName,
                                "roomId": room.id,
                                "chatId": room.chatId,
                              },
                            );
                          },
                          child: Row(
                            children: [
                              /// PROFILE AVATAR
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.surface,
                                    backgroundImage: hasImage
                                        ? NetworkImage(profileImage)
                                        : null,
                                    child: !hasImage
                                        ? Text(
                                      room.resolvedDisplayName.isNotEmpty
                                          ? room.resolvedDisplayName[0].toUpperCase()
                                          : '?',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                        : null,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              AppSpacing.gapHBase,

                              /// CHAT INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            room.resolvedDisplayName,
                                            style: AppTextStyles.bodyLarge.copyWith(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppTextStyles.fontFamilyBody,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          DateTimeUtils.formatTime(room.updatedAt),
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.white38,
                                            fontFamily: AppTextStyles.fontFamilyBody,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      room.lastMessage != null ? "Tap to view message" : "No messages yet",
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.white70,
                                        fontFamily: AppTextStyles.fontFamilyBody,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading) const AppLoader(),
          ],

        ),
      );
    }
  }