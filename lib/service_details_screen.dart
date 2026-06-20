import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:daleel/api/api_service.dart';
import 'package:daleel/providers/user_provider.dart';
import 'package:provider/provider.dart';

// ===================== Main Screen =====================
class ServiceDetailsScreen extends StatefulWidget {
  final String serviceTitle;
  final String serviceDescription;
  final List<ServiceStep> steps;
  final List<MemberComment> comments;
  final String serviceId;
  final bool isAdmin;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.steps,
    required this.comments,
    required this.serviceId,
    this.isAdmin = false,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final List<bool> _expandedSteps = [];
  final List<bool> _completedSteps = [];
  bool _isApproving = false;
  bool _isRejecting = false;

  List<MemberComment> _comments = [];
  bool _isLoadingComments = false;
  String? _commentsError;

  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _expandedSteps.addAll(List.generate(widget.steps.length, (_) => false));
    _completedSteps.addAll(widget.steps.map((step) => step.isCompleted).toList());
    _comments = List.from(widget.comments);
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final token = context.read<UserProvider>().user.token;
    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });

    final votesJson = await ApiService.getVotes(
      serviceId: widget.serviceId,
      token: token,
    );

    if (!mounted) return;

    if (votesJson != null) {
      setState(() {
        _comments = votesJson.map((json) => MemberComment(
          userName: json['userName'] ?? json['username'] ?? 'مستخدم',
          text: json['text'] ?? json['comment'] ?? '',
          date: json['date'] ?? '',
          upVotes: (json['upVotes'] as num?)?.toInt() ?? 0,
          downVotes: (json['downVotes'] as num?)?.toInt() ?? 0,
        )).toList();
        _isLoadingComments = false;
      });
    } else {
      setState(() {
        _commentsError = 'فشل تحميل التعليقات';
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _toggleStep(int index) async {
    final oldValue = _completedSteps[index];
    setState(() {
      _completedSteps[index] = !_completedSteps[index];
    });

    final stepsData = <Map<String, dynamic>>[];
    for (int i = 0; i < widget.steps.length; i++) {
      stepsData.add({
        'title': widget.steps[i].title,
        'completed': _completedSteps[i],
      });
    }

    final token = context.read<UserProvider>().user.token;
    final success = await ApiService.updateService(
      serviceId: widget.serviceId,
      data: {'steps': stepsData},
      token: token,
    );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _completedSteps[index] = oldValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل تحديث الخطوة، حاول مرة أخرى'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _addComment(String text) async {
    if (text.trim().isEmpty) return;
    // حالياً نضيف محلياً فقط، يمكن ربطه بـ API لاحقاً
    setState(() {
      _comments.insert(0, MemberComment(
        userName: 'أنت',
        text: text,
        date: 'الآن',
        upVotes: 0,
        downVotes: 0,
      ));
    });
    // يمكن استدعاء API هنا
  }

  Future<void> _handleVote(String type) async {
    if (_isVoting) return;
    setState(() => _isVoting = true);

    final token = context.read<UserProvider>().user.token;
    final ok = await ApiService.postVote(
      serviceId: widget.serviceId,
      type: type,
      token: token,
    );

    setState(() => _isVoting = false);

    if (!mounted) return;

    if (ok) {
      await _fetchComments();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم التصويت بنجاح'),
          backgroundColor: const Color(0xFF379777),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فشل التصويت، حاول مرة أخرى'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _approveService() async {
    setState(() => _isApproving = true);
    final token = context.read<UserProvider>().user.token;
    final ok = await ApiService.approveService(
      serviceId: widget.serviceId,
      token: token,
    );
    setState(() => _isApproving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تمت الموافقة على الخدمة ✅' : 'فشلت الموافقة'),
        backgroundColor: ok ? const Color(0xFF379777) : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (ok) Navigator.pop(context);
  }

  Future<void> _rejectService() async {
    setState(() => _isRejecting = true);
    final token = context.read<UserProvider>().user.token;
    final ok = await ApiService.rejectService(
      serviceId: widget.serviceId,
      token: token,
    );
    setState(() => _isRejecting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'تم رفض الخدمة ❌' : 'فشلت العملية'),
        backgroundColor: ok ? Colors.orange : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (ok) Navigator.pop(context);
  }

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
                            style: TextStyle(fontSize: 13, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                          ),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildVoteButtons(),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'اليوم الجمعة 1 مايو',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.serviceTitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.serviceDescription,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 24),
                    ...widget.steps.asMap().entries.map((entry) {
                      return _buildStepItem(entry.value, entry.key, isDark);
                    }),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildMembersButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isVoting)
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF379777)))
        else
          IconButton(
            icon: const Icon(Icons.arrow_upward, color: Color(0xFF379777), size: 20),
            onPressed: () => _handleVote('up'),
            tooltip: 'تصويت بالموافقة',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        if (_isVoting)
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
        else
          IconButton(
            icon: Icon(Icons.arrow_downward, color: Colors.red.shade600, size: 20),
            onPressed: () => _handleVote('down'),
            tooltip: 'تصويت بالرفض',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF379777), size: 24),
          ),
          const Expanded(child: SizedBox()),
          Text(
            'تفاصيل الخدمة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const Expanded(child: SizedBox()),
          if (widget.isAdmin) _buildAdminActions(),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRejecting)
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
        else
          IconButton(
            icon: Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 24),
            onPressed: _rejectService,
            tooltip: 'رفض الخدمة',
          ),
        const SizedBox(width: 8),
        if (_isApproving)
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF379777)))
        else
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: Color(0xFF379777), size: 24),
            onPressed: _approveService,
            tooltip: 'موافقة على الخدمة',
          ),
      ],
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
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, width: 0.8),
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
                              color: isCompleted ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.location,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleStep(index),
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
                          ? const Center(child: Icon(Icons.check, color: Colors.white, size: 14))
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
                      color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9F9F9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(step.description, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6)),
                        if (step.requiredDocs != null && step.requiredDocs!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text('المستندات المطلوبة', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: 6),
                          ...step.requiredDocs!.map((doc) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(doc, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                              )),
                        ],
                        if (step.note != null) ...[
                          const SizedBox(height: 10),
                          Text(step.note!, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تم التحديث 27 مارس', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              InkWell(
                onTap: () {
                  if (!_isLoadingComments && _commentsError == null) {
                    _showMembersBottomSheet();
                  } else if (_commentsError != null) {
                    _fetchComments();
                  }
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF379777).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF379777).withOpacity(0.3), width: 1.5),
                  ),
                  child: _isLoadingComments
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF379777)))
                      : _commentsError != null
                          ? Text('فشل التحميل - اضغط لإعادة', style: TextStyle(color: Colors.red.shade600, fontSize: 11))
                          : Text(
                              'مشاركات الأعضاء (${_comments.length})',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF379777), fontWeight: FontWeight.w600),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _MembersBottomSheet(
        comments: _comments,
        onAddComment: _addComment,
      ),
    );
  }
}

