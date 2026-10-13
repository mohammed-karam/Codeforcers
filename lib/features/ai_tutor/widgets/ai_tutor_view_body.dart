import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/utils/constants.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/ai_tutor/data/models/ai_feedback_model.dart';
import 'package:codeforcers/features/ai_tutor/manager/cubit/ai_tutor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class AiTutorViewBody extends StatefulWidget {
  const AiTutorViewBody({super.key, this.initialQuestion});

    final String? initialQuestion;

  @override
  State<AiTutorViewBody> createState() => _AiTutorViewBodyState();
}

class _AiTutorViewBodyState extends State<AiTutorViewBody> {
  static const Color _success = Color(0xFF16A34A);
  static const Color _error = Color(0xFFDC2626);
  static const Color _hint = Color(0xFFB45309);
  static const Color _hintBackground = Color(0xFFFFF7ED);

  static const BoxDecoration _cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0F1B3B6F),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  );

  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

      bool _hasKey = true;

  @override
  void initState() {
    super.initState();
    _hasKey = AppSettings.instance.hasGroqApiKey;
    final question = widget.initialQuestion;
    if (question != null && question.trim().isNotEmpty) {
      _questionController.text = question.trim();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_hasKey) {
      _promptForKey();
      return;
    }

    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both the question and your answer.'),
        ),
      );
      return;
    }

    context.read<AiTutorCubit>().checkAnswer(question: question, answer: answer);
  }

  void _startOver() {
    _questionController.clear();
    _answerController.clear();
    FocusScope.of(context).unfocus();
    context.read<AiTutorCubit>().reset();
  }

    Future<void> _promptForKey() async {
    final key = await showDialog<String>(
      context: context,
      builder: (_) => const _ApiKeyDialog(),
    );

    if (key == null || key.isEmpty) return;

    await AppSettings.instance.setGroqApiKey(key);
    if (!mounted) return;
    setState(() => _hasKey = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API key saved on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'AI Answer Checker',
        subtitle: 'A hint on each trial — then the solution',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
        child: BlocBuilder<AiTutorCubit, AiTutorState>(
          builder: (context, state) {
            final cubit = context.read<AiTutorCubit>();
            final isLoading = state is AiTutorLoading;
            final attemptsUsed = cubit.attemptsUsed;
            final trialsEnded = cubit.trialsEnded;
            final nextAttempt =
                (attemptsUsed + 1).clamp(1, kMaxAnswerTrials);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check your answer',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paste the question, submit your answer and the AI corrects '
                  'it. Every wrong trial earns a hint — after 3 trials the '
                  'full solution is revealed.',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                if (!_hasKey) ...[
                  _ApiKeyBanner(onAddKey: _promptForKey),
                  const SizedBox(height: 18),
                ],
                _TrialProgress(
                  attemptsUsed: attemptsUsed,
                  trialsEnded: trialsEnded,
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _questionController,
                  enabled: !trialsEnded,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Question / problem statement',
                    hintText: 'Paste the question you are working on...',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _answerController,
                  enabled: !trialsEnded,
                  minLines: 3,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: 'Your answer (text or code)',
                    hintText: 'Type or paste your answer here...',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (isLoading || trialsEnded) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      disabledBackgroundColor: AppColors.navy.withValues(
                        alpha: 0.45,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            trialsEnded
                                ? 'Trials ended — solution revealed'
                                : 'Check my answer  ·  Trial $nextAttempt of'
                                    ' $kMaxAnswerTrials',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildFeedback(state, trialsEnded: trialsEnded),
              ],
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildFeedback(AiTutorState state, {required bool trialsEnded}) {
    return switch (state) {
      AiTutorInitial() => _placeholderBox(),
      AiTutorLoading() => _loadingBox(),
      AiTutorFailure(:final errorMessage, :final needsApiKey) =>
        _failureBox(errorMessage, needsApiKey: needsApiKey),
      AiTutorFeedback(
        :final feedback,
        :final attempt,
        :final attemptsUsed,
      ) =>
        _feedbackCard(
          feedback: feedback,
          attempt: attempt,
          attemptsUsed: attemptsUsed,
          trialsEnded: trialsEnded,
        ),
    };
  }

  Widget _placeholderBox() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.navy, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your correction will appear here. A wrong answer gets a hint, '
              'and once the 3 trials end you receive the full solution.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingBox() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.navy,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'The AI is checking your answer...',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _failureBox(String errorMessage, {required bool needsApiKey}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                needsApiKey
                    ? Icons.key_rounded
                    : Icons.error_outline_rounded,
                color: needsApiKey ? AppColors.navy : _error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: needsApiKey ? AppColors.textPrimary : _error,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (needsApiKey)
            OutlinedButton.icon(
              onPressed: _promptForKey,
              icon: const Icon(Icons.vpn_key_rounded, size: 16),
              label: const Text(
                'Add my API key',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            const Text(
              'No trial was used — press the button to try again.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _feedbackCard({
    required AiFeedbackModel feedback,
    required int attempt,
    required int attemptsUsed,
    required bool trialsEnded,
  }) {
    final isCorrect = feedback.isCorrect;
    final showSolution = feedback.hasSolution;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (isCorrect ? _success : _error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 16,
                      color: isCorrect ? _success : _error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCorrect ? 'Correct' : 'Incorrect',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isCorrect ? _success : _error,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Trial $attempt of $kMaxAnswerTrials',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            feedback.feedback.isEmpty
                ? (isCorrect
                    ? 'Well done, your answer is accepted.'
                    : 'Not quite — read the hint and try again.')
                : feedback.feedback,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (feedback.hasHint) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hintBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        size: 16,
                        color: _hint,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Hint',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _hint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    feedback.hint,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showSolution) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppColors.navy,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Solution',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    feedback.solution,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isCorrect ? _success : _error).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCorrect
                  ? 'Answer accepted — your trials were reset, try another '
                      'question.'
                  : trialsEnded
                      ? 'All $kMaxAnswerTrials trials ended, so the full '
                          'solution is now shown.'
                      : 'Used $attemptsUsed of $kMaxAnswerTrials trials — '
                          'the next wrong answer brings a stronger hint.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: isCorrect
                    ? const Color(0xFF15803D)
                    : const Color(0xFF991B1B),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _startOver,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Start over',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.navy),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AppSettings.instance.groqApiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Add your Groq API key',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The AI checker runs on your own key, so nothing is shared '
            'between students. It is saved on this device only.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'Groq API key',
              hintText: 'gsk_...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://console.groq.com/keys'),
              mode: LaunchMode.platformDefault,
            ),
            child: const Text(
              'Get a free key at console.groq.com',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}


class _TrialProgress extends StatelessWidget {
  const _TrialProgress({
    required this.attemptsUsed,
    required this.trialsEnded,
  });

  final int attemptsUsed;
  final bool trialsEnded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Trials',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                trialsEnded
                    ? 'Solution revealed'
                    : '$attemptsUsed of $kMaxAnswerTrials used',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: trialsEnded ? const Color(0xFFDC2626) : AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(kMaxAnswerTrials, (index) {
              final used = index < attemptsUsed;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 8,
                  margin: EdgeInsets.only(
                    right: index == kMaxAnswerTrials - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: used ? AppColors.navy : AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          const Text(
            'Each wrong answer earns one hint. When the 3 trials end, the '
            'full solution is revealed.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}


class _ApiKeyBanner extends StatelessWidget {
  const _ApiKeyBanner({required this.onAddKey});

  final VoidCallback onAddKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDBA74)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.key_rounded, color: Color(0xFFB45309), size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add your Groq API key to start',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'The checker runs on your own free key — it stays on this device '
            'and is never shared with other students.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF9A3412),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddKey,
              icon: const Icon(Icons.vpn_key_rounded, size: 18),
              label: const Text(
                'Paste my API key',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB45309),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
