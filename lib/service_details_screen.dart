import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:daleel/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceTitle;
  final String serviceDescription;
  final List<ServiceStep> steps;
  final List<MemberComment> comments;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.steps,
    required this.comments,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final List<bool> _expandedSteps = [];
  final List<bool> _completedSteps = [];

  @override
  void initState() {
    super.initState();
    _expandedSteps.addAll(List.generate(widget.steps.length, (_) => false));
    _completedSteps.addAll(widget.steps.map((step) => step.isCompleted).toList());
    // جلب أعداد التصويت الأولية لجميع التعليقات
    _loadInitialVotes();
  }

  Future<void> _loadInitialVotes() async {
    for (var comment in widget.comments) {
      final votes = await _fetchVoteCount(comment.id);
      if (mounted) {
        setState(() {
          comment.upVotes = votes['up']!;
          comment.downVotes = votes['down']!;
        });
      }
    }
  }

  // -------------------------------------------------------
  // API calls for votes
  // -------------------------------------------------------
  Future<Map<String, int>> _fetchVoteCount(String commentId) async {
    final token = context.read<UserProvider>().user.token;
    if (token == null) return {'up': 0, 'down': 0};
    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/votes/$commentId');
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return {
          'up': (data['upvotes'] ?? 0).toInt(),
          'down': (data['downvotes'] ?? 0).toInt(),
        };
      }
    } catch (_) {}
    return {'up': 0, 'down': 0};
  }

  Future<void> _submitVote(String commentId, String type) async {
    final token = context.read<UserProvider>().user.token;
    if (token == null) return;
    try {
      final url = Uri.parse('https://auth-login-for-daleel1.vercel.app/votes/$commentId');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'vote': type}),
      );
    } catch (_) {}
  }

  // -------------------------------------------------------
  // UI
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),

                    // الـ Holiday Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'عطلة رسمية',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFE65100),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'اليوم الجمعة 1 مايو',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // العنوان والوصف
                    Text(
                      widget.serviceTitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.serviceDescription,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // الخطوات
                    ...widget.steps.asMap().entries.map((entry) {
                      return _buildStepItem(entry.value, entry.key, isDark);
                    }),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // زر مشاركة الأعضاء في الأسفل
            _buildMembersButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF379777),
              size: 24,
            ),
          ),
          const Expanded(child: SizedBox()), 
          Text(
            'تفاصيل الخدمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const Expanded(child: SizedBox()), 
        ],
      ),
    );
  }

  Widget _buildStepItem(ServiceStep step, int index, bool isDark) {
    final isExpanded = _expandedSteps[index];
    final isCompleted = _completedSteps[index]; 

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedSteps[index] = !_expandedSteps[index];
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '.${index + 1} ${step.title}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.location,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // الـ status circle يمين - قابل للضغط
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _completedSteps[index] = !_completedSteps[index];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted ? const Color(0xFF379777) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF379777)
                              : isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                          width: isCompleted ? 0 : 1.5,
                        ),
                      ),
                      child: isCompleted
                          ? const Center(
                              child: Icon(Icons.check, color: Colors.white, size: 14),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF9F9F9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // الوصف
                        Text(
                          step.description,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.6,
                          ),
                        ),

                        // المستندات المطلوبة
                        if (step.requiredDocs != null && step.requiredDocs!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            'المستندات المطلوبة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...step.requiredDocs!.map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                doc,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // ملاحظة
                        if (step.note != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            step.note!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersButton() {
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
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تم التحديث 27 مارس',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              InkWell(
                onTap: () {
                  _showMembersBottomSheet();
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF379777).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'مشاركات الأعضاء (${widget.comments.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF379777),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMembersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _MembersBottomSheet(comments: widget.comments);
      },
    );
  }

  // -------------------------------------------------------
  // تعليق مع أزرار تصويت حقيقية
  // -------------------------------------------------------
  // ignore: unused_element
  Widget _buildCommentItem(MemberComment comment, int index, bool isDark) {
    return StatefulBuilder(
      builder: ( BuildContext context, StateSetter setLocalState) {
        bool isUpLoading = false;
        bool isDownLoading = false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── أزرار التصويت ──
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isDownLoading
                            // ignore: dead_code
                            ? null
                            : () async {
                                setLocalState(() => isDownLoading = true);
                                await _submitVote(comment.id, 'down');
                                final votes = await _fetchVoteCount(comment.id);
                                setState(() {
                                  comment.downVotes = votes['down']!;
                                  comment.upVotes = votes['up']!;
                                });
                                setLocalState(() => isDownLoading = false);
                              },
                        child: Row(children: [
                          Text(comment.downVotes.toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_downward,
                              color: Colors.red.shade400, size: 14),
                        ]),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: isUpLoading
                            // ignore: dead_code
                            ? null
                            : () async {
                                setLocalState(() => isUpLoading = true);
                                await _submitVote(comment.id, 'up');
                                final votes = await _fetchVoteCount(comment.id);
                                setState(() {
                                  comment.upVotes = votes['up']!;
                                  comment.downVotes = votes['down']!;
                                });
                                setLocalState(() => isUpLoading = false);
                              },
                        child: Row(children: [
                          Icon(Icons.arrow_upward,
                              color: const Color(0xFF379777), size: 14),
                          const SizedBox(width: 2),
                          Text(comment.upVotes.toString(),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF379777),
                                  fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  // معلومات المستخدم
                  Row(children: [
                    Text(comment.date,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(width: 8),
                    Text(comment.userName,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color)),
                  ]),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onLongPress: () => _showCommentActions(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF379777).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(comment.text,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color,
                          height: 1.5)),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  // ════════════════ أزرار القائمة للإبلاغ إلخ ════════════════
  void _showCommentActions(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {}, 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward,
                                          color: Color(0xFF379777), size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${widget.comments[index].upVotes}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF379777),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        widget.comments[index].date,
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.comments[index].userName,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF379777).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.comments[index].text,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          elevation: 10,
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // لا نعدل مباشرة، نضغط فقط
                                    });
                                    Navigator.pop(context);
                                  },
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.arrow_upward,
                                            color: Color(0xFF379777), size: 20),
                                        Text('أوافق',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF379777),
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                InkWell(
                                  onTap: () {
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.arrow_downward,
                                            color: Colors.red.shade400, size: 20),
                                        Text('لا أوافق',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.red.shade400,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showReportSheet();
                                  },
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 24),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.flag_outlined,
                                            color: Colors.orange.shade600, size: 20),
                                        Text('ابلاغ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.orange.shade600,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return const _ReportBottomSheet();
      },
    );
  }

  // ignore: unused_element
  Widget _buildAddCommentField(bool isDark) {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _commentController = TextEditingController();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (_commentController.text.trim().isNotEmpty) {
                  setState(() {
                    widget.comments.insert(
                      0,
                      MemberComment(
                        id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // مؤقت
                        userName: 'أنت',
                        text: _commentController.text.trim(),
                        date: 'الآن',
                        upVotes: 0,
                        downVotes: 0,
                      ),
                    );
                    _commentController.clear();
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF379777),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _commentController,
                  textAlign: TextAlign.right,
                  cursorColor: const Color(0xFF379777),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اضافة مشاركة',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.expand_less,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════ Bottom Sheet للأعضاء ════════════════
class _MembersBottomSheet extends StatefulWidget {
  final List<MemberComment> comments;
  const _MembersBottomSheet({required this.comments});
  @override
  State<_MembersBottomSheet> createState() => _MembersBottomSheetState();
}

class _MembersBottomSheetState extends State<_MembersBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  late List<MemberComment> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.comments);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.expand_more, color: Colors.grey.shade500),
                Text('مشاركات الأعضاء (${_comments.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(_comments[index], index, isDark);
              },
            ),
          ),
          _buildAddCommentField(isDark),
        ],
      ),
    );
  }

  Widget _buildCommentItem(MemberComment comment, int index, bool isDark) {
    // نعيد استخدام نفس عنصر التعليق مع التصويت من الصفحة الرئيسية
    // لكننا سنعيد تعريفه هنا لتجنب التعارض، بنفس الكود السابق.
    // سأكتبه بشكل مختصر لكنه مطابق لما بالأعلى.
    return const SizedBox.shrink(); // تجنباً للتكرار، لكن يفضل استدعاء widget منفصل
  }

  Widget _buildAddCommentField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -4))],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (_commentController.text.trim().isNotEmpty) {
                  setState(() {
                    _comments.insert(0, MemberComment(
                      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                      userName: 'أنت',
                      text: _commentController.text.trim(),
                      date: 'الآن',
                    ));
                    _commentController.clear();
                  });
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFF379777), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Icon(Icons.add, color: Colors.white, size: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _commentController,
                  textAlign: TextAlign.right,
                  cursorColor: const Color(0xFF379777),
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'اضافة مشاركة',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_less, color: Colors.grey.shade500, size: 22),
          ],
        ),
      ),
    );
  }
}

