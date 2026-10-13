import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/online_friends/data/models/friend_info.dart';
import 'package:codeforcers/features/online_friends/manager/online_friends_cubit/online_friends_cubit.dart';
import 'package:codeforcers/features/user_details/widgets/get_rating_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _errorRed = Color(0xFFDC2626);
const Color _onlineGreen = Color(0xFF16A34A);

List<String> filterOnlineFriends(Iterable<String> handles, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return List<String>.from(handles);
  return handles
      .where((handle) => handle.toLowerCase().contains(needle))
      .toList();
}

class OnlineFriendsViewBody extends StatefulWidget {
  const OnlineFriendsViewBody({
    super.key,
    this.query = '',
    this.onQueryChanged,
  });

      final String query;

  final ValueChanged<String>? onQueryChanged;

  @override
  State<OnlineFriendsViewBody> createState() => _OnlineFriendsViewBodyState();
}

class _OnlineFriendsViewBodyState extends State<OnlineFriendsViewBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    BlocProvider.of<OnlineFriendsCubit>(context, listen: false)
        .getOnlineFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() =>
      BlocProvider.of<OnlineFriendsCubit>(context).getOnlineFriends();

  void _retry() {
    BlocProvider.of<OnlineFriendsCubit>(context, listen: false)
        .getOnlineFriends();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onQueryChanged?.call('');
  }

  Future<void> _openProfile(String handle) async {
    try {
      await launchUrl(
        Uri.parse('https://codeforces.com/profile/$handle'),
        mode: LaunchMode.platformDefault,
      );
    } catch (_) {
          }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: _SearchField(
            controller: _searchController,
            hasQuery: widget.query.isNotEmpty,
            onChanged: widget.onQueryChanged,
            onClear: _clearSearch,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<OnlineFriendsCubit, OnlineFriendsState>(
            builder: (context, state) => _buildState(state),
          ),
        ),
      ],
    );
  }

  Widget _buildState(OnlineFriendsState state) {
    if (state is OnlineFriendsLoading) return const _LoadingState();
    if (state is OnlineFriendsFailure) {
      return _centered(
        child: _ErrorCard(message: state.errorMessage, onRetry: _retry),
      );
    }
    if (state is OnlineFriendsSuccess) {
      final friends = state.onlineFriendsModel.result;
      final visible = filterOnlineFriends(friends, widget.query);
      if (visible.isEmpty) {
        if (widget.query.trim().isNotEmpty && friends.isNotEmpty) {
          return _centered(
            child: _NoResultsState(
              query: widget.query.trim(),
              onClear: _clearSearch,
            ),
          );
        }
        return _centered(child: const _EmptyState());
      }
      return _FriendListView(
        handles: visible,
        friendInfo: state.friendInfo,
        onRefresh: _refresh,
        onOpen: _openProfile,
      );
    }
    return const SizedBox.shrink();
  }

      Widget _centered({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: AppColors.navy,
          backgroundColor: AppColors.surface,
          edgeOffset: 16,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 56,
              ),
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }
}


class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String>? onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1B3B6F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.blue,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          hintText: 'Search by handle',
          hintStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: hasQuery
              ? IconButton(
                  onPressed: onClear,
                  tooltip: 'Clear search',
                  icon: const Icon(
                    Icons.cancel_rounded,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 44),
        ),
      ),
    );
  }
}


class _FriendListView extends StatelessWidget {
  const _FriendListView({
    required this.handles,
    required this.friendInfo,
    required this.onRefresh,
    required this.onOpen,
  });

  final List<String> handles;
  final Map<String, FriendInfo>? friendInfo;
  final Future<void> Function() onRefresh;
  final void Function(String handle) onOpen;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.navy,
      backgroundColor: AppColors.surface,
      edgeOffset: 16,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
        itemCount: handles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final handle = handles[index];
          return _FriendCard(
            handle: handle,
            friendInfo: friendInfo,
            onOpen: () => onOpen(handle),
          );
        },
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({
    required this.handle,
    required this.friendInfo,
    required this.onOpen,
  });

  final String handle;
  final Map<String, FriendInfo>? friendInfo;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      semanticsLabel: 'Open $handle on Codeforces',
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F1B3B6F),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _FriendAvatar(handle: handle, photoUrl: _photoUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    handle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _RatingBadge(handle: handle, friendInfo: friendInfo),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String? get _photoUrl => friendInfo?[handle]?.titlePhoto;
}


