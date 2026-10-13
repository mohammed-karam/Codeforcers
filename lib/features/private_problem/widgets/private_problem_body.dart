import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:codeforcers/core/widgets/scale_tap.dart';
import 'package:codeforcers/features/private_problem/data/browse_target.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivateProblemBody extends StatefulWidget {
  const PrivateProblemBody({super.key});

  @override
  State<PrivateProblemBody> createState() => _PrivateProblemBodyState();
}

class _PrivateProblemBodyState extends State<PrivateProblemBody> {
  final TextEditingController _address = TextEditingController();
  final FocusNode _addressFocus = FocusNode();

      WebViewController? _web;
  Uri? _target;

        double _webShare = _defaultShare;

  static const double _defaultShare = 0.55;

        static const double _outsideTheSplit = 301;

        double get _pageChrome => 96 + (_hasBrowser ? 40 : 0);

      static const double _pageStrip = 40;
  static const double _editorStrip = 60;

  bool get _hasBrowser => _web != null;

  @override
  void initState() {
    super.initState();

            if (WebViewPlatform.instance == null) return;

    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => _syncAddress(url),
          onUrlChange: (change) => _syncAddress(change.url ?? ''),
        ),
      )
      ..loadRequest(_home);

    _target = _home;
    _address.text = _home.toString();
  }

  @override
  void dispose() {
    _address.dispose();
    _addressFocus.dispose();
    _web = null;
    super.dispose();
  }

  static final Uri _home = buildBrowseUri('');

  void _syncAddress(String url) {
    if (url.isEmpty || !mounted) return;
        if (_addressFocus.hasFocus) return;
    _target = Uri.tryParse(url);
    _address.text = url;
  }

  void _go() {
    final uri = buildBrowseUri(_address.text);
    FocusScope.of(context).unfocus();
    setState(() {
      _target = uri;
      _address.text = uri.toString();
    });
    _web?.loadRequest(uri);
  }

          (double, double) _shareRange(BuildContext context) {
    final free = MediaQuery.sizeOf(context).height - _outsideTheSplit;
    if (free <= 0) return (_defaultShare, _defaultShare);

    var low = (_pageChrome + _pageStrip) / free;
    var high = 1 - _editorStrip / free;
    low = low.clamp(0.1, 0.8);
    high = high.clamp(0.2, 0.9);

        if (low > high) return (low, low);
    return (low, high);
  }

          int _flexFor(double share) {
    final ratio = share / (1 - share);
    return (ratio * 100).round().clamp(10, 900);
  }

  @override
  Widget build(BuildContext context) {
    final range = _shareRange(context);
    final share = _webShare.clamp(range.$1, range.$2);

    return Expanded(
      flex: _flexFor(share),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildAddressBar(),
            if (_hasBrowser) ...[
              const SizedBox(height: 8),
              _buildToolbar(),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: _hasBrowser
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ColoredBox(
                        color: Colors.white,
                        child: WebViewWidget(controller: _web!),
                      ),
                    )
                  : _FallbackCard(target: _target),
            ),
            Row(
              children: [
                _tool(
                  key: const Key('private-problem-max-page'),
                  icon: Icons.language_rounded,
                  tooltip: 'Maximize the page',
                  enabled: share < range.$2,
                  onTap: () => setState(() => _webShare = range.$2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DragHandle(
                    key: const Key('private-problem-resize'),
                                                            onDrag: (deltaY) => setState(
                      () => _webShare = (_webShare + deltaY * 0.0018)
                          .clamp(range.$1, range.$2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _tool(
                  key: const Key('private-problem-max-editor'),
                  icon: Icons.code_rounded,
                  tooltip: 'Maximize the editor',
                  enabled: share > range.$1,
                  onTap: () => setState(() => _webShare = range.$1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildAddressBar() {
    return TextField(
      controller: _address,
      focusNode: _addressFocus,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      onSubmitted: (_) => _go(),
      decoration: InputDecoration(
        hintText: 'Paste a link or type a name',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: IconButton(
          tooltip: 'Go',
          onPressed: _go,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.navy),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );

  Widget _buildToolbar() {
    return Row(
      children: [
        _tool(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back',
          onTap: () => _web?.goBack(),
        ),
        const SizedBox(width: 6),
        _tool(
          icon: Icons.arrow_forward_rounded,
          tooltip: 'Forward',
          onTap: () => _web?.goForward(),
        ),
        const SizedBox(width: 6),
        _tool(
          icon: Icons.refresh_rounded,
          tooltip: 'Reload',
          onTap: () => _web?.reload(),
        ),
        const SizedBox(width: 6),
        _tool(
          icon: Icons.open_in_new_rounded,
          tooltip: 'Open outside',
          onTap: () => _openOutside(_target ?? buildBrowseUri(_address.text)),
        ),
      ],
    );
  }

  Widget _tool({
    Key? key,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      key: key,
            opacity: enabled ? 1 : 0.35,
      child: Tooltip(
        message: tooltip,
        child: ScaleTap(
          semanticsLabel: tooltip,
          onTap: onTap,
          child: Container(
            width: 34,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Icon(icon, size: 17, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}


class _DragHandle extends StatelessWidget {
  const _DragHandle({super.key, required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
      child: SizedBox(
        height: 34,
        child: Center(
          child: Container(
            width: 46,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}


class _FallbackCard extends StatelessWidget {
  const _FallbackCard({this.target});

  final Uri? target;

  @override
  Widget build(BuildContext context) {
    final shown = target;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.travel_explore_rounded,
              size: 30,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            const Text(
              'Pages open inside the app on your phone.\nHere, they open in your own browser.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            if (shown != null) ...[
              const SizedBox(height: 10),
              Text(
                shown.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openOutside(shown),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text(
                  'Open in your browser',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _openOutside(Uri uri) async {
  await launchUrl(uri, mode: LaunchMode.platformDefault);
}
