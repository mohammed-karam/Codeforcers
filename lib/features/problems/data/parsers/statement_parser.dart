import 'package:codeforcers/features/problems/data/models/statement_model.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

class StatementParser {
  const StatementParser();

  ProblemStatement parse(String htmlSource) {
    final document = html_parser.parse(htmlSource);
    final root = document.querySelector('.problem-statement');
    if (root == null) {
      throw const FormatException(
        'This page did not contain a problem statement.',
      );
    }

    final header = root.querySelector('.header');

    final blocks = <StatementBlock>[];
    for (final child in root.children) {
      if (child.classes.contains('header')) continue;
      _collect(child, blocks);
    }

    return ProblemStatement(
      title: _clean(_raw(header?.querySelector('.title'))),
      timeLimit: _limit(header?.querySelector('.time-limit')),
      memoryLimit: _limit(header?.querySelector('.memory-limit')),
      blocks: blocks,
    );
  }

  
  void _collect(Element element, List<StatementBlock> out) {
    final tag = element.localName ?? '';
    final classes = element.classes;

    if (classes.contains('sample-tests')) {
      out.addAll(_samples(element));
      return;
    }

    if (tag == 'pre') {
      final text = _preText(element);
      if (text.isNotEmpty) out.add(StatementCode(text));
      return;
    }

    if (tag == 'p') {
      final text = _clean(_raw(element));
      if (text.isNotEmpty) out.add(StatementParagraph(text));
      return;
    }

    if (tag == 'ul' || tag == 'ol') {
      final items = <String>[];
      for (final child in element.querySelectorAll('li')) {
        final text = _clean(_raw(child));
        if (text.isNotEmpty) items.add(text);
      }
      if (items.isNotEmpty) {
        out.add(StatementList(items, ordered: tag == 'ol'));
      }
      return;
    }

    if (tag == 'img') {
      final src = _imageSrc(element);
      if (src != null) out.add(StatementImage(src));
      return;
    }

    if (tag == 'h1' ||
        tag == 'h2' ||
        tag == 'h3' ||
        tag == 'h4' ||
        classes.contains('section-title')) {
      final text = _clean(_raw(element));
      if (text.isNotEmpty) out.add(StatementHeading(text));
      return;
    }

    if (tag == 'div' || tag == 'section' || tag == 'article' || tag == 'main') {
      for (final child in element.children) {
        _collect(child, out);
      }
      return;
    }

            final text = _clean(_raw(element));
    if (text.isNotEmpty) out.add(StatementParagraph(text));

    var keptImage = false;
    for (final img in element.querySelectorAll('img')) {
      final src = _imageSrc(img);
      if (src == null) continue;
      out.add(StatementImage(src));
      keptImage = true;
    }

    if (text.isEmpty && !keptImage) {
      for (final child in element.children) {
        _collect(child, out);
      }
    }
  }

  
  List<StatementBlock> _samples(Element sampleTests) {
    final blocks = <StatementBlock>[];

    for (final sample in sampleTests.querySelectorAll('.sample-test')) {
      final inputs = sample.querySelectorAll('.input');
      final outputs = sample.querySelectorAll('.output');
      final count =
          inputs.length > outputs.length ? inputs.length : outputs.length;

      for (var i = 0; i < count; i++) {
        blocks.add(
          StatementSample(
            input: i < inputs.length ? _sampleText(inputs[i]) : '',
            output: i < outputs.length ? _sampleText(outputs[i]) : '',
          ),
        );
      }
    }

    return blocks;
  }

  String _sampleText(Element container) {
    final pre = container.querySelector('pre');
    if (pre == null) return _clean(_raw(container));
    return _preText(pre);
  }

  
    String _preText(Element pre) {
    final lineDivs = pre.querySelectorAll('div');
    var text = _raw(pre).replaceAll('\u00a0', ' ');

    if (lineDivs.isNotEmpty && !text.contains('\n')) {
      text = lineDivs
          .map((line) => _raw(line).replaceAll('\u00a0', ' '))
          .join('\n');
    }

    final lines = text.split('\n').map((line) => line.trimRight()).toList();
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    return lines.join('\n');
  }

  String _raw(Node? node) {
    if (node == null) return '';
    if (node is Text) return node.text;
    if (node is Element) {
      if (node.localName == 'br') return '\n\n';
      return node.nodes.map(_raw).join();
    }
    return '';
  }

  String? _imageSrc(Element img) {
    final src = img.attributes['src'];
    if (src == null || src.trim().isEmpty) return null;
    if (src.startsWith('//')) return 'https:$src';
    if (src.startsWith('http://') || src.startsWith('https://')) return src;
    if (src.startsWith('/')) return 'https://codeforces.com$src';
    return 'https://codeforces.com/$src';
  }

  String _limit(Element? element) {
    if (element == null) return '';
    var text = _clean(_raw(element));

    final property = element.querySelector('.property-title');
    if (property != null) {
      final label = _clean(_raw(property));
      if (label.isNotEmpty && text.startsWith(label)) {
        text = text.substring(label.length).trim();
      }
    }
    return text;
  }

