
// ignore_for_file: file_names

import 'package:daleel/category_services_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  final String userName;

  const AllCategoriesScreen({super.key, required this.userName});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  Future<void> _loadIfNeeded() async {
    final provider = context.read<ServicesProvider>();
    if (provider.categoriesList.isNotEmpty) return;

    final token = context.read<UserProvider>().user.token;
    setState(() => _isLoading = true);
    await provider.fetchCategories(token: token);
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ServicesProvider>().categoriesList;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(categories.length),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF379777)),
                    )
                  : categories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد فئات متاحة',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadIfNeeded,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF379777),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) =>
                              _buildCategoryCard(categories[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios,
                color: Color(0xFF379777), size: 24),
          ),
          const Expanded(child: SizedBox()),
          Center(
            child: Column(
              children: [
                Text(
                  'كل الفئات',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                if (count > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$count فئة متاحة',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ),
              ],
            ),
          ),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return _AnimatedCategoryCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryServicesScreen(
              categoryId: category.id,
              categoryTitle: category.name,
              categoryIcon: category.iconPath,
              userName: widget.userName,
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
              color: const Color(0xFFB2E4D0).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: category.iconPath.isNotEmpty
                  ? SvgPicture.asset(
                      category.iconPath,
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF379777), BlendMode.srcIn),
                      placeholderBuilder: (context) => const Icon(
                          Icons.category, color: Color(0xFF379777)),
                    )
                  : const Icon(Icons.category, color: Color(0xFF379777)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category.name,
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
}

class _AnimatedCategoryCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedCategoryCard({required this.child, required this.onTap});
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