class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({required this.handle, required this.photoUrl});

  final String handle;
  final String? photoUrl;

    static const List<Color> _tints = [
    AppColors.navy,
    AppColors.blue,
    AppColors.accentBlue,
    Color(0xFF4338CA),
    Color(0xFF0E7490),
    Color(0xFF03A89E),
  ];

  Color get _tint {
    var hash = 0;
    for (final unit in handle.codeUnits) {
      hash = (hash * 31 + unit) & 0x7FFFFFFF;
    }
    return _tints[hash % _tints.length];
  }

  String get _initial {
    final trimmed = handle.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tint;
    final letter = Center(
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: tint,
        ),
      ),
    );

    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 54,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: 0.12),
              border: Border.all(
                color: tint.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: photoUrl == null
                ? letter
                : Image.network(
                    photoUrl!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => letter,
                  ),
          ),
          const Positioned(right: -2, bottom: -1, child: _PulsingDot()),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _animate = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = !(MediaQuery.maybeOf(context)?.disableAnimations ?? false);
    if (_animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 13,
      height: 13,
      decoration: BoxDecoration(
        color: _onlineGreen,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );

    if (!_animate) return dot;

    return AnimatedBuilder(
      animation: _controller,
      child: dot,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 13 + 11 * t,
              height: 13 + 11 * t,
              decoration: BoxDecoration(
                color: _onlineGreen.withValues(alpha: 0.30 * (1 - t)),
                shape: BoxShape.circle,
              ),
            ),
            child!,
          ],
        );
      },
    );
  }
}


class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.handle, required this.friendInfo});

  final String handle;
  final Map<String, FriendInfo>? friendInfo;

  @override
  Widget build(BuildContext context) {
    final info = friendInfo;
    if (info == null) {
            return Container(
        width: 84,
        height: 22,
        decoration: const BoxDecoration(
          color: AppColors.chipBackground,
          borderRadius: BorderRadius.all(Radius.circular(999)),
        ),
      );
    }

    final friend = info[handle];
    if (friend == null) {
            return const SizedBox.shrink();
    }

    final rating = friend.rating;
    final maxRating = friend.maxRating ?? rating;
    final rated = rating != null;
    final color = rated
        ? getRatingColor(rating, maxRating ?? rating)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: rated ? 0.12 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label(friend),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _label(FriendInfo friend) {
    final rank = friend.rankLabel;
    final rating = friend.rating;
    if (rank.isEmpty && rating == null) return 'Unrated';
    if (rank.isEmpty) return '$rating';
    if (rating == null) return rank;
    return '$rank $rating';
  }
}


class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Finding your online friends',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Checking Codeforces for who is solving right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      icon: Icons.group_off_rounded,
      tint: AppColors.navy,
      title: 'No friends online right now',
      message: 'Friends appear here the moment they start solving on '
          'Codeforces. Pull down to refresh, or check back a bit later.',
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      icon: Icons.search_off_rounded,
      tint: AppColors.blue,
      title: 'No matching friends',
      message: 'No online friend matches "$query". Try part of another handle.',
      action: TextButton(
        onPressed: onClear,
        child: const Text(
          'Clear search',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.accentBlue,
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageCard(
      icon: Icons.cloud_off_rounded,
      tint: _errorRed,
      title: "Couldn't load your friends",
      message: message,
      hint: 'Check your connection, then try again.',
      action: ElevatedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Try again'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.tint,
    required this.title,
    required this.message,
    this.hint,
    this.action,
  });

  final IconData icon;
  final Color tint;
  final String title;
  final String message;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(22)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F1B3B6F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 18),
            action!,
          ],
        ],
      ),
    );
  }
}
