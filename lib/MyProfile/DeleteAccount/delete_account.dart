import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../service/api_endpoints.dart';
import '../../service/api_service.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../app/radii.dart';
import 'delete_account_otp_screen.dart';
class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
 bool isLoading = false;
  String? selectedReason;

  final List<String> reasons = [
    "What's the reason for deleting your account?",
    "Help us understand why you're leaving",
    "I'm not using the app anymore",
    "Others",
  ];


 Future<void> _requestDeleteAccount() async {
   if (selectedReason == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text("Please select a reason"),
         backgroundColor: AppColors.error,
       ),
     );
     return;
   }

   setState(() => isLoading = true);

   debugPrint("🟢 DELETE ACCOUNT API CALL STARTED");

   try {
     final response = await ApiService().postData(
       ApiEndpoints.user_delete_account,
       {
         "delete_reason": selectedReason,
       },
     );

     debugPrint("🟡 API RESPONSE: $response");

     if (response != null && response['error'] == false) {
       debugPrint("✅ DELETE REQUEST SUCCESS");

       /// 👉 OTP SCREEN
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (_) => const DeleteAccountOtpScreen(),
         ),
       );
     } else {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text(response['message'] ?? "Something went wrong"),
           backgroundColor: AppColors.error,
         ),
       );
     }
   } catch (e) {
     debugPrint("🚨 DELETE ACCOUNT ERROR: $e");
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text("Server error, please try again"),
         backgroundColor: AppColors.error,
       ),
     );
   } finally {
     setState(() => isLoading = false);
   }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
   body: SafeArea(
       child:Padding(
         padding:  EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,

           children: [

             /// 🔙 BACK BUTTON
             InkWell(
               onTap: () => Navigator.pop(context),
               child:  SvgPicture.asset(
                 "assets/svg/back.svg",
                 height: 24,
                 color: AppColors.white,
               )
             ),

             const SizedBox(height: 16),

             /// 🏷 TITLE
             Text(
               "Delete Account",
               style: TextStyle(
                 fontFamily: AppTextStyles.fontFamilyDisplay,
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
                 color: AppColors.white,
               ),
             ),

              SizedBox(height: 20),


             Text(
               "This action will permanently delete your account and all associated data. If you need help or have questions, please contact us at support@beige.com",
               style: TextStyle(
                 fontSize: 14,
                 color: AppColors.white70,
                 height: 1.5,
                 fontWeight: FontWeight.w400,
                 fontFamily: AppTextStyles.fontFamilyBody
               ),
             ),

             SizedBox(height: 20),
             Container(
               padding: EdgeInsets.all(20),

               decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadii.lgAll),

               child: Column(
                 children: [
                   Row(
                     children: [
                       Text("Why do you wish to leave Beige?",
                         style: TextStyle(
                             fontSize: 14,
                             color: AppColors.white,
                             fontWeight: FontWeight.w500,
                             fontFamily: AppTextStyles.fontFamilyBody
                         ),),
                     ],
                   ),
                     const SizedBox(height: 8),

                    Text(
                     "Please let us know the reason for deleting your account.",
                     style: TextStyle(
                       fontSize: 12,
                       color: AppColors.white70,
                       fontFamily: AppTextStyles.fontFamilyBody,
                       fontWeight: FontWeight.w400

                     ),
                   ),

                   ...reasons.map((reason) {
                     return _buildReasonOption(reason);
                   }).toList(),

                 ],
               ),
             )
           ],
         ),
       )
   ),
      bottomNavigationBar:
      Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _requestDeleteAccount,


            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.xlAll,
              ),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamilyDisplay,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textHeading,
              ),
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildReasonOption(String reason) {
    final bool isSelected = selectedReason == reason;

    return InkWell(
      onTap: () {
        setState(() {
          selectedReason = reason;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔘 CUSTOM RADIO
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.white70,

                ),
              ),
              child: isSelected
                  ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                ),
              )
                  : null,
            ),

            const SizedBox(width: 14),

            /// 📝 TEXT
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppTextStyles.fontFamilyBody,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
