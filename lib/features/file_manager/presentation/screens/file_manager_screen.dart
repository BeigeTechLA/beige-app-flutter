import 'package:beige/app/app.dart';
import 'package:beige/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';

import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../app_drawer/screen/drawer_screen.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});

  @override
  ConsumerState<FileManagerScreen> createState() =>
      _FileManagerScreenState();
}

class _FileManagerScreenState
    extends ConsumerState<FileManagerScreen>
    with SingleTickerProviderStateMixin {


  bool isLoading = true;
  bool isGridView = true;

  late TabController _tabController;
  final TextEditingController folderController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  bool loding = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    folderController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context,) {
    return AppScaffold(
        hasAppBar: true,
        drawer: const DrawerScreen(),


        body: SafeArea(
          child: Column(
            children: [
          
              /// 🔝 HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
          
                    /// MENU
                    Builder(
                      builder: (context) =>
                          InkWell(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: SvgPicture.asset(
                              AppAssets.menu,
                              width: 26,
                              height: 26,
                            ),
                          ),
                    ),
          
          
                    const Spacer(),
          
                    /// TITLE
                    Text(
                      "File Manager",
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
          
                    const Spacer(),
          
                  ],
                ),
              ),
          
              /// 🔍 SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
          
                    /// 🔍 Search Container (Full Width)
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: AppRadii.xlAll,
                        ),
                        child: Row(
                          children: [
          
                             SvgPicture.asset(
                            AppAssets.search
          
                          ),
                            const SizedBox(width: 10),
          
                            /// TextField should be Expanded
                           /*  Expanded(
                              child: TextField(

                                decoration: InputDecoration(
                                  hintText: "Search File, User...",
                                   hintStyle: TextStyle(color: AppColors.white38,fontFamily:AppTextStyles.titleMedium ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(AppRadii.lg))
                                  ),
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
          
                    const SizedBox(width: 12),
          
                    /// 📱 Grid Button (Separate)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          loding = !loding;
                        });
                      },
          
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMid,
                          borderRadius: AppRadii.lgAll,
                          /*border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                          ),*/
                          /* boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],*/
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            loding
                                ? AppAssets.grid
                                : AppAssets.list,
          
                          height: 22,
                          width: 22,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
          
              const SizedBox(height: 16),
          
              /// 📂 TABS
              Column(
                children: [
          
                  TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
          
                    /// 👇 Custom Rounded Indicator
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 3,
                        color: AppColors.primary,
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 25),
                    ),
          
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.white,
          
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Outfit",
          
                    ),
          
          
                    tabs: const [
                      Tab(text: "All Files"),
                      Tab(text: "Recent Files"),
                    ],
                  ),
          
                  /// 👇 Full Width Bottom Divider Line
                  Container(
                    height: 2,
                    color: Colors.white12,
                  ),
                ],
              ),
          
              const SizedBox(height: 10),
          
              /// 📄 LIST
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _fileList(),
                    _fileList(),
                  ],
                ),
              ),
          
              /// 👇 Bottom Button
          /*    Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: InkWell(
          
                    onTap: () {
                      showCreateFolderSheet();
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadii.mld),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.black, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Add / Create",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        )


    );
  }

 /* void showCreateFolderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Drag line
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(AppRadii.mld),
                    ),
                  ),
                ),

                /// Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Create Folder",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontFamily: "Unbounded",
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                const Text(
                  "Create new folder for users",
                  style: TextStyle(
                    color: AppColors.white70,
                    fontSize: 12,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w400,
                  ),
                ),


                Divider(
                  color: AppColors.divider,
                  thickness: 0.8,

                ),
                SizedBox(height: 12),
                AppTextField(
                  label: "Folder Name", controller: folderController,),
                const SizedBox(height: 15),
                AppTextField(
                  label: "Category", controller: categoryController,),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style:
                          OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white24),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {

                          },

                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            backgroundColor:
                            const Color(0xFFE8D1AB),
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                          onPressed:

                              () {

                          },
                          child: const Text(
                            "Create Folder",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: "Unbounded",
                              fontWeight:
                              FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }*/

  /// 📁 FILE CARD LIST
  Widget _fileList() {
    if (loding) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return InkWell(
            /*  onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>  PostProductionScreen(),
              ),
            );
          },*/

            onTap: () {

              /* context.pushNamed(
                RouteNames.postProduction,
              );*/
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.portfolioCompactAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Folder Title Row
                  Row(
                    children: [
                      Icon(Icons.folder,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text(
                        "Lana #123456",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(
                            Icons.more_vert, color: AppColors.white),
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        onSelected: (value) {
                          if (value == "open") {
                            print("Open");
                          } else if (value == "view") {
                            print("View Shoot Details");
                          } else if (value == "rename") {
                            print("Rename");
                          } else if (value == "share") {
                            print("Share");
                          } else if (value == "download") {
                            print("Download");
                          } else if (value == "delete") {
                            print("Delete");
                          }
                        },
                        itemBuilder: (context) =>
                        [

                          popupItem("open", Icons.folder_open, "Open"),
                          popupItem("view", Icons.remove_red_eye,
                              "View Shoot Details"),
                          popupItem("rename", Icons.edit, "Rename"),

                          const PopupMenuDivider(),

                          popupItem("share", Icons.share, "Share"),
                          popupItem("download", Icons.download, "Download"),

                          const PopupMenuDivider(),

                          popupItem("delete", Icons.delete, "Delete",
                              isDelete: true),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "02 Files",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary,
                      borderRadius: AppRadii.hugeAll,
                    ),
                    child: const Text(
                      "Corporate Event",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Divider(
                    color: AppColors.divider,
                    thickness: 0.8,

                  ),
                  Row(
                    children: const [
                      CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary,
                          child: Text("DP",
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 16,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                            ),)
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Opened 2 hours ago",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 20,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceMid,
                borderRadius: AppRadii.portfolioCompactAll,
              ),
              child: Row(
                children: const [
                  Icon(Icons.folder, color: AppColors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Lana #123456",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  PopupMenuItem<String> popupItem(String value,
      IconData icon,
      String text, {
        bool isDelete = false,
      }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDelete ? Colors.red : Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDelete ? Colors.red : Colors.white,
              fontFamily: "Outfit",
            ),
          ),
        ],
      ),
    );
  }

}