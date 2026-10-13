import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    this.displayName = 'Usuario',
    this.paidPlan = false,
  });

  final String displayName;
  final bool paidPlan;

  static const _items = [
    _CartItem(
      title: 'Anatomía humana',
      price: '45.00 soles',
      color: Color(0xFF7A2830),
      imagePath: 'assets/images/ImagenLibro/LibroAnatomiaHumana.png',
    ),
    _CartItem(
      title: 'JavaScript: The Definitive Guide',
      price: '55.00 soles',
      color: Color(0xFF3E5668),
      imagePath: 'assets/images/ImagenLibro/LibroJavaScriptTheDefinitiveGuide.png',
    ),
    _CartItem(
      title: 'Python',
      price: '35.00 soles',
      color: Color(0xFFC88E65),
      imagePath: 'assets/images/ImagenLibro/LibroPython.png',
    ),
  ];

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
              ? (width / 430).clamp(0.82, 1.0)
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
                        12 * scale,
                        16 * scale,
                        12 * scale,
                        12 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu, size: 42 * scale),
                              Expanded(
                                child: Text(
                                  'BookSmarth',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(Icons.search, size: 42 * scale),
                            ],
                          ),
                          SizedBox(height: 8 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _TabLabel(
                                label: 'Leyendo',
                                selected: true,
                                scale: scale,
                              ),
                              _TabLabel(label: 'Completados', scale: scale),
                              _TabLabel(label: 'Pendiente', scale: scale),
                            ],
                          ),
                          Divider(
                            color: const Color(0xFF638DB1),
                            thickness: 4 * scale,
                            height: 8 * scale,
                          ),
                          Text(
                            'Resumen del pedido...',
                            style: TextStyle(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 20 * scale),
                          ..._items.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 16 * scale),
                              child: _CartItemRow(item: item, scale: scale),
                            ),
                          ),
                          SizedBox(height: 2 * scale),
                          _OrderTotal(scale: scale),
                        ],
                      ),
                    ),
                  ),
                  _CartNavigation(
                    scale: scale,
                    paidPlan: paidPlan,
                    selectedIndex: paidPlan ? 1 : 2,
                    onSelected: (index) {
                      if (index == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => HomeScreen(
                              displayName: displayName,
                              paidPlan: paidPlan,
                            ),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CatalogScreen(
                              displayName: displayName,
                              paidPlan: paidPlan,
                            ),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                LibraryScreen(displayName: displayName),
                          ),
                        );
                      } else if (index == 3) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ProfileScreen(displayName: displayName),
                          ),
                        );
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

class _CartItem {
  const _CartItem({
    required this.title,
    required this.price,
    required this.color,
    required this.imagePath,
  });

  final String title;
  final String price;
  final Color color;
  final String imagePath;
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.scale,
    this.selected = false,
  });

  final String label;
  final double scale;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: selected ? const Color(0xFFE9BD40) : Colors.black54,
        fontSize: 17 * scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item, required this.scale});

  final _CartItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_box, color: const Color(0xFF28639B), size: 35 * scale),
        SizedBox(width: 14 * scale),
        _BookThumb(item: item, scale: scale),
        SizedBox(width: 18 * scale),
        Expanded(
          child: Container(
            constraints: BoxConstraints(minHeight: 72 * scale),
            padding: EdgeInsets.symmetric(
              horizontal: 18 * scale,
              vertical: 12 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF4477A5),
              borderRadius: BorderRadius.circular(20 * scale),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.price,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.close,
                  color: const Color(0xFFF0C94D),
                  size: 31 * scale,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookThumb extends StatelessWidget {
  const _BookThumb({required this.item, required this.scale});

  final _CartItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52 * scale,
      height: 84 * scale,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            BookCoverImage(path: item.imagePath),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 4 * scale,
              right: 4 * scale,
              bottom: 6 * scale,
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 6.5 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTotal extends StatelessWidget {
  const _OrderTotal({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 28 * scale),
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        16 * scale,
        24 * scale,
        14 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5D267),
        border: Border.all(color: const Color(0xFF009AF5), width: 2.5 * scale),
        borderRadius: BorderRadius.circular(22 * scale),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Subtotal\nDescuento VIP\nTOTAL',
                  style: TextStyle(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              Text(
                '95\n-20%\n76',
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          SizedBox(
            height: 28 * scale,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4477A5),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18 * scale),
                ),
              ),
              child: Text(
                'Finaliza compra',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartNavigation extends StatelessWidget {
  const _CartNavigation({
    required this.scale,
    required this.paidPlan,
    required this.selectedIndex,
    required this.onSelected,
  });

  final double scale;
  final bool paidPlan;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final icons = paidPlan
        ? const [
            Icons.home,
            Icons.business_center,
            Icons.favorite,
            Icons.check_circle,
            Icons.person,
          ]
        : const [
            Icons.home,
            Icons.business_center,
            Icons.menu_book,
            Icons.person,
          ];
    final labels = paidPlan
        ? const ['Inicio', 'Catalogo', 'Favoritos', 'Completados', 'Perfil']
        : const ['Inicio', 'Catalogo', 'Mi Biblioteca', 'Perfil'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF638DB1), width: 4)),
      ),
      padding: EdgeInsets.symmetric(vertical: 12 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (index) => InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(8 * scale),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icons[index],
                    size: 33 * scale,
                    color: selectedIndex == index
                        ? const Color(0xFFE9BD40)
                        : const Color(0xFF28639B),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    labels[index],
                    style: TextStyle(fontSize: 11 * scale, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FreeCartScreen extends CartScreen {
  const FreeCartScreen({super.key, super.displayName}) : super(paidPlan: false);
}

class PaidCartScreen extends CartScreen {
  const PaidCartScreen({super.key, super.displayName}) : super(paidPlan: true);
}
