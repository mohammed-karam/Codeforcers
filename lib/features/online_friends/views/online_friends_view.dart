import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/utils/api_service.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/online_friends/data/repo/online_friends_repo_impl.dart';
import 'package:codeforcers/features/online_friends/manager/online_friends_cubit/online_friends_cubit.dart';
import 'package:codeforcers/features/online_friends/widgets/online_friends_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnlineFriendsView extends StatefulWidget {
  const OnlineFriendsView({super.key, this.cubit});

      final OnlineFriendsCubit? cubit;

  @override
  State<OnlineFriendsView> createState() => _OnlineFriendsViewState();
}

class _OnlineFriendsViewState extends State<OnlineFriendsView> {
  OnlineFriendsCubit? _ownedCubit;

    String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.cubit == null) {
      _ownedCubit = OnlineFriendsCubit(
        OnlineFriendsRepoImpl(apiService: Api()),
      );
    }
  }

  @override
  void dispose() {
    _ownedCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit ?? _ownedCubit!;
    return BlocProvider<OnlineFriendsCubit>.value(
      value: cubit,
      child: BlocBuilder<OnlineFriendsCubit, OnlineFriendsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Online Codeforces Friends',
              subtitle: _subtitleFor(state),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: cubit.getOnlineFriends,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: OnlineFriendsViewBody(
              query: _query,
              onQueryChanged: (value) => setState(() => _query = value),
            ),
          );
        },
      ),
    );
  }

  String _subtitleFor(OnlineFriendsState state) {
    if (state is OnlineFriendsLoading) return 'Checking who is online...';
    if (state is OnlineFriendsFailure) return 'Could not refresh right now';
    if (state is OnlineFriendsSuccess) {
      final friends = state.onlineFriendsModel.result;
      final query = _query.trim();
      if (friends.isEmpty || query.isEmpty) return '${friends.length} online now';
      final visible = filterOnlineFriends(friends, query).length;
      return '$visible of ${friends.length} friends';
    }
    return 'Who is solving right now';
  }
}
