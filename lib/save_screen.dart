import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:daleel/api/api_service.dart';            // لاستدعاء API الحذف
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';     // للحصول على التوكن
import 'package:daleel/service_details_screen.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  bool _isDeleting = false;   // لمؤشر التحميل أثناء الحذف

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<TripsProvider>(
                builder: (context, tripsProvider, child) {
                  final trips = tripsProvider.savedTrips;

                  if (trips.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      return _buildTripCard(trips[index], index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'مشاويري',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/Bookmark.svg',
              color: Color(0xFF379777),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مشاوير محفوظة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابحث عن الخدمات واحفظها هنا',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ استخدام بيانات الرحلة الحقيقية (trip.steps) بدل البيانات الوهمية
    final actualSteps = trip.steps.isNotEmpty
        ? List.generate(trip.steps.length, (i) => ServiceStep(
              title: trip.steps[i].title,
              location: '',
              description: trip.steps[i].description,
              isCompleted: i < trip.completedSteps,
            ))
        : <ServiceStep>[];
    final totalSteps = trip.totalSteps > 0 ? trip.totalSteps : actualSteps.length;
    final completedSteps = trip.completedSteps;

    return _AnimatedCard(
      onTap: () {
        // فتح تفاصيل الخدمة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              serviceTitle: trip.title,
              serviceDescription: trip.description ?? trip.category,
              steps: actualSteps,
              comments: const [],
              serviceId: trip.id,   // المعرف الفريد للمشوار
            ),
          ),
        );
      },
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // الصف الأول: العنوان والدائرة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // دائرة التقدم
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: totalSteps > 0
                                ? completedSteps / totalSteps
                                : 0.0,
                            strokeWidth: 5,
                            backgroundColor: const Color(0xFFE8F5E9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF379777),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '$completedSteps/$totalSteps',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF379777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // العنوان والتاريخ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trip.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trip.date,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // الخطوة الحالية
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر الحذف
                  InkWell(
                    onTap: () => _showDeleteDialog(trip),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: SvgPicture.asset(
                        'assets/icons/bookmark-minus-02.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      trip.currentStep,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== مربع حوار الحذف مع ربط DELETE API ==========
  void _showDeleteDialog(Trip trip) {
    showDialog(
      context: context,
      barrierDismissible: !_isDeleting,  // لا يُغلق أثناء الحذف
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: AlertDialog(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: const Color(0xFF379777).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                title: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade500,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حذف المشوار',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'هل أنت متأكد من حذف هذا المشوار؟',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'لن تتمكن من استرجاعه مرة أخرى',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (_isDeleting) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(
                          color: Color(0xFF379777)),
                    ],
                  ],
                ),
                actionsPadding: const EdgeInsets.all(20),
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                              _isDeleting ? null : () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor:
                                const Color(0xFF379777).withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF379777),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isDeleting
                              ? null
                              : () => _deleteTrip(ctx, trip, setDialogState),
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.red.shade500,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'حذف',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTrip(
    BuildContext dialogContext,
    Trip trip,
    StateSetter setDialogState,
  ) async {
    setDialogState(() => _isDeleting = true);

    // استدعاء DELETE من الخادم
    final token = context.read<UserProvider>().user.token;
    final success = await ApiService.deleteService(
      serviceId: trip.id,
      token: token,
    );

    if (!mounted) return;

    if (success) {
      // حذف من القائمة المحلية
      Provider.of<TripsProvider>(context, listen: false)
          .removeTrip(trip.id);
      // ignore: use_build_context_synchronously
      Navigator.pop(dialogContext); // إغلاق الحوار

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'تم حذف المشوار بنجاح',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF379777),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      setDialogState(() => _isDeleting = false); // نعطي فرصة للإعادة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل حذف المشوار من الخادم، حاول مجدداً'),
          backgroundColor: Colors.red.shade500,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  AnimatedCard helper
// ═══════════════════════════════════════════════════════════

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const _AnimatedCard({
    required this.child,
    this.onTap,
    this.margin,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xFF379777).withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}