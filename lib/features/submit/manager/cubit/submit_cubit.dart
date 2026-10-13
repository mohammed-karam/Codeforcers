import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/features/submit/data/cf_submission.dart';
import 'package:codeforcers/features/submit/data/cf_submissions_api.dart';
import 'package:codeforcers/features/submit/data/cf_verdict_store.dart';

part 'submit_state.dart';

class SubmitCubit extends Cubit<SubmitState> {
  SubmitCubit({
    required this.problemCode,
    CfSubmissionsApi? api,
    String? handle,
    this.pollEvery = const Duration(seconds: 3),
    this.giveUpAfter = const Duration(minutes: 2),
  })  : _api = api ?? CfSubmissionsApi(),
        _handle = handle ?? AppSettings.instance.codeforcesHandle,
        super(const SubmitOpening());

    final String problemCode;

      final Duration pollEvery;
  final Duration giveUpAfter;

  final CfSubmissionsApi _api;

  late String _handle;
  String _language = '';
  bool _clicked = false;
  bool _watching = false;
  Timer? _formWatchdog;

    bool get hasHandle => _handle.trim().isNotEmpty;

      bool get clicked => _clicked || _watching;

  
    void pageFinished(String url) {
    final path = Uri.tryParse(url)?.path ?? '';

    if (path.contains('/enter') || path.contains('/login')) {
      _formWatchdog?.cancel();
      if (state is! SubmitDone && state is! SubmitJudging) {
        emit(const SubmitNeedsLogin());
      }
      return;
    }

    if (path.endsWith('/submit')) {
                  _formWatchdog?.cancel();
      _formWatchdog = Timer(const Duration(seconds: 6), () {
        if (!isClosed && state is SubmitOpening) {
          emit(const SubmitFailed(
            message:
                'The submit form never filled itself in — tap Reload, or fill it in on the page yourself.',
          ));
        }
      });
      return;
    }

    if (path.contains('/status') || path.contains('/my')) {
                  _formWatchdog?.cancel();
      if (clicked || state is SubmitWaiting || state is SubmitClicking) return;
      if (state is SubmitReady || state is SubmitNeedsHandle) {
        _watch(strict: false);
      }
      return;
    }

    _formWatchdog?.cancel();
    if (state is SubmitOpening) {
      emit(const SubmitFailed(
        message:
            'Codeforces opened a different page — tap Reload to come back to the submit form.',
      ));
    }
  }

    void pageUnavailable() {
    emit(const SubmitFailed(
      message:
          'Submitting happens on Codeforces\' own page, which this screen cannot open here. Use the link below to submit in a browser.',
    ));
  }

    void jsMessage(String raw) {
    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      payload = decoded;
    } on FormatException {
      return;
    }

    switch (payload['step'] as String?) {
      case 'prefill':
        _onPrefill(payload);
        break;
      case 'click':
        _onClicked(
          ok: payload['ok'] == true,
          why: payload['why']?.toString(),
        );
        break;
      default:
        break;
    }
  }

  
    void submit() {
    if (state is! SubmitReady) return;
    _clicked = true;
    emit(const SubmitClicking());
  }

    Future<void> saveHandle(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    await AppSettings.instance.setCodeforcesHandle(trimmed);
    _handle = trimmed;

    if (state is SubmitNeedsHandle) emit(SubmitReady(language: _language));
  }

    void retry() {
    if (clicked) {
      emit(const SubmitWaiting());
      _watch(strict: true);
      return;
    }
    emit(const SubmitOpening());
  }

  
  void _onPrefill(Map<String, dynamic> payload) {
    _formWatchdog?.cancel();

                final busy = state is SubmitClicking ||
        state is SubmitWaiting ||
        state is SubmitJudging ||
        state is SubmitDone;
    if (busy) {
      final chosen = payload['chosen']?.toString();
      if (chosen != null && chosen.isNotEmpty) _language = chosen;
      return;
    }

    final filled = payload['problem'] == true && payload['source'] == true;
    if (!filled) {
      emit(const SubmitFailed(
        message:
            'The submit form did not fill itself in — tap Reload, or fill it in on the page yourself.',
      ));
      return;
    }

    _language = payload['chosen']?.toString() ?? '';
    emit(hasHandle
        ? SubmitReady(language: _language)
        : const SubmitNeedsHandle());
  }

  void _onClicked({required bool ok, String? why}) {
    _clicked = true;
    emit(SubmitWaiting(
      note: ok
          ? null
          : (why ?? 'Tap Submit on the page yourself — the verdict is watched either way.'),
    ));
    _watch(strict: true);
  }

            Future<void> _watch({required bool strict}) async {
    if (_watching) return;
    _watching = true;

    final deadline = DateTime.now().add(giveUpAfter);

            var baselineId = -1;
    var misses = 0;

    while (!isClosed && DateTime.now().isBefore(deadline)) {
      final result = await _api.latestFor(_handle);

      if (result.isLeft()) {
        misses += 1;
        if (misses >= 3) {
          _watching = false;
          if (isClosed) return;
          if (strict) {
            emit(const SubmitFailed(
              message:
                  'Codeforces is not answering — check your connection, then tap Watch again.',
            ));
          }
          return;
        }
      } else {
        misses = 0;
        final submission =
            result.fold<CfSubmission?>((_) => null, (value) => value);

        if (submission != null) {
          if (baselineId == -1) baselineId = submission.id;

          final isNew = submission.id != baselineId || submission.isRecent;
          if (submission.problemCode == problemCode && isNew) {
            await CfVerdictStore.instance.write(submission);
            if (isClosed) return;

            emit(SubmitJudging(submission: submission));
            if (!submission.isJudging) {
              emit(SubmitDone(submission: submission));
              _watching = false;
              return;
            }
          }
        }
      }

      await Future<void>.delayed(pollEvery);
    }

    _watching = false;
    if (isClosed) return;

    if (state is SubmitJudging) {
      emit(const SubmitFailed(
        message: 'Still judging after a couple of minutes — tap Watch again.',
      ));
    } else if (strict && state is SubmitWaiting) {
      emit(const SubmitFailed(
        message:
            'Nothing reached Codeforces yet — tap Watch again, or check it on the site.',
      ));
    }
  }

  @override
  Future<void> close() {
    _formWatchdog?.cancel();
    return super.close();
  }
}