      String _clean(String source) {
    var text = source.replaceAll('\u00a0', ' ');
    text = _stripTex(text);

    final paragraphs = text
        .split(RegExp(r'\n{2,}'))
        .map((part) => part.replaceAll('\n', ' '))
        .map((part) => part.replaceAll(RegExp(r'[ \t]+'), ' '))
                .map((part) => part.replaceAll(RegExp(r'\( +'), '('))
        .map(
          (part) => part.replaceAllMapped(
            RegExp(r' +([.,;:!?%)\]])'),
            (match) => match.group(1)!,
          ),
        )
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return paragraphs.join('\n\n');
  }

              String _stripTex(String text) {
    var result = text
        .replaceAllMapped(_mathChunk, (match) => ' ${match.group(1)} ')
        .replaceAllMapped(_mathPair, (match) => ' ${match.group(1)} ');

    result = _expandFractions(result);

    result = result
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll(r'\\', ' ');

    result = result.replaceAllMapped(_symbolPattern, (match) {
      return _texSymbols[match.group(0)] ?? '';
    });

        result = result.replaceAllMapped(
      RegExp(r'\\([a-zA-Z]+)'),
      (match) => match.group(1)!,
    );

    return result.replaceAll('{', '').replaceAll('}', '');
  }

    static final RegExp _mathChunk = RegExp(
    r'\$\$\$(.+?)\$\$\$',
    dotAll: true,
  );

    static final RegExp _mathPair = RegExp(r'\$\$(.+?)\$\$', dotAll: true);

      static final RegExp _symbolPattern = RegExp(
    _texSymbols.keys
        .map((command) => '${RegExp.escape(command)}(?![a-zA-Z])')
        .join('|'),
  );

  static const List<String> _fractionCommands = <String>[
    r'\frac',
    r'\dfrac',
    r'\tfrac',
    r'\cfrac',
  ];

    static String _expandFractions(String source) {
    var result = source;

    for (final command in _fractionCommands) {
      var index = result.indexOf(command);
      while (index != -1) {
        final afterCommand = index + command.length;
        final first = _group(result, afterCommand);
        if (first == null) {
          result = result.replaceRange(index, afterCommand, '');
          index = result.indexOf(command, index);
          continue;
        }

        final second = _group(result, first.end);
        final replacement = second == null
            ? '(${_expandFractions(first.text)})'
            : '(${_expandFractions(first.text)})/'
                '(${_expandFractions(second.text)})';
        final end = second == null ? first.end : second.end;

        result = result.replaceRange(index, end, replacement);
        index = result.indexOf(command, index + replacement.length);
      }
    }

    return result;
  }

    static ({String text, int end})? _group(String source, int start) {
    if (start >= source.length || source[start] != '{') return null;

    var depth = 0;
    for (var i = start; i < source.length; i++) {
      final character = source[i];
      if (character == '{') {
        depth++;
      } else if (character == '}') {
        depth--;
        if (depth == 0) {
          return (text: source.substring(start + 1, i), end: i + 1);
        }
      }
    }
    return null;
  }

  static const Map<String, String> _texSymbols = <String, String>{
    r'\displaystyle': '',
    r'\text': '',
    r'\left': '',
    r'\right': '',
    r'\infty': '∞',
    r'\times': '×',
    r'\cdot': '·',
    r'\sqrt': '√',
    r'\sum': 'Σ',
    r'\prod': '∏',
    r'\int': '∫',
    r'\neq': '≠',
    r'\geq': '≥',
    r'\leq': '≤',
    r'\pi': 'π',
    r'\div': '÷',
    r'\ge': '≥',
    r'\le': '≤',
    r'\ne': '≠',
    r'\in': '∈',
    r'\lt': '<',
    r'\gt': '>',
    r'\approx': '≈',
    r'\equiv': '≡',
    r'\propto': '∝',
    r'\pm': '±',
    r'\mp': '∓',
    r'\Rightarrow': '⇒',
    r'\rightarrow': '→',
    r'\leftarrow': '←',
    r'\to': '→',
    r'\ldots': '…',
    r'\dots': '…',
    r'\cdots': '…',
    r'\cup': '∪',
    r'\cap': '∩',
    r'\subseteq': '⊆',
    r'\subset': '⊂',
    r'\supseteq': '⊃',
    r'\forall': '∀',
    r'\exists': '∃',
    r'\emptyset': '∅',
    r'\alpha': 'α',
    r'\beta': 'β',
    r'\gamma': 'γ',
    r'\delta': 'δ',
    r'\Delta': 'Δ',
    r'\theta': 'θ',
    r'\lambda': 'λ',
    r'\mu': 'μ',
    r'\sigma': 'σ',
    r'\Sigma': 'Σ',
    r'\phi': 'φ',
    r'\omega': 'ω',
    r'\Omega': 'Ω',
    r'\,': ' ',
    r'\;': ' ',
    r'\!': '',
  };
}
