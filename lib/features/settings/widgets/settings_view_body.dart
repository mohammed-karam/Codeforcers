import 'package:codeforcers/core/storage/app_settings.dart';
import 'package:codeforcers/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsViewBody extends StatefulWidget {
  const SettingsViewBody({super.key});

  @override
  State<SettingsViewBody> createState() => _SettingsViewBodyState();
}

class _SettingsViewBodyState extends State<SettingsViewBody> {
  static const Color _amber = Color(0xFFB45309);

  late final TextEditingController _keyController;
  late final TextEditingController _modelController;
  late final TextEditingController _handleController;

  bool _obscureKey = true;
  bool _hasKey = true;

  @override
  void initState() {
    super.initState();
    final settings = AppSettings.instance;
    _keyController = TextEditingController(text: settings.groqApiKey);
    _modelController = TextEditingController(text: settings.groqModel);
    _handleController = TextEditingController(text: settings.codeforcesHandle);
    _hasKey = settings.hasGroqApiKey;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final settings = AppSettings.instance;
    await settings.setGroqApiKey(_keyController.text);
    await settings.setGroqModel(_modelController.text);
    await settings.setCodeforcesHandle(_handleController.text);

    if (!mounted) return;
    setState(() => _hasKey = settings.hasGroqApiKey);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved on this device.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your setup',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'These values are stored on this device only. The app ships with '
            'no shared API key.',
            style: TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  icon: Icons.key_rounded,
                  color: _amber,
                  title: 'Groq API key',
                  caption: 'Powers the AI Answer Checker',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyController,
                  obscureText: _obscureKey,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (_) => setState(
                    () => _hasKey = _keyController.text.trim().isNotEmpty,
                  ),
                  decoration: InputDecoration(
                    labelText: 'gsk_...',
                    hintText: 'Paste your Groq API key',
                    helperText: _hasKey
                        ? 'A key is saved on this device.'
                        : 'No key yet — the checker will ask for one.',
                    helperMaxLines: 2,
                    filled: true,
                    fillColor: AppColors.background,
                    suffixIcon: IconButton(
                      tooltip: _obscureKey ? 'Show key' : 'Hide key',
                      onPressed: () =>
                          setState(() => _obscureKey = !_obscureKey),
                      icon: Icon(
                        _obscureKey
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse('https://console.groq.com/keys'),
                      mode: LaunchMode.platformDefault,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 15),
                    label: const Text(
                      'Get a free key at console.groq.com',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: 'Model',
                    hintText: AppSettings.defaultGroqModel,
                    helperText: 'Leave empty to keep the default model.',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  icon: Icons.alternate_email_rounded,
                  color: AppColors.navy,
                  title: 'Codeforces handle',
                  caption: 'Shown on your profile and used for your stats',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _handleController,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: 'Handle',
                    hintText: 'e.g. Karam',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text(
                'Save settings',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B3B6F),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String caption,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
