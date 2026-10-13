import 'package:bloc/bloc.dart';
import 'package:codeforcers/features/problems/data/models/problem_model.dart';
import 'package:codeforcers/features/problems/data/repo/problems_repo.dart';

part 'problems_list_state.dart';

class ProblemsListCubit extends Cubit<ProblemsListState> {
  ProblemsListCubit(this._repo) : super(ProblemsListLoading());

  final ProblemsRepo _repo;

  List<ProblemRef> _problems = const <ProblemRef>[];

  Future<void> load({bool forceRefresh = false}) async {
    if (!forceRefresh) emit(ProblemsListLoading());

    final result = await _repo.fetchProblems(forceRefresh: forceRefresh);

    result.fold(
      (failure) => emit(
        ProblemsListFailure(
          errorMessage: failure.errorMessage,
          problems: _problems,
        ),
      ),
      (problems) {
        _problems = problems;
        emit(ProblemsListSuccess(problems: problems));
      },
    );
  }
}
