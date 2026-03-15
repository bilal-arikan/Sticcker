import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../data/cache/sticker_cache.dart';
import '../../core/utils/error_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _tokenController = TextEditingController();
  bool _isValidating = false;
  String? _botName;
  int _cacheSizeMB = 0;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
    final token = ref.read(telegramTokenProvider);
    if (token != null) _tokenController.text = token;
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _loadCacheSize() async {
    final cache = await StickerCache.getInstance();
    final size = await cache.getCacheSizeMB();
    if (mounted) setState(() => _cacheSizeMB = size);
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context)!;
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme
          _SectionHeader(title: l.appearance),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l.darkTheme),
                  subtitle: Text(l.darkThemeSubtitle),
                  value: isDark,
                  onChanged: (val) => ref.read(themeProvider.notifier).state = val,
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l.language),
                  subtitle: Text(_getLocaleLabel(ref.watch(localeProvider), l)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context, ref),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.grid_view),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.gridColumns, style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 2),
                            Text(l.gridColumnsSubtitle,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                    )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 3, label: Text('3')),
                          ButtonSegment(value: 4, label: Text('4')),
                          ButtonSegment(value: 5, label: Text('5')),
                        ],
                        selected: {ref.watch(gridColumnsProvider)},
                        onSelectionChanged: (val) =>
                            ref.read(gridColumnsProvider.notifier).state = val.first,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Telegram
          _SectionHeader(title: l.telegramIntegration),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: l.botToken,
                      hintText: '123456:ABC-DEF...',
                      helperText: l.botTokenHelper,
                      suffixIcon: _isValidating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: _validateToken,
                            ),
                    ),
                    obscureText: true,
                  ),
                  if (_botName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text('Bot: @$_botName',
                            style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Cache
          _SectionHeader(title: l.cache),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: Text(l.cacheSize),
              subtitle: Text(l.cacheSizeUsing(_cacheSizeMB)),
              trailing: TextButton(
                onPressed: _clearCache,
                child: Text(l.clear),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About
          _SectionHeader(title: l.about),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sticcker'),
                  subtitle: const Text('v1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(l.openSourceLicenses),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) return;

    setState(() => _isValidating = true);

    try {
      final telegramService = ref.read(telegramServiceProvider);
      final botInfo = await telegramService.validateToken(token);
      ref.read(telegramTokenProvider.notifier).state = token;

      if (mounted) {
        setState(() {
          _botName = botInfo['username'];
          _isValidating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context)!.botConnected(botInfo['username']))),
        );
      }
    } catch (e, st) {
      if (mounted) {
        setState(() => _isValidating = false);
        showErrorDialog(context, e, st);
      }
    }
  }

  String _getLocaleLabel(Locale? locale, S l) {
    if (locale == null) return l.systemDefault;
    switch (locale.languageCode) {
      case 'tr':
        return l.turkish;
      case 'en':
        return l.english;
      case 'ru':
        return l.russian;
      case 'ko':
        return l.korean;
      case 'es':
        return l.spanish;
      case 'ja':
        return l.japanese;
      default:
        return locale.languageCode;
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l = S.of(context)!;
    final current = ref.read(localeProvider);

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.language),
        children: [
          RadioListTile<Locale?>(
            title: Text(l.systemDefault),
            value: null,
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.turkish),
            subtitle: const Text('Türkçe'),
            value: const Locale('tr'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.english),
            subtitle: const Text('English'),
            value: const Locale('en'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.russian),
            subtitle: const Text('Русский'),
            value: const Locale('ru'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.korean),
            subtitle: const Text('한국어'),
            value: const Locale('ko'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.spanish),
            subtitle: const Text('Español'),
            value: const Locale('es'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
          RadioListTile<Locale?>(
            title: Text(l.japanese),
            subtitle: const Text('日本語'),
            value: const Locale('ja'),
            groupValue: current,
            onChanged: (val) {
              ref.read(localeProvider.notifier).state = val;
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache() async {
    final l = S.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.clearCache),
        content: Text(l.clearCacheConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.clear, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cache = await StickerCache.getInstance();
      await cache.clearCache();
      await _loadCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.cacheCleared)),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
