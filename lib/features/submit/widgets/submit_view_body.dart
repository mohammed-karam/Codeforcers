import 'dart:convert';

import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/submit/data/cf_scripts.dart';
import 'package:codeforcers/features/submit/data/cf_submission.dart';
import 'package:codeforcers/features/submit/manager/cubit/submit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubmitViewBody extends StatefulWidget {
  const SubmitViewBody({
    super.key,
    required this.problem,
    required this.code,
    required this.language,
  });

  final ProblemRef problem;
  final String code;
  final LanguageModel language;

  @override
  State<SubmitViewBody> createState() => _SubmitViewBodyState();
}

class _SubmitViewBodyState extends State<SubmitViewBody> {
  static const String _channel = 'CfSubmit';
  static final Uri _submitPage =
      Uri.parse('https://codeforces.com/problemset/submit');

  static const Color _ok = Color(0xFF16A34A);
  static const Color _warn = Color(0xFFB45309);
  static const Color _bad = Color(0xFFDC2626);

  final TextEditingController _handle = TextEditingController();

    WebViewController? _web;

  bool get _hasBrowser => _web != null;

  @override
  void initState() {
    super.initState();

            if (WebViewPlatform.instance == null) {
      context.read<SubmitCubit>().pageUnavailable();
      return;
    }

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _channel,
        onMessageReceived: _onChannelMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: _onPageFinished),
      )
      ..loadRequest(_submitPage);
  }

  @override
  void dispose() {
    _handle.dispose();
    _web = null;
    super.dispose();
  }

  
  void _onChannelMessage(JavaScriptMessage message) {
    if (!mounted) return;
    context.read<SubmitCubit>().jsMessage(message.message);
  }

  void _onPageFinished(String url) {
    if (!mounted) return;
    final cubit = context.read<SubmitCubit>();
    cubit.pageFinished(url);

    final path = Uri.tryParse(url)?.path ?? '';
    if (path.endsWith('/submit')) _prefill();
  }

  Future<void> _prefill() async {
    final web = _web;
    if (web == null) return;
    try {
      await web.runJavaScript(
        cfPrefillScript(
          problemCode: widget.problem.id,
          source: widget.code,
          language: cfLanguageHint(widget.language.displayName),
        ),
      );
    } catch (_) {
          }
  }

  Future<void> _pressSubmit() async {
    final web = _web;
    if (web == null) return;
    try {
      await web.runJavaScript(cfClickSubmitScript());
    } catch (_) {
      if (!mounted) return;
                  context.read<SubmitCubit>().jsMessage(
            jsonEncode(<String, dynamic>{
              'step': 'click',
              'ok': false,
              'why': 'This page would not take the tap — press Submit on the page yourself.',
            }),
          );
    }
  }

  void _submit() => context.read<SubmitCubit>().submit();

  Future<void> _saveHandle() async {
    await context.read<SubmitCubit>().saveHandle(_handle.text);
    if (mounted) FocusScope.of(context).unfocus();
  }

      void _retry() {
    final cubit = context.read<SubmitCubit>();
    if (cubit.clicked) {
      cubit.retry();
      return;
    }
    cubit.retry();
    _web?.reload();
  }

  Future<void> _openOnCodeforces() => launchUrl(
        Uri.parse(
          'https://codeforces.com/problemset/status/'
          '${AppSettings.instance.codeforcesHandle}',
        ),
        mode: LaunchMode.platformDefault,
      );

  
  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmitCubit, SubmitState>(
      listenWhen: (_, next) => next is SubmitClicking,
      listener: (_, __) => _pressSubmit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: CustomAppBar(
          title: 'Submit to Codeforces',
          subtitle: '${widget.problem.code} · ${widget.language.displayName}',
          actions: [
            IconButton(
              tooltip: 'Reload the submit page',
              onPressed: _hasBrowser ? _retry : null,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Column(
          children: [
            _statusStrip(),
            Expanded(
              child: _hasBrowser ? _thePage() : _noBrowserCard(),
            ),
            if (_hasBrowser) _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _thePage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: Colors.white,
          child: WebViewWidget(controller: _web!),
        ),
      ),
    );
  }

    Widget _statusStrip() {
    return BlocBuilder<SubmitCubit, SubmitState>(
      builder: (context, state) {
        final handle = AppSettings.instance.codeforcesHandle;

        final ({
          String text,
          String? subtext,
          Color tint,
          IconData icon,
          bool busy,
          CfSubmission? submission,
        }) info = switch (state) {
          SubmitOpening() => (
              text: 'Opening Codeforces\' submit page…',
              subtext: null,
              tint: AppColors.navy,
              icon: Icons.language_rounded,
              busy: true,
              submission: null,
            ),
          SubmitNeedsLogin() => (
              text: 'Sign in on the page below — once. This phone keeps the session.',
              subtext: null,
              tint: _warn,
              icon: Icons.lock_outline_rounded,
              busy: false,
              submission: null,
            ),
          SubmitNeedsHandle() => (
              text: 'Add your Codeforces handle below to watch the verdict.',
              subtext: null,
              tint: AppColors.navy,
              icon: Icons.badge_outlined,
              busy: false,
              submission: null,
            ),
          SubmitReady(:final language) => (
              text: language.isEmpty
                  ? 'Form filled in for ${widget.problem.id} — ready to send.'
                  : 'Filled in for ${widget.problem.id} · $language.',
              subtext: null,
              tint: _ok,
              icon: Icons.check_circle_outline_rounded,
              busy: false,
              submission: null,
            ),
          SubmitClicking() => (
              text: 'Handing your code to Codeforces…',
              subtext: null,
              tint: AppColors.navy,
              icon: Icons.send_rounded,
              busy: true,
              submission: null,
            ),
          SubmitWaiting(:final note) => (
              text: note ?? 'Waiting for Codeforces to pick it up…',
              subtext: null,
              tint: AppColors.navy,
              icon: Icons.hourglass_top_rounded,
              busy: true,
              submission: null,
            ),
          SubmitJudging(:final submission) => (
              text: 'Running on the judges…',
              subtext: '${submission.problemCode} · ${submission.language}',
              tint: AppColors.navy,
              icon: Icons.timelapse_rounded,
              busy: true,
              submission: submission,
            ),
          SubmitDone(:final submission) => (
              text: submission.friendlyVerdict,
              subtext: '${submission.problemCode} · ${submission.language}',
              tint: submission.looksGood ? _ok : _bad,
              icon: submission.looksGood
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              busy: false,
              submission: submission,
            ),
          SubmitFailed(:final message) => (
              text: message,
              subtext: null,
              tint: _bad,
              icon: Icons.error_outline_rounded,
              busy: false,
              submission: null,
            ),
        };

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: info.tint.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: info.tint.withOpacity(0.28)),
          ),
          child: Row(
            children: [
              if (info.busy)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.navy,
                  ),
                )
              else
                Icon(info.icon, size: 17, color: info.tint),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.text,
                      style: const TextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                    if (info.subtext != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.subtext!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (info.submission != null && handle.isNotEmpty) ...[
                const SizedBox(width: 6),
                TextButton(
                  onPressed: _openOnCodeforces,
                  child: const Text(
                    'View',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

    Widget _bottomBar() {
    return BlocBuilder<SubmitCubit, SubmitState>(
      builder: (context, state) {
        final cubit = context.read<SubmitCubit>();
        final needsHandle = state is SubmitNeedsHandle;

        final (String label, VoidCallback? action) = switch (state) {
          SubmitOpening() => ('Opening the page…', null),
          SubmitNeedsLogin() => ('Sign in on the page to continue', null),
          SubmitNeedsHandle() => ('Add your handle to watch the verdict', null),
          SubmitReady() => ('Submit to Codeforces', _submit),
          SubmitClicking() => ('Sending your code…', null),
          SubmitWaiting() => ('Waiting for Codeforces…', null),
          SubmitJudging() => ('Judging — one moment…', null),
          SubmitDone() => ('Submitted', null),
          SubmitFailed() => (
              cubit.clicked ? 'Watch again' : 'Reload the page',
              _retry,
            ),
        };

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: EdgeInsets.fromLTRB(16, needsHandle ? 12 : 8, 16, 16),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (needsHandle) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _handle,
                          autocorrect: false,
                          onSubmitted: (_) => _saveHandle(),
                          decoration: InputDecoration(
                            hintText: 'Your Codeforces handle',
                            filled: true,
                            fillColor: const Color(0xFFF4F6F9),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: _fieldBorder(AppColors.border),
                            enabledBorder: _fieldBorder(AppColors.border),
                            focusedBorder: _fieldBorder(AppColors.navy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _saveHandle,
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                ElevatedButton.icon(
                  onPressed: action,
                  icon: action == null
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded, size: 17),
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.navy.withOpacity(0.45),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  OutlineInputBorder _fieldBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

    Widget _noBrowserCard() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.public_rounded,
                size: 30,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 10),
              const Text(
                'Your code is filled into Codeforces\' own submit page, inside the app on your phone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.problem.code} · ${widget.language.displayName}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => launchUrl(
                  _submitPage,
                  mode: LaunchMode.platformDefault,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Open on Codeforces',
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
            ],
          ),
        ),
      ),
    );
  }
}
