import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_text_field.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "Profile",
        showBack: false,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            ProfileAvatar(
              imagePath: Assets.imagesLogoNoName,
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
              child: Column(
                children: [
                  ProfileSectionCard(
                    icon: Icons.person,
                    title: l10n.accountSetting,
                    child: Column(
                      children: [
                        ProfileTextField(
                          label: l10n.fullName,
                          value: l10n.yourFullName,
                        ),
                        SizedBox(height: 12.h),
                        ProfileTextField(
                          label: l10n.userName,
                          value: l10n.yourUserName,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ProfileActionButton(
                              text: l10n.female,
                              selected: true,
                            ),
                            ProfileActionButton(
                              text: l10n.male,
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProfileSectionCard(
                    icon: Icons.mail,
                    title: l10n.contactInfo,
                    child: Column(
                      children: [
                        ProfileTextField(
                          label: l10n.email,
                          value: l10n.exampleEmailContact,
                        ),
                        SizedBox(height: 12.h),
                        ProfileTextField(
                          label: l10n.phoneNumber,
                          value: "+20 10 0000 0000",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProfileSectionCard(
                    child: Column(
                      children: [
                        ProfileInfoRow(
                          icon: Icons.language,
                          title: l10n.language,
                          value: l10n.english,
                        ),
                        SizedBox(height: 12.h),
                        ProfileInfoRow(
                          icon: Icons.dark_mode,
                          title: l10n.theme,
                          value: l10n.lightMode,
                        ),
                        SizedBox(height: 12.h),
                        ProfileInfoRow(
                          icon: Icons.notifications,
                          title: l10n.notification,
                          value: l10n.enabled,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProfileSectionCard(
                    child: ProfileInfoRow(
                      icon: Icons.shield,
                      title: l10n.privacyPolicy,
                      value: "",
                      onTap: () {
                        // TODO: Navigate to Privacy Policy screen when implemented
                        // For now, show a placeholder dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.privacyPolicy),
                            content: const Text("Privacy Policy screen coming soon."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProfileSectionCard(
                    child: ProfileInfoRow(
                      icon: Icons.contact_support,
                      title: l10n.helpSupport,
                      value: "",
                      onTap: () {
                        // TODO: Navigate to Help & Support screen when implemented
                        // For now, show a placeholder dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.helpSupport),
                            content: const Text("Help & Support screen coming soon."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ProfileSectionCard(
                    child: ProfileInfoRow(
                      icon: Icons.logout,
                      title: l10n.logOut,
                      value: "",
                      onTap: () {
                        // Show logout confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.logOut),
                            content: const Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Implement actual logout logic
                                  // This should clear user session and navigate to login
                                },
                                child: Text(
                                  l10n.logOut,
                                  style: const TextStyle(color: AppColors.red),
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
          ],
        ),
      ),
    );
  }
}