// ===================== Members Bottom Sheet =====================
class _MembersBottomSheet extends StatefulWidget {
  final List<MemberComment> comments;
  final Future<void> Function(String) onAddComment;

  const _MembersBottomSheet({required this.comments, required this.onAddComment});

  @override
  State<_MembersBottomSheet> createState() => _MembersBottomSheetState();
}

class _MembersBottomSheetState extends State<_MembersBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  late List<MemberComment> _comments;
  bool _isSending = false;

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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    await widget.onAddComment(text);
    setState(() {
      _isSending = false;
      _commentController.clear();
      _comments.insert(0, MemberComment(
        userName: 'أنت',
        text: text,
        date: 'الآن',
        upVotes: 0,
        downVotes: 0,
      ));
    });
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
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.expand_more, color: Colors.grey.shade500),
                Text(
                  'مشاركات الأعضاء (${_comments.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _comments.length,
              itemBuilder: (context, index) => _buildCommentItem(_comments[index], index, isDark),
            ),
          ),
          _buildAddCommentField(isDark),
        ],
      ),
    );
  }

  Widget _buildCommentItem(MemberComment comment, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(comment.downVotes.toString(), style: TextStyle(fontSize: 12, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_downward, color: Colors.red.shade400, size: 14),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_upward, color: const Color(0xFF379777), size: 14),
                  const SizedBox(width: 2),
                  Text(comment.upVotes.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF379777), fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Text(comment.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(width: 8),
                  Text(comment.userName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onLongPress: () => _showCommentActions(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF379777).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                comment.text,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

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
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.arrow_upward, color: Color(0xFF379777), size: 14),
                                      const SizedBox(width: 2),
                                      Text(_comments[index].upVotes.toString(), style: const TextStyle(fontSize: 12, color: Color(0xFF379777), fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(_comments[index].date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                      const SizedBox(width: 8),
                                      Text(_comments[index].userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF379777).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _comments[index].text,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
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
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _comments[index] = MemberComment(
                                        userName: _comments[index].userName,
                                        text: _comments[index].text,
                                        date: _comments[index].date,
                                        upVotes: _comments[index].upVotes + 1,
                                        downVotes: _comments[index].downVotes,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Icon(Icons.arrow_upward, color: Color(0xFF379777), size: 20),
                                      Text('أوافق', style: TextStyle(fontSize: 15, color: Color(0xFF379777), fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _comments[index] = MemberComment(
                                        userName: _comments[index].userName,
                                        text: _comments[index].text,
                                        date: _comments[index].date,
                                        upVotes: _comments[index].upVotes,
                                        downVotes: _comments[index].downVotes + 1,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Icon(Icons.arrow_downward, color: Colors.red.shade400, size: 20),
                                      Text('لا أوافق', style: TextStyle(fontSize: 15, color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                                    ]),
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey.shade200),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showReportSheet();
                                  },
                                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Icon(Icons.flag_outlined, color: Colors.orange.shade600, size: 20),
                                      Text('ابلاغ', style: TextStyle(fontSize: 15, color: Colors.orange.shade600, fontWeight: FontWeight.w600)),
                                    ]),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _ReportBottomSheet(),
    );
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
              onTap: _isSending ? null : _sendComment,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _isSending ? Colors.grey : const Color(0xFF379777),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isSending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Center(child: Icon(Icons.add, color: Colors.white, size: 22)),
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

// ===================== Report Bottom Sheet =====================
class _ReportBottomSheet extends StatefulWidget {
  const _ReportBottomSheet({super.key});
  @override
  State<_ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<_ReportBottomSheet> {
  final Set<String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('ابلاغ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Text('لماذا تقوم بالابلاغ عن هذا المحتوى؟', textAlign: TextAlign.right, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 4),
            Text('اذا كان شخص ما في خطر مباشر , فاطلب المساعدة قبل الإبلاغ الى دليل , لا تنتظر', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4)),
            const SizedBox(height: 24),
            _buildReportSection(title: 'التنمر أو المضايقة ؟', question: 'من يتعرض لها؟', options: ['أنا', 'صديق', 'لا أعرفه']),
            const SizedBox(height: 24),
            _buildReportSection(title: 'الاحتيال أو النصب أو المعلومات الكاذبة ؟', question: null, options: ['أحتيال أو النصب', 'مشاركة معلومات خاطئة', 'أنتحال صفة شركة أو شخص']),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('إرسال الابلاغ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection({required String title, String? question, required List<String> options}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(Icons.expand_less, color: Colors.grey.shade500, size: 22),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ]),
        if (question != null) ...[
          const SizedBox(height: 8),
          Text(question, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8, alignment: WrapAlignment.end,
          children: options.map((option) {
            final isSelected = _selectedOptions.contains(option);
            return GestureDetector(
              onTap: () => setState(() { isSelected ? _selectedOptions.remove(option) : _selectedOptions.add(option); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF379777) : const Color(0xFF379777).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? const Color(0xFF379777) : const Color(0xFF379777).withOpacity(0.2), width: 1.5),
                ),
                child: Text(option, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : const Color(0xFF379777), fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ===================== Models =====================
class ServiceStep {
  final String title;
  final String location;
  final String description;
  final bool isCompleted;
  final List<String>? requiredDocs;
  final String? note;

  ServiceStep({
    required this.title,
    required this.location,
    required this.description,
    this.isCompleted = false,
    this.requiredDocs,
    this.note,
  });
}

class MemberComment {
  final String userName;
  final String text;
  final String date;
  final int upVotes;
  final int downVotes;

  MemberComment({
    required this.userName,
    required this.text,
    required this.date,
    this.upVotes = 0,
    this.downVotes = 0,
  });
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
      MemberComment(userName: 'كارما علي.', text: 'الموظف طلب صورتين للبطاقة', date: '2 مارس', upVotes: 10, downVotes: 0),
      MemberComment(userName: 'محمود يسري.', text: 'الصبح طابور طويل جدا , روح قبل مايقفلو ب 10 دقائق', date: '5 يناير', upVotes: 25, downVotes: 2),
      MemberComment(userName: 'مريم أحمد', text: 'اول مكتب , أستاذ سامح بيخلص الورق بسرعة', date: '2 فبراير', upVotes: 11, downVotes: 0),
    ];
  }
}