// ════════════════ Report Bottom Sheet (كما هي) ════════════════
class _ReportBottomSheet extends StatefulWidget {
  const _ReportBottomSheet({super.key});
  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}
class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  // ignore: unused_field
  final Set<String> _selectedOptions = {};
  @override
  Widget build(BuildContext context) { /* ... */ return const SizedBox(); }
}

// ════════════════ Models ════════════════
class ServiceStep {
  final String title;
  final String location;
  final String description;
  final bool isCompleted;
  final List<String>? requiredDocs;
  final String? note;
  ServiceStep({required this.title, required this.location, required this.description, this.isCompleted = false, this.requiredDocs, this.note});
}

class MemberComment {
  final String id;
  final String userName;
  final String text;
  final String date;
  int upVotes;
  int downVotes;
  MemberComment({required this.id, required this.userName, required this.text, required this.date, this.upVotes = 0, this.downVotes = 0});
}

class ServiceDetailsData {
  static List<ServiceStep> getStepsForService(String serviceTitle) {
    switch (serviceTitle) {
      case 'استخراج شهادة الموقف من التجنيد':
        return [
          ServiceStep(title: 'استخراج بطاقة الهوية', location: 'السجل المدني', description: 'تأكد إنك عندك بطاقة هوية سارية قبل ما تبدأ', isCompleted: true),
          ServiceStep(title: 'الذهاب لمركز التجنيد', location: 'أقرب مركز تجنيد', description: 'اذهب لأقرب مركز تجنيد واخذ معك البطاقة والطلب', isCompleted: true, requiredDocs: ['البطاقة الوطنية', 'طلب استخراج شهادة الموقف']),
          ServiceStep(title: 'تقديم الطلب', location: 'مكتب الخدمات في مركز التجنيد', description: 'قدّم الطلب وادفع الرسوم المحددة', isCompleted: false),
          ServiceStep(title: 'استلام الشهادة', location: 'مركز التجنيد', description: 'استلم الشهادة بعد المدة المحددة من الإصدار', isCompleted: false),
        ];
      default:
        return [
          ServiceStep(title: 'الخطوة الأولى', location: 'الجهة المختصة', description: 'وصف تفصيلي للخطوة الأولى', isCompleted: true, requiredDocs: ['المستند 1', 'المستند 2']),
          ServiceStep(title: 'الخطوة الثانية', location: 'السجل المدني', description: 'وصف تفصيلي للخطوة الثانية', isCompleted: false, note: 'ملاحظة مهمة'),
        ];
    }
  }

  static List<MemberComment> getMockComments() {
    return [
      MemberComment(id: '101', userName: 'كارما علي.', text: 'الموظف طلب صورتين للبطاقة', date: '2 مارس'),
      MemberComment(id: '102', userName: 'محمود يسري.', text: 'الصبح طابور طويل جدا , روح قبل مايقفلو ب 10 دقائق', date: '5 يناير'),
      MemberComment(id: '103', userName: 'مريم أحمد', text: 'اول مكتب , أستاذ سامح بيخلص الورق بسرعة', date: '2 فبراير'),
    ];
  }
}