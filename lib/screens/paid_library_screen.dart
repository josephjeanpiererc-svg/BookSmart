import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/platform_layout.dart';
import '../widgets/booksmart_widgets.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'paid_profile_screen.dart';

class PaidLibraryScreen extends StatefulWidget {
  const PaidLibraryScreen({
    super.key,
    this.displayName = 'Usuario',
    this.initialTab = 0,
  });

  final String displayName;
  final int initialTab;

  @override
  State<PaidLibraryScreen> createState() => _PaidLibraryScreenState();
}

class _PaidLibraryScreenState extends State<PaidLibraryScreen> {
  late int _selectedTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final useFullScreen =
        shouldUseFullScreenLayout(defaultTargetPlatform) || kIsWeb;

    return Scaffold(
      floatingActionButton: const ScreenCloseButton(),
      floatingActionButtonLocation: screenCloseButtonLocation,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final frameWidth = useFullScreen
              ? width
              : (width - 32).clamp(280.0, 440.0);
          final scale = useFullScreen
              ? (width / 600).clamp(0.82, 1.0)
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
                        16 * scale,
                        14 * scale,
                        16 * scale,
                        10 * scale,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.menu, size: 42 * scale),
                              Expanded(
                                child: Text(
                                  'Mi biblioteca',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 25 * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(Icons.search, size: 42 * scale),
                            ],
                          ),
                          SizedBox(height: 6 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _PaidLibraryTab(
                                label: 'Leyendo',
                                selected: _selectedTab == 0,
                                scale: scale,
                                onTap: () => setState(() => _selectedTab = 0),
                              ),
                              _PaidLibraryTab(
                                label: 'Completados',
                                selected: _selectedTab == 1,
                                scale: scale,
                                onTap: () => setState(() => _selectedTab = 1),
                              ),
                            ],
                          ),
                          Divider(
                            color: const Color(0xFF638DB1),
                            thickness: 4 * scale,
                            height: 8 * scale,
                          ),
                          Text(
                            _selectedTab == 0
                                ? 'Meta vip 14 a 24 libros...'
                                : '50 libros completados',
                            style: TextStyle(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 18 * scale),
                          _PaidLibraryBooks(
                            scale: scale,
                            completed: _selectedTab == 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _PaidLibraryNavigation(
                    scale: scale,
                    selectedIndex: _selectedTab == 0 ? 3 : 4,
                    onSelected: (index) {
                      if (index == 0) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => HomeScreen(
                              displayName: widget.displayName,
                              paidPlan: true,
                            ),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PaidCartScreen(displayName: widget.displayName),
                          ),
                        );
                      } else if (index == 2) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CatalogScreen(
                              displayName: widget.displayName,
                              paidPlan: true,
                            ),
                          ),
                        );
                      } else if (index == 3) {
                        setState(() => _selectedTab = 0);
                      } else if (index == 4) {
                        setState(() => _selectedTab = 1);
                      } else if (index == 5) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PaidProfileScreen(
                              displayName: widget.displayName,
                            ),
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

class _PaidLibraryTab extends StatelessWidget {
  const _PaidLibraryTab({
    required this.label,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFFE9BD40) : Colors.black54,
          fontSize: 17 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaidLibraryBooks extends StatelessWidget {
  const _PaidLibraryBooks({required this.scale, required this.completed});

  final double scale;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final books = completed
        ? const [
            ('Anatomía\nhumana', Color(0xFF496344)),
            ('Diagnóstico\nclínico', Color(0xFF7A2830)),
            ('Python', Color(0xFFC88E65)),
          ]
        : const [
            ('JavaScript', Color(0xFF3E5668)),
            ('Artificial\nIntelligence', Color(0xFF496344)),
            ('Contabilidad\nfinanciera', Color(0xFFC88E65)),
          ];

    return Wrap(
      alignment: WrapAlignment.spaceAround,
      runSpacing: 18 * scale,
      spacing: 18 * scale,
      children: books
          .map(
            (book) => Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 92 * scale,
                      height: 136 * scale,
                      color: book.$2,
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 * scale),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            BookCoverImage(
                              path: _paidLibraryImagePath(book.$1),
                            ),
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
                              left: 6 * scale,
                              right: 6 * scale,
                              bottom: 8 * scale,
                              child: Text(
                                book.$1,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10 * scale,
                                  fontWeight: FontWeight.w700,
                                  height: 1.05,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -10 * scale,
                      top: -10 * scale,
                      child: Icon(
                        completed ? Icons.check_circle : Icons.favorite,
                        color: completed
                            ? const Color(0xFF28639B)
                            : const Color(0xFFF0C94D),
                        size: 34 * scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

String _paidLibraryImagePath(String title) {
  if (title.contains('Anatomía')) {
    return 'assets/images/ImagenLibro/LibroAnatomiaHumana.png';
  }
  if (title.contains('Diagnóstico')) {
    return 'assets/images/ImagenLibro/LibroDiagnosticoClinico.png';
  }
  if (title.contains('Python')) {
    return 'assets/images/ImagenLibro/LibroPython.png';
  }
  if (title.contains('JavaScript')) {
    return 'assets/images/ImagenLibro/LibroJavaScriptTheDefinitiveGuide.png';
  }
  if (title.contains('Artificial')) {
    return 'assets/images/ImagenLibro/LibroLugarArtificialIntelligence.png';
  }
  return 'assets/images/ImagenLibro/LibroContabilidadFinancieraIntermedia.png';
}

class _PaidLibraryNavigation extends StatelessWidget {
  const _PaidLibraryNavigation({
    required this.scale,
    required this.selectedIndex,
    required this.onSelected,
  });

  final double scale;
  final int selectedIndex;
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
      'Catalogo',
      'Favoritos',
      'Completados',
      'Perfil',
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF638DB1), width: 4)),
      ),
      padding: EdgeInsets.symmetric(vertical: 7 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
          (index) => InkWell(
            onTap: () => onSelected(index),
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
                Text(labels[index], style: TextStyle(fontSize: 11 * scale)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
