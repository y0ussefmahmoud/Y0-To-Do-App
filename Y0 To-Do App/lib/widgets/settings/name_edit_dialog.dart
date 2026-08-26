// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../providers/settings_provider.dart';

class NameEditDialog extends ConsumerStatefulWidget {
  const NameEditDialog({super.key});

  @override
  ConsumerState<NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends ConsumerState<NameEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(settingsProvider).userName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editNameTitle),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: context.l10n.userNameLabel,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              ref.read(settingsProvider.notifier).updateUserName(name);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.nameUpdated)),
              );
            }
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}
