import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'paid_library_screen.dart';

class PaidProfileScreen extends StatelessWidget {
  const PaidProfileScreen({super.key, this.displayName = 'Usuario'});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const ScreenCloseButton(),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final frameWidth = useFullScreen
              ? width
              : (width - 32).clamp(280.0, 440.0);
          final scale = useFullScreen
              ? (width / 430).clamp(0.72, 1.0)
              : (frameWidth / 375).clamp(0.68, 1.1);

          return Center(
            child: Container(
              width: frameWidth,
              height: useFullScreen
                  ? constraints.maxHeight
                  : constraints.maxHeight - 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2DB),
                border: useFullScreen
                    ? null
                    : Border.all(
                        color: const Color(0xFF39688F),
                        width: 9 * scale,
                      ),
                borderRadius: useFullScreen
                    ? null
                    : BorderRadius.circular(28 * scale),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        30 * scale,
                        42 * scale,
                        30 * scale,
                        20 * scale,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 164 * scale,
                                  height: 164 * scale,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF285A98),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 125 * scale,
                                    color: const Color(0xFFFFF2DB),
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Icon(
                                  Icons.settings,
                                  color: const Color(0xFF285A98),
                                  size: 46 * scale,
                                ),
                              ],
                            ),
                            SizedBox(height: 6 * scale),
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Membresía premium activa',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 28 * scale),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 18 * scale,
                                vertical: 17 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0C94D),
                                borderRadius: BorderRadius.circular(22 * scale),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Invita y gana\nCódigo del personal',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                    ),
                                  ),
                                  SizedBox(height: 10 * scale),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18 * scale,
                                      vertical: 4 * scale,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4477A5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'book smart 2026',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Gana 1 VIP gratis\nreferidos completados',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 22 * scale),
                            _ProfileOption(
                              icon: Icons.settings,
                              label: 'Ajustes de lectura',
                              scale: scale,
                            ),
                            _ProfileOption(
                              icon: Icons.add_circle,
                              label: 'Suscripción',
                              scale: scale,
                            ),
                            _ProfileOption(
                              icon: Icons.receipt_long,
                              label: 'Comprobantes',
                              scale: scale,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _PaidProfileNavigation(
                    scale: scale,
                    onSelected: (index) {
                      final route = switch (index) {
                        0 => HomeScreen(
                          displayName: displayName,
                          paidPlan: true,
                        ),
                        1 => PaidCartScreen(displayName: displayName),
                        2 => CatalogScreen(
                          displayName: displayName,
                          paidPlan: true,
                        ),
                        3 => PaidLibraryScreen(
                          displayName: displayName,
                          initialTab: 0,
                        ),
                        4 => PaidLibraryScreen(
                          displayName: displayName,
                          initialTab: 1,
                        ),
                        5 => PaidProfileScreen(displayName: displayName),
                        _ => null,
                      };
                      if (route != null) {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute<void>(builder: (_) => route));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.scale,
  });

  final IconData icon;
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$label próximamente'))),
      borderRadius: BorderRadius.circular(12 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9 * scale),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF285A98), size: 31 * scale),
            SizedBox(width: 18 * scale),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF285A98),
              size: 38 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaidProfileNavigation extends StatelessWidget {
  const _PaidProfileNavigation({required this.scale, required this.onSelected});

  final double scale;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home,
      Icons.shopping_cart,
      Icons.business_center,
      Icons.favorite,
      Icons.check_circle,
      Icons.person,
    ];
    const labels = [
      'Inicio',
      'Carrito',
      'Catálogo',
      'Favoritos',
      'Completados',
      'Perfil',
    ];
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF638DB1), width: 4)),
      ),
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (index) => InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    size: 30 * scale,
                    color: index == 5
                        ? const Color(0xFFF0C94D)
                        : const Color(0xFF285A98),
                  ),
                  Text(labels[index], style: TextStyle(fontSize: 10 * scale)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
