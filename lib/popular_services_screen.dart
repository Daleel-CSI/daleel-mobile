import 'dart:convert';
import 'package:daleel/screen/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:daleel/providers/app_provider.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:daleel/service_details_screen.dart';
import 'package:daleel/api/api_service.dart';

class PopularServicesScreen extends StatefulWidget {
  const PopularServicesScreen({super.key});

  @override
  State<PopularServicesScreen> createState() => _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  List<ServiceItem> _popularServices = [];
  bool _isLoading = false;
  String? _error;
  bool _initialFetchDone = false;

  // حفظ مرجع إلى UserProvider لتجنب استخدام context في dispose
  UserProvider? _userProvider;

  @override
  void initState() {
    super.initState();
    // حفظ مرجع UserProvider
    _userProvider = context.read<UserProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetch();
    });
  }

  void _checkAndFetch() {
    if (_userProvider == null) return;
    if (_userProvider!.isLoading) {
      _userProvider!.addListener(_onUserProviderLoaded);
      return;
    }
    _fetchPopular();
  }

  void _onUserProviderLoaded() {
    if (_userProvider == null) return;
    if (!_userProvider!.isLoading) {
      _userProvider!.removeListener(_onUserProviderLoaded);
      if (mounted) {
        _fetchPopular();
      }
    }
  }

  @override
  void dispose() {
    // إزالة المستمع بأمان باستخدام المرجع المخزن
    _userProvider?.removeListener(_onUserProviderLoaded);
    _userProvider = null;
    super.dispose();
  }

  Future<void> _fetchPopular() async {
    final token = _userProvider?.token;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse('${ApiService.baseUrl}/services/popular');

      // بناء الـ headers
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // إذا كان التوكن يبدأ بـ cookie_، استخدمه ككوكي
      if (token != null && token.startsWith('cookie_')) {
        final cookieValue = token.substring(7);
        headers['Cookie'] = 'connect.sid=$cookieValue';
      } else if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      print('📡 Popular Services Request Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('📡 Popular Services Response Status: ${response.statusCode}');
      print('📦 Popular Services Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') && decoded['data'] is List) {
            dataList = decoded['data'];
          } else if (decoded.containsKey('services') && decoded['services'] is List) {
            dataList = decoded['services'];
          } else if (decoded.containsKey('popular') && decoded['popular'] is List) {
            dataList = decoded['popular'];
          } else {
            dataList = [decoded];
          }
        }

        if (!mounted) return;

        setState(() {
          _popularServices = dataList
              .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          _initialFetchDone = true;
        });

        if (_popularServices.isEmpty && mounted) {
          setState(() => _error = 'لا توجد خدمات شائعة حالياً');
        }
      } else if (response.statusCode == 401) {
        // إذا كان 401، قد يكون الكوكي منتهي الصلاحية
        if (mounted) {
          // لا نمسح التوكن، فقط نعرض رسالة ونوجه لتسجيل الدخول
          // لكن يمكننا أيضاً محاولة تحديث التوكن عبر إعادة تسجيل الدخول
          setState(() {
            _error = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          // نذهب لشاشة تسجيل الدخول ولكن لا نمسح التوكن
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthScreen(startWithLogin: true)),
          );
        }
      } else {
        String errorMsg = 'فشل تحميل الخدمات الشائعة';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map && errorBody.containsKey('message')) {
            errorMsg = errorBody['message'].toString();
          }
        } catch (_) {}
        if (mounted) {
          setState(() {
            _error = errorMsg;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching popular services: $e');
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ في الاتصال: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF379777)),
                    );
                  }
                  if (!_initialFetchDone) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _fetchPopular();
                    });
                  }
                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF379777)),
                    );
                  }
                  if (_error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchPopular,
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
                    );
                  }
                  if (_popularServices.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد خدمات شائعة حالياً',
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _popularServices.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(_popularServices[index]);
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF379777), size: 24),
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

  Widget _buildServiceCard(ServiceItem service) {
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
                  service.steps,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF379777).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '(±${_formatReviewCount(service.reviewCount)})',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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
                      const Icon(Icons.star, color: Color(0xFF379777), size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    service.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.circle, color: Color(0xFF379777), size: 6),
                const SizedBox(width: 8),
                Text(
                  'بواسطة ${service.author}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
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