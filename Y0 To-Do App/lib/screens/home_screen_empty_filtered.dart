import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/haptic_service.dart';

import '../models/task_filter.dart';
import '../providers/task_provider.dart';

class EmptyFilteredState extends StatefulWidget {
  const EmptyFilteredState({super.key});

  @override
  State<EmptyFilteredState> createState() => _EmptyFilteredStateState();
}

class _EmptyFilteredStateState extends State<EmptyFilteredState> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon for Search Empty
                SizedBox(
                  width: 200,
                  height: 200,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.search_ellipsis,
                    progress: _animationController,
                    size: 80,
                    color: const Color(0xFF64748B),
                  ),
                ).animate().scale(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Gradient Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
              ).createShader(bounds),
              child: Text(
                'لا توجد مهام تطابق الفلاتر! 🔍',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            Text(
              'جرب تعديل الفلاتر أو إعادة تعيينها\nلعرض جميع المهام',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 32),
            
            // Enhanced Button with Gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF64748B).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticService.medium();
                  ref.read(taskFilterProvider.notifier).state = const TaskFilter();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة تعيين الفلاتر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
            
            const SizedBox(height: 24),
            
            // Tips Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Color(0xFF64748B)),
                      SizedBox(width: 8),
                      Text(
                        'نصيحة البحث',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '💡 يمكنك استخدام البحث للعثور على مهام محددة بسرعة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
      },
    );
  }
}
