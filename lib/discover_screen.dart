import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'category_services_screen.dart';

class DiscoverScreen extends StatefulWidget {
  final String? userName;
  
  const DiscoverScreen({
    super.key,
    this.userName,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  final List<ServiceCategory> _categories = [
    ServiceCategory(title: 'الجيش', iconPath: 'assets/icons/army.svg'),
    ServiceCategory(title: 'التخرج الجامعي', iconPath: 'assets/icons/graduation.svg'),
    ServiceCategory(title: 'الزواج', iconPath: 'assets/icons/Component 1.svg'),
    ServiceCategory(title: 'التقديم الجامعي', iconPath: 'assets/icons/Container-4.svg'),
    ServiceCategory(title: 'ترخيص السيارات', iconPath: 'assets/icons/car_license.svg'),
    ServiceCategory(title: 'السفر للخارج', iconPath: 'assets/icons/Container-4.svg'),
    ServiceCategory(title: 'الضرائب', iconPath: 'assets/icons/graduation.svg'),
    ServiceCategory(title: 'المدارس', iconPath: 'assets/icons/graduation.svg'),
    ServiceCategory(title: 'الحي', iconPath: 'assets/icons/Component 1.svg'),
    ServiceCategory(title: 'الصحة', iconPath: 'assets/icons/army.svg'),
    ServiceCategory(title: 'الشهر العقاري', iconPath: 'assets/icons/graduation.svg'),
    ServiceCategory(title: 'الإسكان', iconPath: 'assets/icons/Component 1.svg'),
    ServiceCategory(title: 'الوظائف', iconPath: 'assets/icons/car_license.svg'),
    ServiceCategory(title: 'المرور', iconPath: 'assets/icons/car_license.svg'),
    ServiceCategory(title: 'شركات', iconPath: 'assets/icons/Component 1.svg'),
    ServiceCategory(title: 'التأمينات', iconPath: 'assets/icons/graduation.svg'),
    ServiceCategory(title: 'الجمارك', iconPath: 'assets/icons/Container-4.svg'),
    ServiceCategory(title: 'الاستيراد و التصدير', iconPath: 'assets/icons/Container-4.svg'),
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchExpanded = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF379777),
          selectionColor: const Color(0xFF379777).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF379777),
        ),
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _buildCategoriesGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Text(
          'اكتشف الخدمات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Container(
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
                border: Border.all(
                  color: _isSearchExpanded
                      ? const Color(0xFF379777)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isSearchExpanded = true;
                        });
                      },
                      child: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن خدمة...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isSearchExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'نتائج البحث',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSearchResult('تجديد البطاقة الشخصية'),
                  _buildSearchResult('تجديد رخصة القيادة'),
                  _buildSearchResult('استخراج قيد عائلي'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResult(String title) {
    return InkWell(
      onTap: () {
        // التعامل مع اختيار نتيجة البحث  
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.search,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(_categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    return _AnimatedCategoryCard(
      onTap: () {
        // الانتقال لصفحة الخدمات
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryServicesScreen(
              categoryTitle: category.title,
              categoryIcon: category.iconPath,
              userName: widget.userName ?? "",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFB2E4D0).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SvgPicture.asset(
                  category.iconPath,
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF379777),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCategoryCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedCategoryCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<_AnimatedCategoryCard> {
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
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
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

class ServiceCategory {
  final String title;
  final String iconPath;

  ServiceCategory({
    required this.title,
    required this.iconPath,
  });
}