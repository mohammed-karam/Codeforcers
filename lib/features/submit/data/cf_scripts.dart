import 'dart:convert';


String cfLanguageHint(String displayName) => switch (displayName) {
      'C++' => 'cpp',
      'C' => 'c',
      'Python 3' => 'python3',
      'Java' => 'java',
      'Rust' => 'rust',
      'Go' => 'go',
      'C#' => 'csharp',
      _ => '',
    };

String cfPrefillScript({
  required String problemCode,
  required String source,
  required String language,
}) {
  return r'''
(function () {
  var post = function (payload) {
    try { CfSubmit.postMessage(JSON.stringify(payload)); } catch (e) {}
  };
  var fire = function (el) {
    try {
      el.dispatchEvent(new Event('input', { bubbles: true }));
      el.dispatchEvent(new Event('change', { bubbles: true }));
    } catch (e) {}
  };
  var out = { step: 'prefill', problem: false, language: false, source: false, chosen: '' };

  var code = '''+ jsonEncode(problemCode) + r''';
  var src = '''+ jsonEncode(source) + r''';

  // The code lives in a textarea even while the Ace editor is on screen, so
  // fill both and let Codeforces' own change handler keep them in step.
  var area = document.querySelector('textarea[name=source], #sourceCodeTextarea');
  if (area) {
    area.value = src;
    fire(area);
    out.source = true;
    try {
      if (window.ace && document.getElementById('editor')) {
        window.ace.edit('editor').setValue(src, -1);
      }
    } catch (e) {}
  }

  // The problem: the problemset submit page carries it as a text field
  // holding "1850C"; a contest submit page uses a dropdown of indexes.
  var field = document.querySelector('input[name=submittedProblemCode]');
  if (field) {
    field.value = code;
    fire(field);
    out.problem = true;
  } else {
    var select = document.querySelector('select[name=submittedProblemIndex]');
    if (select) {
      var wanted = code.replace(/^[0-9]+/, '');
      for (var i = 0; i < select.options.length; i++) {
        if (select.options[i].value === wanted) {
          select.selectedIndex = i;
          fire(select);
          out.problem = true;
          break;
        }
      }
    }
  }

  // The language: newest matching option wins, because Codeforces lists its
  // compilers oldest first and retires the old ones over time.
  var hint = '''+ jsonEncode(language) + r''';
  var langSelect = document.querySelector('select[name=programTypeId]');
  if (langSelect && hint) {
    var patterns = {
      cpp: [/GNU G\+\+2/i, /G\+\+17/i, /Clang\+\+17/i, /\+\+/],
      c: [/^GNU C[0-9]/i, /^Clang C/i, /^C[0-9]/],
      python3: [/^Python 3/i],
      java: [/^Java 1/i, /^Java /i],
      rust: [/^Rust/i],
      go: [/^Go /i, /^Go$/i],
      csharp: [/^C#/i]
    };
    var rules = patterns[hint] || [];
    var chosen = null;
    for (var r = 0; r < rules.length && !chosen; r++) {
      for (var j = langSelect.options.length - 1; j >= 0; j--) {
        if (rules[r].test(langSelect.options[j].text)) {
          chosen = langSelect.options[j];
          break;
        }
      }
    }
    if (chosen) {
      langSelect.value = chosen.value;
      fire(langSelect);
      out.language = true;
      out.chosen = chosen.text;
    }
  }

  post(out);
  return JSON.stringify(out);
})();
''';
}

String cfClickSubmitScript() => r'''
(function () {
  var post = function (payload) {
    try { CfSubmit.postMessage(JSON.stringify(payload)); } catch (e) {}
  };
  var button = document.querySelector(
    'form.submit-form input.submit, .submit-form input[type=submit], input.submit[type=submit]'
  );
  if (!button) {
    post({ step: 'click', ok: false, why: 'The Submit button is not on this page yet.' });
    return 'missing';
  }
  if (button.disabled) {
    post({ step: 'click', ok: false, why: 'Codeforces has not enabled Submit yet — pick the problem on the page.' });
    return 'disabled';
  }
  button.click();
  post({ step: 'click', ok: true });
  return 'ok';
})();
''';
