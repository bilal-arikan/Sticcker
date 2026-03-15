import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

void showErrorDialog(BuildContext context, Object error, [StackTrace? stackTrace]) {
  final l = S.of(context)!;
  final errorText = error.toString().replaceFirst('Exception: ', '');
  final fullError = stackTrace != null
      ? '$errorText\n\n${stackTrace.toString().split('\n').take(10).join('\n')}'
      : errorText;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.error_outline, color: Colors.red, size: 36),
      title: Text(l.error),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                errorText,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 12),
                Text(
                  l.errorDetails,
                  style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SelectableText(
                    stackTrace.toString().split('\n').take(10).join('\n'),
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: fullError));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.copiedToClipboard),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: const Icon(Icons.copy, size: 16),
          label: Text(l.copy),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l.ok),
        ),
      ],
    ),
  );
}
