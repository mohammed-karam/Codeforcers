import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/code_compiler/views/code_compiler_view.dart';
import 'package:codeforcers/features/problems/widgets/solved_progress_card.dart';
import 'package:codeforcers/features/settings/views/settings_view.dart';
import 'package:codeforcers/features/user_details/manager/cubit/user_info_cubit.dart';
import 'package:codeforcers/features/user_details/widgets/build_date_row.dart';
import 'package:codeforcers/features/user_details/widgets/build_info_tile.dart';
import 'package:codeforcers/features/user_details/widgets/get_rating_color.dart';
import 'package:codeforcers/features/user_rating/views/user_rating_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsViewBody extends StatefulWidget {
  const UserDetailsViewBody({super.key});

  @override
  State<UserDetailsViewBody> createState() => _UserDetailsViewBodyState();
}

class _UserDetailsViewBodyState extends State<UserDetailsViewBody> {
  final TextEditingController _handleController = TextEditingController();

  @override
  initState() {
    super.initState();
            final handle = AppSettings.instance.codeforcesHandle;
    if (handle.isNotEmpty) {
      BlocProvider.of<UserInfoCubit>(context).fetchUserInfo(handle);
    }
  }

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _saveHandle(String raw) async {
    final handle = raw.trim();
    if (handle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Codeforces handle.')),
      );
      return;
    }

    await AppSettings.instance.setCodeforcesHandle(handle);
    if (!mounted) return;
    await BlocProvider.of<UserInfoCubit>(context).fetchUserInfo(handle);
  }

  Future<void> _promptForHandle() async {
    _handleController.text = AppSettings.instance.codeforcesHandle;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Your Codeforces handle',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: _handleController,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(dialogContext).pop(true),
          decoration: InputDecoration(
            labelText: 'Handle',
            hintText: 'e.g. Karam',
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;
    await _saveHandle(_handleController.text);
  }

  String _formatDate(int seconds) {
    if (seconds == 0) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar(
        title: 'User Profile',
        roundedBottom: false,
        actions: [
          IconButton(
            tooltip: 'Code Compiler',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CodeCompilerView(),
                ),
              );
            },
            icon: const Icon(Icons.code_rounded),
          ),
          IconButton(
            tooltip: 'Change handle',
            onPressed: _promptForHandle,
            icon: const Icon(Icons.manage_accounts_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsView()),
              );
            },
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: BlocBuilder<UserInfoCubit, UserInfoState>(
        builder: (context, state) {
          if (state is UserInfoSuccess) {
            Color rankColor = getRatingColor(
              state.userModel.rating,
              state.userModel.maxRating,
            );
            Color maxRankColor = getRatingColor(
              state.userModel.maxRating,
              state.userModel.maxRating,
            );
            return SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    decoration: const BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 120),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                                                                    Text(
                                            '${state.userModel.firstName} ${state.userModel.lastName}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                                                                    Text(
                                            state.userModel.handle,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: rankColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                                                                            color: rankColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              ' ${state.userModel.rank}'
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                                                                color: Colors.white,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                                                                    Text(
                                            '${state.userModel.rating}',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                                                                            color: rankColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                                                            Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Current Rating',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${state.userModel.rating}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: rankColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            state.userModel.rank.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: rankColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Max Rating',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${state.userModel.maxRating}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: maxRankColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            state.userModel.maxRank
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: maxRankColor,
                                            ),
                                          ),
                                        ],
                                      ),

                                      
                                                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const SolvedProgressCard(),
                          const SizedBox(height: 12),

                          Card(
                            elevation: 2,
                            color: Colors.white,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                buildInfoTile(
                                  Icons.public,
                                  'Location',
                                  state.userModel.country,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                buildInfoTile(
                                  Icons.business,
                                  'Organization',
                                  state.userModel.organization,
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                buildInfoTile(
                                  Icons.emoji_events_outlined,
                                  'Contribution',
                                  '${state.userModel.contribution > 0 ? "+${state.userModel.contribution}" : state.userModel.contribution}',
                                ),
                                const Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                buildInfoTile(
                                  Icons.people_outline,
                                  'Friends',
                                  '${state.userModel.friendOfCount} users',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                                                    Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  buildDateRow(
                                    'Registered:',
                                    _formatDate(
                                      state.userModel.registrationTimeSeconds,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  buildDateRow(
                                    'Last Online:',
                                    _formatDate(
                                      state.userModel.lastOnlineTimeSeconds,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                                                    Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF1B3B6F),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Submissions',
                                    style: TextStyle(
                                      color: Color(0xFF1B3B6F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => UserRatingView(
                                          handle: state.userModel.handle,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B3B6F),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Contest History',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: rankColor,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(
                            state.userModel.titlePhoto.isNotEmpty
                                ? state.userModel.titlePhoto
                                : 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                          ),
                                                                                                        onBackgroundImageError: (_, __) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is UserInfoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserInfoFailure) {
            return _failureState(state.errorMessage);
          } else {
            return _handleSetup();
          }
        },
      ),
    );
  }

  
  Widget _handleSetup() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who are you?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter your Codeforces handle and your profile, rating history '
            'and friends load from there.',
            style: TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.border),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F1B3B6F),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.alternate_email_rounded,
                        size: 18,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Codeforces handle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'We only use it to look up your stats.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _handleController,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _saveHandle,
                  decoration: InputDecoration(
                    labelText: 'Handle',
                    hintText: 'e.g. Karam',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _saveHandle(_handleController.text),
                    icon: const Icon(Icons.search_rounded, size: 17),
                    label: const Text(
                      'Load my profile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Saved on this device — change it any time in Settings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _failureState(String message) {
    final handle = AppSettings.instance.codeforcesHandle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_rounded,
              size: 32,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            if (handle.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _saveHandle(handle),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text(
                  'Try again',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: _promptForHandle,
              icon: const Icon(Icons.manage_accounts_rounded, size: 16),
              label: const Text(
                'Change handle',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
