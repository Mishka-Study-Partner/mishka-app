import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class StudyWithFriendsScreen extends StatelessWidget {
  const StudyWithFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.studyWithYourFriends,
        topTitle: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: 18.h),
            Text(
              l10n.studyWithYourFriends,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 22.h),
            _StudyFriendOptionCard(
              title: l10n.createNewLink,
              icon: Icons.link,
              onTap: () => _showCreateLinkDialog(context, l10n, withPassword: false),
            ),
            SizedBox(height: 14.h),
            _StudyFriendOptionCard(
              title: l10n.createLinkAndPassword,
              icon: Icons.link,
              onTap: () => _showCreateLinkDialog(context, l10n, withPassword: true),
            ),
            const Spacer(),
            const ScreenEndSpacer(),
          ],
        ),
      ),
    );
  }

  void _showCreateLinkDialog(
    BuildContext context,
    AppLocalizations l10n, {
    required bool withPassword,
  }) {
    final passwordController = TextEditingController();
    final generatedLink = 'https://mishka.study/${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.mainGold),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    withPassword ? l10n.createLinkAndPassword : l10n.createNewLink,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  l10n.yourStudyLink,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.screenBackground,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          generatedLink,
                          style: TextStyle(
                            fontFamily: 'Pridi',
                            fontSize: 11.sp,
                            color: AppColors.blue,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: generatedLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.linkCopied)),
                          );
                        },
                        child: Icon(Icons.copy, size: 18.w, color: AppColors.mainGold),
                      ),
                    ],
                  ),
                ),

                if (withPassword) ...[
                  SizedBox(height: 16.h),
                  Text(
                    l10n.password,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 42.h,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(fontFamily: 'Pridi', fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: l10n.enterPassword,
                        hintStyle: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.stroke),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.mainGold),
                        ),
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: generatedLink));
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.linkCopiedAndReady)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.copyAndShare,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              color: AppColors.white,
                              fontSize: 13.sp,
                              height: 1.0,
                            ),
                            strutStyle: StrutStyle(
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.4,
                              forceStrutHeight: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: SizedBox(
                        height: 42.h,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.stroke),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontFamily: 'Pridi',
                              color: AppColors.mainDark,
                              fontSize: 13.sp,
                              height: 1.0,
                            ),
                            strutStyle: StrutStyle(
                              fontFamily: 'Pridi',
                              fontSize: 13.sp,
                              height: 1.4,
                              forceStrutHeight: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudyFriendOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _StudyFriendOptionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.mainGold.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.mainGold),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18.w, color: AppColors.mainGold),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.w, color: AppColors.mainDark),
            ],
          ),
        ),
      ),
    );
  }
}
