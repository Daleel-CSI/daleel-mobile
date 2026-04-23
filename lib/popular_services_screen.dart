import 'package:daleel/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_services_screen.dart';
import 'service_details_screen.dart';


class PopularServicesScreen extends StatefulWidget {
  const PopularServicesScreen({super.key});

  @override
  State<PopularServicesScreen> createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCategoriesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF379777),
              size: 24,
            ),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: Text(
              'الأكثر شيوعاً',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final categories = servicesProvider.categories;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final services = categories[category]!;
        return _buildCategorySection(category, services);
      },
    );
  }

  Widget _buildCategorySection(String category, List<ServiceItem> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 8),
        // عنوان القسم
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // الانتقال لصفحة القسم مع كل الخدمات
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryServicesScreen(
                      categoryTitle: category,
                      categoryIcon: _getCategoryIcon(category),
                      userName: 'المستخدم',
                    ),
                  ),
                );
              },
              child: const Text(
                'اظهار الكل',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF379777),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              category,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // الخدمات
        ...services.take(3).map((service) => _buildServiceCard(service)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return _AnimatedCard(
      onTap: () {
        // الانتقال لصفحة تفاصيل الخدمة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              serviceTitle: service.title,
              serviceDescription: service.description,
              steps: ServiceDetailsData.getStepsForService(service.title),
              comments: ServiceDetailsData.getMockComments(),
            ),
          ),
        );
      },
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // التقييم وعدد الخطوات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service.steps,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF379777).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '(±${_formatReviewCount(service.reviewCount)})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF379777),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.star,
                        color: Color(0xFF379777),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // عنوان الخدمة
            Text(
              service.title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 8),

            // المؤلف والمصدر
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  service.source,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.circle,
                  color: Color(0xFF379777),
                  size: 6,
                ),
                const SizedBox(width: 8),
                Text(
                  'بواسطة ${service.author}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

 String _getCategoryIcon(String category) {
    switch (category) {
      case 'الجيش':
        return 'assets/icons/army.svg';
      case 'التعليم':
        return 'assets/icons/Container-2.svg';
      case 'الصحة':
        return 'assets/icons/Container-8.svg';
      case 'النقل':
        return 'assets/icons/Container-15.svg';
      case 'السكن':
        return 'assets/icons/Container-7.svg';
      default:
        return 'assets/icons/Container-9.svg';
    }
  }
}

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
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _isPressed = false) : null,
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