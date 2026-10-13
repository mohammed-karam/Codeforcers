part of 'submit_cubit.dart';

sealed class SubmitState {
  const SubmitState();
}

final class SubmitOpening extends SubmitState {
  const SubmitOpening();
}

final class SubmitNeedsLogin extends SubmitState {
  const SubmitNeedsLogin();
}

final class SubmitNeedsHandle extends SubmitState {
  const SubmitNeedsHandle();
}

final class SubmitReady extends SubmitState {
  const SubmitReady({this.language = ''});

    final String language;
}

final class SubmitClicking extends SubmitState {
  const SubmitClicking();
}

final class SubmitWaiting extends SubmitState {
  const SubmitWaiting({this.note});

      final String? note;
}

final class SubmitJudging extends SubmitState {
  const SubmitJudging({required this.submission});

  final CfSubmission submission;
}

final class SubmitDone extends SubmitState {
  const SubmitDone({required this.submission});

  final CfSubmission submission;
}

final class SubmitFailed extends SubmitState {
  const SubmitFailed({required this.message});

  final String message;
}
