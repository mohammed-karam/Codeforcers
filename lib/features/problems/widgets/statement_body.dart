import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/features/problems/data/models/statement_model.dart';

class StatementBody extends StatelessWidget {
  const StatementBody({
    super.key,
    required this.statement,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final ProblemStatement statement;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (statement.timeLimit.isNotEmpty ||
              statement.memoryLimit.isNotEmpty) ...[
            _MetaChips(
              timeLimit: statement.timeLimit,
              memoryLimit: statement.memoryLimit,
            ),
            const SizedBox(height: 12),
          ],
          for (final block in statement.blocks) ...[
            _buildBlock(context, block),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildBlock(BuildContext context, StatementBlock block) {
    return switch (block) {
      StatementHeading(:final text, :final level) => Text(
          text,
          style: TextStyle(
            fontSize: level <= 2 ? 16 : 14.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.35,
          ),
        ),
      StatementParagraph(:final text) => Text(
          text,
          style: const TextStyle(
            fontSize: 14.5,
            color: AppColors.textPrimary,
            height: 1.55,
          ),
        ),
      StatementCode(:final text) => _CodeBox(text: text),
      StatementSample(:final input, :final output) =>
        _SampleBox(input: input, output: output),
      StatementList(:final items, :final ordered) =>
        _ListBlock(items: items, ordered: ordered),
      StatementImage(:final src) => _StatementImage(src: src),
    };
  }
}


class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.timeLimit, required this.memoryLimit});

  final String timeLimit;
  final String memoryLimit;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (timeLimit.isNotEmpty)
        _chip(Icons.timer_outlined, 'Time $timeLimit'),
      if (memoryLimit.isNotEmpty)
        _chip(Icons.memory_outlined, 'Memory $memoryLimit'),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.navy),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}


class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Color(0xFFCDD6F4),
          height: 1.5,
        ),
      ),
    );
  }
}


class _SampleBox extends StatelessWidget {
  const _SampleBox({required this.input, required this.output});

  final String input;
  final String output;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined,
                  size: 16, color: AppColors.navy),
              const SizedBox(width: 6),
              const Text(
                'Sample',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _CopyButton(
                label: 'Copy sample',
                value: 'Input\n$input\n\nOutput\n$output',
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ioLabel('Input'),
          _ioBox(input),
          const SizedBox(height: 10),
          _ioLabel('Output'),
          _ioBox(output),
        ],
      ),
    );
  }

  Widget _ioLabel(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      );

  Widget _ioBox(String value) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: SelectableText(
          value.isEmpty ? '(empty)' : value,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      );
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied.'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      icon: const Icon(Icons.copy_rounded, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
      ),
    );
  }
}


class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.items, required this.ordered});

  final List<String> items;
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    ordered ? '${i + 1}.' : '•',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


class _StatementImage extends StatelessWidget {
  const _StatementImage({required this.src});

  final String src;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        src,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 120,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Image unavailable offline',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
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
