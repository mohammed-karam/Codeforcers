sealed class StatementBlock {
  const StatementBlock();
}

class StatementHeading extends StatementBlock {
  const StatementHeading(this.text, {this.level = 2});

  final String text;
  final int level;
}

class StatementParagraph extends StatementBlock {
  const StatementParagraph(this.text);

  final String text;
}

class StatementCode extends StatementBlock {
  const StatementCode(this.text);

  final String text;
}

class StatementSample extends StatementBlock {
  const StatementSample({required this.input, required this.output});

  final String input;
  final String output;
}

class StatementImage extends StatementBlock {
  const StatementImage(this.src);

  final String src;
}

class StatementList extends StatementBlock {
  const StatementList(this.items, {this.ordered = false});

  final List<String> items;
  final bool ordered;
}

class ProblemStatement {
  const ProblemStatement({
    required this.title,
    required this.blocks,
    this.timeLimit = '',
    this.memoryLimit = '',
  });

  final String title;
  final String timeLimit;
  final String memoryLimit;
  final List<StatementBlock> blocks;

    String get plainText {
    final buffer = StringBuffer(title);
    if (timeLimit.isNotEmpty) buffer.write(' · time limit $timeLimit');
    if (memoryLimit.isNotEmpty) buffer.write(' · memory $memoryLimit');
    buffer.writeln();

    for (final block in blocks) {
      buffer.writeln();
      switch (block) {
        case StatementHeading(:final text):
          buffer.writeln(text);
        case StatementParagraph(:final text):
          buffer.writeln(text);
        case StatementCode(:final text):
          buffer.writeln(text);
        case StatementImage():
          continue;
        case StatementList(:final items, :final ordered):
          for (var i = 0; i < items.length; i++) {
            buffer.writeln(ordered ? '${i + 1}. ${items[i]}' : '- ${items[i]}');
          }
        case StatementSample(:final input, :final output):
          buffer.writeln('Input');
          buffer.writeln(input);
          buffer.writeln('Output');
          buffer.writeln(output);
      }
    }

    return buffer.toString().trim();
  }
}
