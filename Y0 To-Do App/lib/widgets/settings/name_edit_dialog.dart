// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: const Text('تعديل اسم المستخدم'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'الاسم',
          hintText: 'أدخل اسمك',
          border: OutlineInputBorder(),
        ),
        textDirection: TextDirection.rtl,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              ref.read(settingsProvider.notifier).updateUserName(name);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تحديث اسم المستخدم')),
              );
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
