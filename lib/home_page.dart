import 'package:daleel/all_categories_screen.dart';
import 'package:daleel/profile_screen.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/discover_screen.dart';
import 'package:daleel/search_results_screen.dart';
import 'package:daleel/popular_services_screen.dart';
import 'package:daleel/category_services_screen.dart';
import 'package:daleel/notifications_screen.dart';
import 'package:daleel/ai_chat_screen.dart';
import 'package:daleel/service_details_screen.dart';
import 'package:daleel/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final bool showWelcome;
  final String? welcomeName;

  const HomePage({super.key, this.showWelcome = false, this.welcomeName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  int _selectedBottomIndex = 0;
  int _unreadNotificationsCount = 0;

  List<ServiceItem> _popularServices = [];
  bool _isLoadingPopular = false;
  String? _popularError;

  @override
  void initState() {
    super.initState();
    if (widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'أهلاً بك يا ${widget.welcomeName}! 🎉',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF379777),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
    Future.microtask(() async {
      // ignore: use_build_context_synchronously
      final token = context.read<UserProvider>().user.token;
      // ignore: use_build_context_synchronously
      final provider = context.read<ServicesProvider>();
      if (provider.categoriesList.isEmpty) {
        await provider.fetchCategories(token: token);
      }
      try {
        await provider.fetchAndSetServices(token: token);
      } catch (e) {
        debugPrint('❌ Error loading services in HomePage: $e');
      }
    });
    _fetchPopularServices();
  }

  Future<void> _fetchPopularServices() async {
    final token = context.read<UserProvider>().user.token;
    setState(() {
      _isLoadingPopular = true;
      _popularError = null;
    });

    final popularJson = await ApiService.getPopularServices(token: token);

    if (!mounted) return;

    if (popularJson != null) {
      setState(() {
        _popularServices =
            popularJson.map((json) => ServiceItem.fromJson(json)).toList();
        _isLoadingPopular = false;
      });
    } else {
      setState(() {
        _popularError = 'فشل تحميل الخدمات الأكثر شيوعاً';
        _isLoadingPopular = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchResultsScreen(initialQuery: _searchController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final userName = user.displayName ?? user.email?.split('@').first ?? 'مستخدم';
    final servicesProvider = context.watch<ServicesProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedBottomIndex),
          index: _selectedBottomIndex,
          children: [
            servicesProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF379777),
                    ),
                  )
                : _buildHomeContent(userName),
            DiscoverScreen(userName: userName),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton:
          _selectedBottomIndex == 0 ? _buildAIChatFAB() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildHomeContent(String userName) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(userName),
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildDiscoverSection(userName),
                  const SizedBox(height: 30),
                  _buildPopularSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== الهيدر (معدل لإصلاح التجاوز) ==========
  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNotificationBell(),
          Expanded(  // ✅ إضافة Expanded لمنع التجاوز
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(  // ✅ استخدام Flexible للنص الطويل
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF379777),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'مرحبا',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasNotifications = _unreadNotificationsCount > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const NotificationsScreen()),
        ).then((_) {
          setState(() {
            _unreadNotificationsCount = 0;
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              'assets/icons/notification.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                hasNotifications
                    ? const Color(0xFF379777)
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                BlendMode.srcIn,
              ),
            ),
            if (hasNotifications)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                      minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      _unreadNotificationsCount > 9
                          ? '9+'
                          : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: _openSearch,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade600,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (context) => Icon(Icons.search,
                        color: Colors.grey.shade600, size: 22),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Text(
                      'تجديد بطاقة، رخصة، قيد عائلي   ابحث عن مشوارك',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== قسم "اكتشف مشاوير جديدة" ==========
  Widget _buildDiscoverSection(String userName) {
    final categories = context.watch<ServicesProvider>().categoriesList;
    final displayCategories = categories.length >= 6 ? categories.sublist(0, 6) : categories;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (categories.isNotEmpty)
                _AnimatedButton(
                  text: 'اظهار الكل',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AllCategoriesScreen(userName: userName),
                      ),
                    );
                  },
                )
              else
                const SizedBox.shrink(),
              Text(
                'اكتشف مشاوير جديدة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (categories.isEmpty)
            const Center(child: CircularProgressIndicator(color: Color(0xFF379777)))
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: displayCategories.map((category) {
                return _buildServiceCard(
                  category.name,
                  category.iconPath.isNotEmpty ? category.iconPath : 'assets/icons/more.svg',
                  userName,
                  categoryId: category.id,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String svgPath,
    String userName, {
    required String categoryId,
    bool isMore = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _ClickableServiceCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryServicesScreen(
              categoryId: categoryId,
              categoryTitle: title,
              categoryIcon: svgPath,
              userName: userName,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isMore
                  ? (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100)
                  : const Color(0xFFB2E4D0).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isMore
                  ? const Icon(Icons.more_horiz,
                      size: 28, color: Color(0xFF379777))
                  : SvgPicture.asset(
                      svgPath,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF379777), BlendMode.srcIn),
                      placeholderBuilder: (context) =>
                          const Icon(Icons.category, color: Color(0xFF379777)),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== قسم "الأكثر شيوعاً" ==========
  Widget _buildPopularSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedButton(
                text: 'اظهار الكل',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PopularServicesScreen()),
                  );
                },
              ),
              Text(
                'الأكثر شيوعاً',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingPopular
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(color: Color(0xFF379777)),
                  ),
                )
              : _popularError != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(_popularError!,
                                style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          ElevatedButton(
                            onPressed: _fetchPopularServices,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF379777),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('إعادة المحاولة',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                  : _popularServices.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text('لا توجد خدمات شائعة حالياً',
                                style: TextStyle(color: Colors.grey.shade600)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _popularServices.length,
                          itemBuilder: (context, index) {
                            return _buildPopularServiceCard(_popularServices[index]);
                          },
                        ),
        ],
      ),
    );
  }

  Widget _buildPopularServiceCard(ServiceItem service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _AnimatedCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              serviceTitle: service.title,
              serviceDescription: service.description,
              steps: ServiceDetailsData.buildSteps(
                description: service.description,
                requiredDocuments: service.requiredDocuments,
              ),
              comments: const [],
              serviceId: service.id,
              price: service.price,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '(${_formatReviewCount(service.reviewCount)} حضور)',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Row(
                  children: [
                    Text(
                      service.rating.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star,
                        color: Color(0xFF379777), size: 18),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (service.source.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.source,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Row(
                  children: [
                    Text(
                      'بواسطة ${service.author}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.circle,
                        color: Color(0xFF379777), size: 8),
                  ],
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
      return '${(count / 1000).toStringAsFixed(0)}K+';
    }
    return count.toString();
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('assets/icons/profile.svg', 'ملفي', 2),
              _buildNavItem(
                  'assets/icons/Property 1=Component 2.svg', 'اكتشف', 1),
              _buildNavItem('assets/icons/home.svg', 'الرئيسية', 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String svgPath, String label, int index) {
    final isActive = _selectedBottomIndex == index;

    return InkWell(
      onTap: () => _onNavItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF379777).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFF379777) : Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isActive ? const Color(0xFF379777) : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIChatFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AIChatScreen()),
        );
      },
      backgroundColor: const Color(0xFF379777),
      elevation: 6,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF379777), Color(0xFF4CAF88)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}

// ============================================================
//                      Helper animated widgets
// ============================================================

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _AnimatedButton({required this.text, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed
              ? const Color(0xFF379777)
              : const Color(0xFFB2E4D0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF379777).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isPressed ? Colors.white : const Color(0xFF379777),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const _AnimatedCard({required this.child, this.onTap, this.margin});

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

class _ClickableServiceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ClickableServiceCard({required this.child, required this.onTap});

  @override
  State<_ClickableServiceCard> createState() => _ClickableServiceCardState();
}

class _ClickableServiceCardState extends State<_ClickableServiceCard> {
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
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? const Color(0xFF379777).withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isPressed ? 12 : 8,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}