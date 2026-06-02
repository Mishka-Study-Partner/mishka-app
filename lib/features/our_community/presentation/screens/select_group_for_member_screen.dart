import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_dialogs.dart';
import '../widgets/group_list_item_card.dart';

class SelectGroupForMemberScreen extends StatefulWidget {
  const SelectGroupForMemberScreen({
    super.key,
    required this.community,
    required this.memberName,
    required this.repository,
  });

  final CommunityModel community;
  final String memberName;
  final CommunityRepository repository;

  @override
  State<SelectGroupForMemberScreen> createState() =>
      _SelectGroupForMemberScreenState();
}

class _SelectGroupForMemberScreenState extends State<SelectGroupForMemberScreen> {
  List<CommunityGroupModel> _groups = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final groups = await widget.repository.loadChannels(widget.community.id);
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: '${widget.community.name} Groups',
        topTitle: '${widget.community.name} Groups',
        showBack: true,
        showBottomBar: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Select a group for ${widget.memberName}',
              style: CommunityStyles.sectionLabel,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _groups.length,
                    itemBuilder: (context, index) {
                        final group = _groups[index];
                        return GroupListItemCard(
                          group: group,
                          onTap: () async {
                            Navigator.pop(context);
                            await showCommunitySuccessDialog(
                              context,
                              message: 'Member successfully added to the group.',
                            );
                          },
                        );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
