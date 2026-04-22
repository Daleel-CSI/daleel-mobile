import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({
    super.key,
    this.initialQuery = '',
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // نتائج البحث المؤقتة (في انتظار الباك إند)
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _performSearch(widget.initialQuery);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
    });

    // TODO: هنا هيتم استبدال البيانات المؤقتة بـ API call للباك إند
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _searchResults = _getMockResults(query);
        _isSearching = false;
      });
    });
  }

  // بيانات مؤقتة للتجربة (هتتشال لما الباك إند يجهز)
  List<SearchResult> _getMockResults(String query) {
    return [
      SearchResult(
        title: 'بواسطة عمر وحيد',
        serviceName: 'شراء سيارة جديدة بالتقسيط',
        subtitle: '(12 خطوة)',
        source: '(مصدر موثوق)',
        rating: 4.8,
        reviewCount: 10000,
      ),
      SearchResult(
        title: 'بواسطة عمر وحيد',
        serviceName: 'شراء سيارة جديدة بالتقسيط',
        subtitle: '(12 خطوة)',
        source: '(مصدر موثوق)',
        rating: 4.8,
        reviewCount: 10000,
      ),
      SearchResult(
        title: 'بواسطة عمر وحيد',
        serviceName: 'شراء سيارة جديدة بالتقسيط',
        subtitle: '(12 خطوة)',
        source: '(مصدر موثوق)',
        rating: 4.8,
        reviewCount: 10000,
      ),
    ];
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
          child: Stack(
            children: [
              // الديكور الخلفي
              Positioned(
                top: -50,
                left: -50,
                child: Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    'assets/images/part_1.svg',
                    width: 200,
                    height: 200,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF379777),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: -50,
                child: Opacity(
                  opacity: 0.05,
                  child: SvgPicture.asset(
                    'assets/images/part_1.svg',
                    width: 200,
                    height: 200,
                    colorFilter: ColorFilter.mode(
                      const Color(0xFF379777),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // المحتوى
              Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildSearchResults(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // زر الرجوع
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
          const SizedBox(width: 12),
          // السيرش بار
          Expanded(
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
                  border: Border.all(
                    color: _searchFocusNode.hasFocus
                        ? const Color(0xFF379777)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child:             SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade600,
                      BlendMode.srcIn,
                    ),
                  ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textAlign: TextAlign.right,
                        autofocus: true,
                        cursorColor: const Color(0xFF379777),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'سيارات',
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
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF379777),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade600,
                      BlendMode.srcIn,
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              'ابدأ البحث عن الخدمة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildSearchResultItem(_searchResults[index]);
      },
    );
  }

  Widget _buildSearchResultItem(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: الانتقال لصفحة تفاصيل النتيجة
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFF379777).withOpacity(0.1),
          highlightColor: const Color(0xFF379777).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // التقييم وعدد الخطوات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // عدد الخطوات
                    Text(
                      result.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    // التقييم
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
                            '(±${_formatReviewCount(result.reviewCount)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result.rating.toString(),
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

                const SizedBox(height: 12),

                // اسم الخدمة (العنوان الرئيسي)
                Text(
                  result.serviceName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // المصدر والناشر
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      result.source,
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
                      result.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}K';
    }
    return count.toString();
  }
}

class SearchResult {
  final String title;
  final String serviceName;
  final String subtitle;
  final String source;
  final double rating;
  final int reviewCount;

  SearchResult({
    required this.title,
    required this.serviceName,
    required this.subtitle,
    required this.source,
    required this.rating,
    required this.reviewCount,
  });
}