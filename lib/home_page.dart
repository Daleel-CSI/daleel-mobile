import 'package:daleel/add_trip_screen.dart';
import 'package:daleel/profile_screen.dart';
import 'package:daleel/save_screen.dart';
import 'package:daleel/discover_screen.dart';
import 'package:daleel/search_results_screen.dart';
import 'package:daleel/popular_services_screen.dart';
import 'package:daleel/category_services_screen.dart';
import 'package:daleel/notifications_screen.dart';
import 'package:daleel/ai_chat_screen.dart';
import 'package:daleel/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  final String? userName;
  
  const HomePage({
    super.key,
    this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  
  late String userName;
  int _selectedBottomIndex = 0;
  
  // Notifications state
  int _unreadNotificationsCount = 3;
  
  int completedSteps = 5;
  int totalSteps = 5;
  
  final List<PopularService> _popularServices = [
    PopularService(
      title: "شراء سيارة جديدة بالتقسيط",
      rating: 4.8,
      reviewCount: 10000,
      location: "بواسطة عمر وحيد",
      source: "مصدر موثوق",
      isFeatured: true,
    ),
    PopularService(
      title: "شراء سيارة جديدة بالتقسيط",
      rating: 4.8,
      reviewCount: 10000,
      location: "بواسطة عمر وحيد",
      source: "مصدر موثوق",
      isFeatured: true,
    ),
    PopularService(
      title: "شراء سيارة جديدة بالتقسيط",
      rating: 4.8,
      reviewCount: 10000,
      location: "بواسطة عمر وحيد",
      source: "مصدر موثوق",
      isFeatured: true,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    userName = widget.userName ?? "عماد";
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
        builder: (context) => SearchResultsScreen(
          initialQuery: _searchController.text,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
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
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));
          
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        child: IndexedStack(
          key: ValueKey<int>(_selectedBottomIndex),
          index: _selectedBottomIndex,
          children: [
            _buildHomeContent(),
            const SaveScreen(),
            DiscoverScreen(userName: userName),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _selectedBottomIndex == 0
          ? _buildAIChatFAB()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildAIChatFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AiChatScreen(),
          ),
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

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTripsSection(),
                  const SizedBox(height: 30),
                  _buildDiscoverSection(),
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
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Notification bell icon
          _buildNotificationBell(),
          // Greeting
          Row(
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF379777),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.tr.hello,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
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
            builder: (context) => const NotificationsScreen(),
          ),
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
            // Badge
            if (hasNotifications)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      _unreadNotificationsCount > 9
                          ? '9+'
                          : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
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
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
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
                    // في حالة فشل تحميل SVG، استخدم Icon
                    placeholderBuilder: (context) => Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
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
  
  Widget _buildTripsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedButton(
                text: context.tr.addTrip,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTripScreen(
                        userName: userName,
                      ),
                    ),
                  );
                },
              ),
              Text(
                context.tr.myTrips,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          _AnimatedCard(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  value: completedSteps / totalSteps,
                                  strokeWidth: 6,
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF379777),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.tr.workDocs,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اليوم الأربعاء 5 مايو',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF2A2A2A) 
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            '٥. بيريت التأمينات - مكتب التأمينات',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
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
          ),
        ],
      ),
    );
  }
  
  Widget _buildDiscoverSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.tr.discoverNewTrips,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          
          const SizedBox(height: 20),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
              _buildServiceCard(context.tr.categorySoldiers, 'assets/icons/army.svg'),
              _buildServiceCard(context.tr.categoryGraduation, 'assets/icons/graduation.svg'),
              _buildServiceCard(context.tr.categoryTravel, 'assets/icons/Container-4.svg'),
              _buildServiceCard(context.tr.categoryMarriage, 'assets/icons/Component 1.svg'),
              _buildServiceCard(context.tr.categoryCarLicense, 'assets/icons/car_license.svg'),
              _buildServiceCard(context.tr.categoryTraffic, 'assets/icons/Container-12.svg'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceCard(String title, String? svgPath, {bool isMore = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _ClickableServiceCard(
      onTap: () {
        // فتح صفحة الخدمات حسب القسم
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryServicesScreen(
              categoryTitle: title,
              categoryIcon: svgPath ?? 'assets/icons/more.svg',
              userName: userName,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                  ? const Icon(
                      Icons.more_horiz,
                      size: 28,
                      color: Color(0xFF379777),
                    )
                  : SvgPicture.asset(
                      svgPath!,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF379777),
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPopularSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedButton(
                text: context.tr.showAll,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PopularServicesScreen(),
                    ),
                  );
                },
              ),
              Text(
                context.tr.mostPopular,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ListView.builder(
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
  
  Widget _buildPopularServiceCard(PopularService service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _AnimatedCard(
      onTap: () {},
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      service.rating.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star,
                      color: Color(0xFF379777),
                      size: 18,
                    ),
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      service.source,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Row(
                  children: [
                    Text(
                      service.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.circle,
                      color: Color(0xFF379777),
                      size: 8,
                    ),
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
              _buildNavItem('assets/icons/profile.svg', context.tr.myProfile, 3),
              _buildNavItem('assets/icons/Property 1=Component 2.svg', context.tr.discover, 2),
              _buildNavItem('assets/icons/Bookmark.svg', context.tr.myTrips, 1),
              _buildNavItem('assets/icons/home.svg', context.tr.home, 0),
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
                color: isActive ? const Color(0xFF379777) : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  
  const _AnimatedButton({
    required this.text,
    required this.onTap,
  });
  
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
          boxShadow: _isPressed ? [] : [
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
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
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
  
  const _ClickableServiceCard({
    required this.child,
    required this.onTap,
  });
  
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

class PopularService {
  final String title;
  final double rating;
  final int reviewCount;
  final String location;
  final String source;
  final bool isFeatured;
  
  PopularService({
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.source,
    this.isFeatured = false,
  });
}