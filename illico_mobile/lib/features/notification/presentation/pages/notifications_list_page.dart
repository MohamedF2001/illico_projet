import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/notification_provider.dart';

class NotificationsListPage extends ConsumerWidget {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationListProvider);
    final notifications = state.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
      ),
      body: state.isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(notificationListProvider.notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationItem(notification: n);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final bool isRead = notification['lu'] ?? false;
    final String type = notification['type'] ?? 'info';

    IconData icon;
    Color color;
    switch (type) {
      case 'livraison': icon = Icons.local_shipping_outlined; color = AppColors.primary; break;
      case 'paiement': icon = Icons.account_balance_wallet_outlined; color = Colors.green; break;
      case 'alerte': icon = Icons.warning_amber_rounded; color = AppColors.danger; break;
      default: icon = Icons.info_outline; color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? const Color(0xFFF8F9FA) : const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(16),
        border: isRead ? null : Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['message'] ?? '',
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['dateCreation'] != null
                    ? Formatters.date(DateTime.parse(notification['dateCreation']))
                    : '',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (!isRead)
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
