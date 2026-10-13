import 'dart:math' as math;

import 'package:codeforcers/core/storage/solved_store.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/ai_tutor/views/ai_tutor_view.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/code_compiler/widgets/code_compiler_view_body.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/data/models/statement_model.dart';
import 'package:codeforcers/features/problems/manager/cubit/statement_cubit.dart';
import 'package:codeforcers/features/problems/views/statement_reader_view.dart';
import 'package:codeforcers/features/problems/widgets/statement_body.dart';
import 'package:codeforcers/features/submit/views/submit_view.dart';
import 'package:codeforcers/features/submit/widgets/cf_verdict_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _error = Color(0xFFDC2626);

class ProblemWorkspaceBody extends StatefulWidget {
  const ProblemWorkspaceBody({super.key, required this.problem});

  final ProblemRef problem;

  @override
  State<ProblemWorkspaceBody> createState() => _ProblemWorkspaceBodyState();
}

class _ProblemWorkspaceBodyState extends State<ProblemWorkspaceBody> {
  static const double _collapsedHeight = 46;
  static const double _minPanelHeight = 150;

          static const double _reservedBelowPanel = 600;

  double _panelHeight = 300;
  bool _collapsed = false;
  late bool _solved;

  @override
  void initState() {
    super.initState();
    _solved = SolvedStore.instance.isSolved(widget.problem.id);
  }

  double get _maxPanelHeight {
    final screen = MediaQuery.sizeOf(context).height;
    return math.max(
      _minPanelHeight,
      math.min(screen * 0.55, screen - _reservedBelowPanel),
    );
  }

  void _toggleCollapsed() => setState(() => _collapsed = !_collapsed);

  void _onPanelDrag(DragUpdateDetails details) {
    setState(() {
      _collapsed = false;
      _panelHeight = (_panelHeight + details.delta.dy)
          .clamp(_minPanelHeight, _maxPanelHeight);
    });
  }

  Future<void> _toggleSolved() async {
    final store = SolvedStore.instance;
    final problem = widget.problem;

    if (_solved) {
      await store.unmark(problem.id);
    } else {
      await store.mark(
        id: problem.id,
        name: problem.name,
        rating: problem.rating,
        tags: problem.tags,
      );
    }

    if (!mounted) return;
    setState(() => _solved = !_solved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _solved ? 'Marked as solved.' : 'Removed from your solved list.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _askAi(ProblemStatement statement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiTutorView(initialQuestion: statement.plainText),
      ),
    );
  }

    void _submitCode(String code, LanguageModel language) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitView(
          problem: widget.problem,
          code: code,
          language: language,
        ),
      ),
    );
  }

  void _openReader(ProblemStatement statement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatementReaderView(
          title: widget.problem.name,
          statement: statement,
        ),
      ),
    );
  }

  void _reloadStatement() {
    context.read<StatementCubit>().load(widget.problem);
  }

  String get _subtitle {
    final problem = widget.problem;
    final parts = <String>[problem.code];
    parts.add(problem.rating?.toString() ?? 'Unrated');
    if (problem.tags.isNotEmpty) parts.add(problem.tags.take(2).join(', '));
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return BlocBuilder<StatementCubit, StatementState>(
      builder: (context, state) {
        final statement = state is StatementSuccess ? state.statement : null;

        return CodeCompilerViewBody(
          appBar: CustomAppBar(
            title: widget.problem.name,
            subtitle: _subtitle,
            actions: [
              IconButton(
                tooltip: 'Ask the AI about this problem',
                onPressed:
                    statement == null ? null : () => _askAi(statement),
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
              IconButton(
                tooltip: _solved ? 'Solved — tap to undo' : 'Mark as solved',
                onPressed: _toggleSolved,
                icon: Icon(
                  _solved
                      ? Icons.check_circle_rounded
                      : Icons.check_circle_outline_rounded,
                  color: _solved ? const Color(0xFF86EFAC) : Colors.white,
                ),
              ),
            ],
          ),
          header: keyboardOpen
              ? null
              : SizedBox(
                  height:
                      _collapsed ? _collapsedHeight : _panelHeight.clamp(
                    _minPanelHeight,
                    _maxPanelHeight,
                  ),
                  child: _StatementPanel(
                    collapsed: _collapsed,
                    onToggle: _toggleCollapsed,
                    onDrag: _onPanelDrag,
                    onOpenFull: statement == null
                        ? null
                        : () => _openReader(statement),
                    onRetry: state is StatementFailure ? _reloadStatement : null,
                    child: _panelChild(state),
                  ),
                ),
          aboveRun: CfVerdictCard(problem: widget.problem),
          onSubmit: _submitCode,
        );
      },
    );
  }

  Widget _panelChild(StatementState state) {
    return switch (state) {
      StatementSuccess(:final statement) => StatementBody(statement: statement),
      StatementFailure(:final errorMessage) =>
        _StatementError(message: errorMessage, onRetry: _reloadStatement),
      _ => const _StatementLoading(),
    };
  }
}


class _StatementPanel extends StatelessWidget {
  const _StatementPanel({
    required this.collapsed,
    required this.onToggle,
    required this.onDrag,
    required this.onOpenFull,
    required this.onRetry,
    required this.child,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final ValueChanged<DragUpdateDetails> onDrag;
  final VoidCallback? onOpenFull;
  final VoidCallback? onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
            return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          _bar(),
          if (!collapsed) ...[
            Expanded(child: SingleChildScrollView(child: child)),
            _dragHandle(),
          ],
        ],
      ),
    );
  }

  Widget _bar() {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: AppColors.chipBackground,
        child: Row(
          children: [
            const Icon(Icons.article_outlined, size: 17, color: AppColors.navy),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Problem statement',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (onOpenFull != null)
              IconButton(
                tooltip: 'Read full screen',
                onPressed: onOpenFull,
                icon: const Icon(Icons.fullscreen_rounded, size: 20),
                color: AppColors.navy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
              ),
            if (onRetry != null)
              IconButton(
                tooltip: 'Reload statement',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 19),
                color: AppColors.navy,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
              ),
            IconButton(
              tooltip: collapsed ? 'Expand statement' : 'Collapse statement',
              onPressed: onToggle,
              icon: Icon(
                collapsed
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22,
              ),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDrag,
      child: Container(
        height: 18,
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}


class _StatementLoading extends StatelessWidget {
  const _StatementLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(height: 12),
            Text(
              'Reading the problem statement…',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementError extends StatelessWidget {
  const _StatementError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 18, color: _error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _error,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
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
                onPressed: () => launchUrl(
                  Uri.parse('https://codeforces.com/problemset'),
                  mode: LaunchMode.platformDefault,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 15),
                label: const Text(
                  'Open on the website',
                  style: TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
