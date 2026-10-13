import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/custom_app_bar.dart';
import 'package:codeforcers/features/code_compiler/data/constants/supported_languages.dart';
import 'package:codeforcers/features/code_compiler/data/models/language_model.dart';
import 'package:codeforcers/features/code_compiler/manager/cubit/code_compiler_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CodeCompilerViewBody extends StatefulWidget {
  const CodeCompilerViewBody({
    super.key,
    this.appBar,
    this.header,
    this.editorFlex = 1,
    this.aboveRun,
    this.onSubmit,
  });

      final PreferredSizeWidget? appBar;

            final Widget? header;

        final int editorFlex;

        final Widget? aboveRun;

          final void Function(String code, LanguageModel language)? onSubmit;

  @override
  State<CodeCompilerViewBody> createState() => _CodeCompilerViewBodyState();
}

class _CodeCompilerViewBodyState extends State<CodeCompilerViewBody> {
    late LanguageModel _selectedLanguage;
  late TextEditingController _codeController;
  final TextEditingController _stdinController = TextEditingController();
  bool _showStdin = false;

    static const Color _appBarColor = Color(0xFF1B3B6F);
  static const Color _editorBackground = Color(0xFF1E1E2E);
  static const Color _editorText = Color(0xFFCDD6F4);
  static const Color _lineNumberColor = Color(0xFF6C7086);
  static const Color _selectedChipColor = Color(0xFF1B3B6F);
  static const Color _outputGreen = Color(0xFF4CAF50);
  static const Color _outputRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _selectedLanguage = kSupportedLanguages.first;
    _codeController = TextEditingController(
      text: _selectedLanguage.boilerplate,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _stdinController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(LanguageModel language) {
    setState(() {
      _selectedLanguage = language;
      _codeController.text = language.boilerplate;
    });
  }

  void _runCode() {
    FocusScope.of(context).unfocus();
    BlocProvider.of<CodeCompilerCubit>(context).runCode(
      code: _codeController.text,
      stdin: _stdinController.text,
      language: _selectedLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: widget.appBar ?? _buildAppBar(),
      body: Column(
        children: [
          if (widget.header != null) widget.header!,
          _buildLanguageSelector(),
          Expanded(flex: widget.editorFlex, child: _buildCodeEditor()),
          _buildStdinToggleBar(),
          if (_showStdin) _buildStdinInput(),
          if (widget.aboveRun != null) widget.aboveRun!,
          _buildRunButton(),
          if (widget.onSubmit != null) _buildSubmitButton(),
          _buildOutputPanel(),
        ],
      ),
    );
  }

  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: 'Code Compiler',
      roundedBottom: false,
      actions: [
        IconButton(
          tooltip: 'Clear code',
          onPressed: () => _codeController.clear(),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  
  Widget _buildLanguageSelector() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kSupportedLanguages.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final language = kSupportedLanguages[index];
            final isSelected =
                language.compilerId == _selectedLanguage.compilerId;
            return GestureDetector(
              onTap: () => _onLanguageSelected(language),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  language.displayName,
                  style: TextStyle(
                    color: isSelected ? _selectedChipColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  
  Widget _buildCodeEditor() {
    return Container(
      color: _editorBackground,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    _buildLineNumbers(),
                    Expanded(
            child: TextField(
              controller: _codeController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                color: _editorText,
                height: 1.6,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                hintText: 'Write your code here...',
                hintStyle: TextStyle(color: _lineNumberColor),
              ),
              onChanged: (_) => setState(() {}),             ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineNumbers() {
    final lineCount = '\n'.allMatches(_codeController.text).length + 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 13, 8, 12),
      color: const Color(0xFF181825),
                        child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            lineCount,
            (i) => SizedBox(
              height: 21.6,               child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13.5,
                  color: _lineNumberColor,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildStdinToggleBar() {
    return GestureDetector(
      onTap: () => setState(() => _showStdin = !_showStdin),
      child: Container(
        color: const Color(0xFF2A2A3E),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.input, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            const Text(
              'Standard Input (stdin)',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Spacer(),
            Icon(
              _showStdin ? Icons.expand_less : Icons.expand_more,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStdinInput() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 100),
      color: const Color(0xFF313244),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: _stdinController,
        maxLines: null,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: _editorText,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter input for your program...',
          hintStyle: TextStyle(color: _lineNumberColor),
        ),
      ),
    );
  }

  
  Widget _buildRunButton() {
    return BlocBuilder<CodeCompilerCubit, CodeCompilerState>(
      builder: (context, state) {
        final isLoading = state is CodeCompilerLoading;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _runCode,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(
                isLoading
                    ? 'Running...'
                    : 'Run  (${_selectedLanguage.displayName})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? _appBarColor.withOpacity(0.6)
                    : _appBarColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () =>
              widget.onSubmit!(_codeController.text, _selectedLanguage),
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text(
            'Submit to Codeforces',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _appBarColor,
            backgroundColor: Colors.white,
            side: BorderSide(color: _appBarColor.withOpacity(0.45)),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildOutputPanel() {
    return BlocBuilder<CodeCompilerCubit, CodeCompilerState>(
      builder: (context, state) {
        if (state is CodeCompilerInitial) {
          return _buildOutputPlaceholder();
        } else if (state is CodeCompilerLoading) {
          return _buildOutputContainer(
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),
          );
        } else if (state is CodeCompilerSuccess) {
          return _buildOutputResult(
            state.result.stdout,
            state.result.stderr,
            state.result.exitCode,
          );
        } else if (state is CodeCompilerFailure) {
          return _buildOutputContainer(
            child: Text(
              state.errorMessage,
              style: const TextStyle(
                color: _outputRed,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOutputPlaceholder() {
    return _buildOutputContainer(
      child: const Row(
        children: [
          Icon(Icons.terminal, color: Colors.white30, size: 18),
          SizedBox(width: 8),
          Text(
            'Output will appear here after you run your code.',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputResult(String stdout, String stderr, int exitCode) {
    return _buildOutputContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: exitCode == 0
                      ? _outputGreen.withOpacity(0.2)
                      : _outputRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exitCode == 0 ? '✓  Exit 0' : '✗  Exit $exitCode',
                  style: TextStyle(
                    color: exitCode == 0 ? _outputGreen : _outputRed,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          if (stdout.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              stdout,
              style: const TextStyle(
                color: _outputGreen,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          if (stderr.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              stderr,
              style: const TextStyle(
                color: _outputRed,
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
          if (stdout.isEmpty && stderr.isEmpty)
            const Text(
              '(no output)',
              style: TextStyle(
                color: Colors.white38,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutputContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
      color: const Color(0xFF11111B),
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(child: child),
    );
  }
}
