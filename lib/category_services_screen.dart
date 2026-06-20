// lib/screens/category_services_screen.dart
import 'package:daleel/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:daleel/api/api_service.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';

class CategoryServicesScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String categoryIcon;
  final String userName;

  const CategoryServicesScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.userName,
  });

  @override
  State<CategoryServicesScreen> createState() => _CategoryServicesScreenState();
}

class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  List<ServiceItem> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final token = context.read<UserProvider>().user.token;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final servicesJson = await ApiService.getServicesByCategoryId(
      categoryId: widget.categoryId,
      token: token,
    );

    if (!mounted) return;

    if (servicesJson != null) {
      setState(() {
        _services = servicesJson
            .map((json) => ServiceItem.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'فشل تحميل الخدمات';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF379777)))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchServices,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        )
                      : _services.isEmpty
                          ? Center(
                              child: Text('لا توجد خدمات في هذا القسم',
                                  style: TextStyle(
                                      color: Colors.grey.shade600)))
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _services.length,
                              itemBuilder: (context, index) =>
                                  _buildServiceCard(_services[index]),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios,
                color: Color(0xFF379777), size: 24),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.categoryTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '${_services.length} خدمة متاحة',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFB2E4D0).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: widget.categoryIcon.isNotEmpty
                  ? SvgPicture.asset(
                      widget.categoryIcon,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF379777), BlendMode.srcIn),
                      placeholderBuilder: (context) => const Icon(
                          Icons.category, size: 28, color: Color(0xFF379777)),
                    )
                  : const Icon(Icons.category, size: 28, color: Color(0xFF379777)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return _AnimatedServiceCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              serviceTitle: service.title,
              serviceDescription: service.description,
              steps: ServiceDetailsData.getStepsForService(service.title),
              comments: ServiceDetailsData.getMockComments(),
              serviceId: service.id,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // الصف الأول (عدد الخطوات + حفظ + تقييم)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.steps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<ServicesProvider>(
                      builder: (context, provider, child) {
                        final isSaved = service.isSaved;
                        return InkWell(
                          onTap: () => provider.toggleSaveService(service.id),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? const Color(0xFF379777).withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              isSaved
                                  ? 'assets/icons/Bookmark.svg'
                                  : 'assets/icons/bookmark-add-02.svg',
                              width: 22,
                              height: 22,
                              colorFilter: const ColorFilter.mode(
                                  Color(0xFF379777), BlendMode.srcIn),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF379777).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '(±${_formatReviewCount(service.reviewCount)})',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade700),
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
                          const Icon(Icons.star,
                              color: Color(0xFF379777), size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // العنوان
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

            // الوصف
            Text(
              service.description,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // ========== الصف السفلي (الذي يسبب التجاوز) ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '(${service.views ~/ 1000}K+ حضور)',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Color(0xFF379777), size: 6),
                const SizedBox(width: 8),
                // المصدر – الآن مغلف بـ Flexible لمنع التجاوز
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Color(0xFF379777), size: 6),
                const SizedBox(width: 8),
                Text(
                  'بواسطة ${service.author}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700),
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
}

class _AnimatedServiceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedServiceCard({required this.child, required this.onTap});
  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xFF379777).withOpacity(0.2)
                    : Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.3
                            : 0.06),
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