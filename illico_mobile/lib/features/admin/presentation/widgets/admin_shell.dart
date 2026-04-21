import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _navItems = [
    _NavItem('/admin/dashboard',    Icons.dashboard_outlined,       Icons.dashboard,     'Dashboard'),
    _NavItem('/admin/livraisons',   Icons.local_shipping_outlined,  Icons.local_shipping,'Livraisons'),
    _NavItem('/admin/livreurs',     Icons.two_wheeler_outlined,     Icons.two_wheeler,   'Livreurs'),
    _NavItem('/admin/points',       Icons.store_outlined,           Icons.store,         'Points'),
    _NavItem('/admin/colis',        Icons.inventory_2_outlined,     Icons.inventory_2,   'Colis'),
    _NavItem('/admin/vehicules',    Icons.directions_car_outlined,  Icons.directions_car,'Véhicules'),
    _NavItem('/admin/zones',        Icons.map_outlined,             Icons.map,           'Zones'),
    _NavItem('/admin/tarifs',       Icons.price_change_outlined,    Icons.price_change,  'Tarifs'),
    _NavItem('/admin/transactions', Icons.receipt_long_outlined,    Icons.receipt_long,  'Transactions'),
    _NavItem('/admin/forfaits',     Icons.card_membership_outlined, Icons.card_membership,'Forfaits'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(body: Row(children: [
        _SideNav(location: location, onLogout: () => ref.read(authProvider.notifier).logout()),
        Expanded(child: child),
      ]));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_navItems.firstWhere((n) => location.startsWith(n.path), orElse: () => _navItems.first).label)),
      drawer: Drawer(child: _SideNav(location: location, onLogout: () => ref.read(authProvider.notifier).logout())),
      body: child,
    );
  }
}

class _SideNav extends ConsumerWidget {
  final String location;
  final VoidCallback onLogout;
  const _SideNav({required this.location, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Container(
      width: 240,
      color: AppColors.secondary,
      child: Column(children: [
        Container(padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22)),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ILLICO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 2)),
              Text('Admin', style: TextStyle(color: AppColors.primary, fontSize: 11)),
            ]),
          ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(user?.nom.isNotEmpty == true ? user!.nom[0] : 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.nom ?? 'Admin', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              const Text('Administrateur', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ])),
          ])),
        const Divider(color: Colors.white12, height: 24),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          children: AdminShell._navItems.map((item) {
            final active = location.startsWith(item.path);
            return Padding(padding: const EdgeInsets.only(bottom: 2),
              child: ListTile(
                leading: Icon(active ? item.activeIcon : item.icon, color: active ? AppColors.primary : Colors.white60, size: 20),
                title: Text(item.label, style: TextStyle(color: active ? AppColors.primary : Colors.white70, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                selected: active,
                selectedTileColor: AppColors.primary.withOpacity(0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                dense: true,
                onTap: () { if (Scaffold.of(context).hasDrawer) Navigator.pop(context); context.go(item.path); },
              ));
          }).toList())),
        const Divider(color: Colors.white12),
        Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white60, size: 20),
            title: const Text('Déconnexion', style: TextStyle(color: Colors.white70, fontSize: 13)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            dense: true,
            onTap: onLogout,
          )),
      ]),
    );
  }
}

class _NavItem {
  final String path, label;
  final IconData icon, activeIcon;
  const _NavItem(this.path, this.icon, this.activeIcon, this.label);
}
