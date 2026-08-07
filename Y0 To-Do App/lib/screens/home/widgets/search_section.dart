// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/y0_design_system.dart';
import '../../../widgets/neo_morphic_card.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/task_provider.dart';

class SearchSection extends ConsumerStatefulWidget {
  const SearchSection({super.key});

  @override
  ConsumerState<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends ConsumerState<SearchSection> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search Bar
        NeoMorphicCard(
          isInset: true,
          padding: const EdgeInsets.symmetric(
            horizontal: Y0DesignSystem.spacing3,
            vertical: Y0DesignSystem.spacing3,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.search,
                color: context.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: Y0DesignSystem.spacing2),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: context.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مهمة...',
                    hintStyle: TextStyle(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    ref.read(searchProvider.notifier).updateQuery(
                      value,
                      ref.read(tasksProvider),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Y0DesignSystem.spacing2),
        // Quick Filter Tags - Horizontal Scrollable
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            children: [
              'أولوية عالية',
              'مهام اليوم',
              'متأخرة',
              'العمل',
              'الدراسة',
            ].map((tag) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  ref.read(searchProvider.notifier).updateQuery(
                    tag,
                    ref.read(tasksProvider),
                  );
                },
                child: NeoMorphicCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Y0DesignSystem.spacing2,
                    vertical: 4,
                  ),
                  child: Text(
                    tag,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
