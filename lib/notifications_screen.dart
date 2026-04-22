import 'package:daleel/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 👈 مهم جداً!

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0; // 0 = الكل, 1 = غير مقروءة
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _getInitialNotifications();
  }

  List<NotificationItem> get _filteredNotifications {
    if (_selectedTab == 0) {
      return _notifications;
    } else {
      return _notifications.where((n) => !n.isRead).toList();
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  // ignore: unused_element
  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
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
            _buildTabs(isDark),
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(
                          _filteredNotifications[index],
                          isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // القائمة
          IconButton(
            onPressed: () {
              _showOptionsMenu();
            },
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 26,
            ),
          ),
          // العنوان
          Text(
            context.tr.notifications,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          // زر الرجوع
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF379777),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // غير مقروءة
          _buildTabButton(
            title: context.tr.unread,
            isSelected: _selectedTab == 1,
            onTap: () {
              setState(() {
                _selectedTab = 1;
              });
            },
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          // الكل
          _buildTabButton(
            title: context.tr.allNotifications,
            isSelected: _selectedTab == 0,
            onTap: () {
              setState(() {
                _selectedTab = 0;
              });
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF379777)
              : isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).cardColor
              : const Color(0xFF379777).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                : const Color(0xFF379777).withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // الوقت
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                // المحتوى الرئيسي
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          notification.title,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (notification.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            notification.subtitle!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // الأيقونة
                _buildNotificationIcon(notification.type),
              ],
            ),
            // الأزرار (لو موجودة)
            if (notification.actions != null &&
                notification.actions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: notification.actions!.reversed.map((action) {
                  final isPrimary = action.isPrimary;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () {
                        action.onTap();
                        if (!notification.isRead) {
                          _markAsRead(notification.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPrimary
                              ? const Color(0xFF379777)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isPrimary
                                ? const Color(0xFF379777)
                                : Colors.grey.shade400,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          action.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isPrimary
                                ? Colors.white
                                : isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData icon;
    Color bgColor;
    Color iconColor;

    switch (type) {
      case NotificationType.achievement:
        icon = Icons.emoji_events;
        bgColor = const Color(0xFFFFF4E6);
        iconColor = const Color(0xFFFFA726);
        break;
      case NotificationType.milestone:
        icon = Icons.workspace_premium;
        bgColor = const Color(0xFFFFF4E6);
        iconColor = const Color(0xFFFFA726);
        break;
      case NotificationType.like:
        icon = Icons.favorite;
        bgColor = const Color(0xFFFFE8E8);
        iconColor = const Color(0xFFE57373);
        break;
      case NotificationType.comment:
        icon = Icons.chat_bubble;
        bgColor = const Color(0xFFE8F5F1);
        iconColor = const Color(0xFF379777);
        break;
      case NotificationType.system:
        icon = Icons.notifications;
        bgColor = const Color(0xFFE3F2FD);
        iconColor = const Color(0xFF42A5F5);
        break;
      case NotificationType.user:
        icon = Icons.person;
        bgColor = const Color(0xFFF3E5F5);
        iconColor = const Color(0xFFAB47BC);
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/notification-off-02.svg',
            width: 80,
            height: 80,
            colorFilter: ColorFilter.mode(
              Colors.grey.shade400,
              BlendMode.srcIn,
            ),
            // 👈 Fallback في حالة فشل تحميل SVG
            placeholderBuilder: (context) => Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 0 ? context.tr.noNotifications : context.tr.noUnreadNotifications,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _markAllAsRead();
                },
                trailing: const Icon(Icons.done_all, color: Color(0xFF379777)),
                title: Text(
                  context.tr.markAllRead,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF379777),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Mock Data
  List<NotificationItem> _getInitialNotifications() {
    return [
      NotificationItem(
        id: '3',
        type: NotificationType.like,
        title: 'أُعجبكس أعجب بمنشوارك',
        subtitle: null,
        time: 'ساعات\nأمس',
        isRead: false,
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.system,
        title: 'الملحق الأسبوعي',
        subtitle: null,
        time: 'أمس\nمدن',
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        type: NotificationType.comment,
        title: 'ماركوس علق',
        subtitle: '"بدو مدهش!!!"',
        time: 'أمس',
        isRead: true,
      ),
    ];
  }
}

// Models
enum NotificationType {
  achievement,
  milestone,
  like,
  comment,
  system,
  user,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String? subtitle;
  final String time;
  final bool isRead;
  final List<NotificationAction>? actions;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.time,
    required this.isRead,
    this.actions,
  });

  NotificationItem copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? subtitle,
    String? time,
    bool? isRead,
    List<NotificationAction>? actions,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      actions: actions ?? this.actions,
    );
  }
}

class NotificationAction {
  final String title;
  final bool isPrimary;
  final VoidCallback onTap;

  NotificationAction({
    required this.title,
    required this.isPrimary,
    required this.onTap,
  });
}